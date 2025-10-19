import CryptoKit
import Foundation

struct MasterPasswordManager {
    static func setMasterPassword(_ password: String) -> Bool {
        let salt = Data((0..<16).map { _ in UInt8.random(in: 0...255) })

        let hash = HKDF<SHA256>.deriveKey(
            inputKeyMaterial: SymmetricKey(data: Data(password.utf8)),
            salt: salt,
            info: Data(),
            outputByteCount: 32)

        let hashData = hash.withUnsafeBytes { Data($0) }

        guard KeychainManager.save(hashData, account: "masterPasswordHash") else {
            return false
        }

        guard KeychainManager.save(salt, account: "masterPasswordSalt") else {
            let _ = KeychainManager.delete(account: "masterPasswordHash")
            return false
        }

        return true
    }

    static func verifyMasterPassword(_ password: String) -> Bool {
        guard let storedHash = KeychainManager.loadData(account: "masterPasswordHash"),
            let storedSalt = KeychainManager.loadData(account: "masterPasswordSalt")
        else {
            return false
        }

        let hash = HKDF<SHA256>.deriveKey(
            inputKeyMaterial: SymmetricKey(data: Data(password.utf8)),
            salt: storedSalt,
            info: Data(),
            outputByteCount: 32)

        let hashData = hash.withUnsafeBytes { Data($0) }
        return hashData == storedHash
    }

    static func hasMasterPassword() -> Bool {
        return KeychainManager.loadData(account: "masterPasswordHash") != nil
    }

    static func deleteMasterPassword() -> Bool {
        let hashDeleted = KeychainManager.delete(account: "masterPasswordHash")
        let saltDeleted = KeychainManager.delete(account: "masterPasswordSalt")
        return hashDeleted && saltDeleted
    }
}
