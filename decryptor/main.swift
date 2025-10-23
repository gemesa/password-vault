import CommonCrypto
import CryptoKit
import Foundation

guard CommandLine.arguments.count == 3 else {
    print("Usage: ./decrypt <vault_file_path> <password>")
    exit(1)
}

let filePath = CommandLine.arguments[1]
let password = CommandLine.arguments[2]

guard let encryptedData = FileManager.default.contents(atPath: filePath) else {
    print("Error: Could not read file at path: \(filePath)")
    exit(1)
}

do {
    let decryptedData = try VaultEncryption.decrypt(
        encryptedData: encryptedData, password: password)
    print("Decrypted \(decryptedData.count) bytes")

    NSKeyedUnarchiver.setClass(PasswordEntry.self, forClassName: "PasswordEntry")

    let classes = [NSArray.self, PasswordEntry.self]
    let entries =
        try NSKeyedUnarchiver.unarchivedObject(
            ofClasses: classes,
            from: decryptedData
        ) as? [PasswordEntry]

    if let entries = entries {
        print("\nDecrypted \(entries.count) password entries:\n")
        for (index, entry) in entries.enumerated() {
            print("[\(index + 1)]")
            print(entry)
            print(String(repeating: "-", count: 50))
        }
    } else {
        print("Could not deserialize entries")
    }

} catch {
    print("Error: \(error.localizedDescription)")
    print("Full error: \(error)")
    exit(1)
}
