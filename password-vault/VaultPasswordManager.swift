import CryptoKit
import Foundation

struct VaultPasswordManager {
    static func setVaultPassword(_ password: String) -> Bool {
        let salt = Data((0..<16).map { _ in UInt8.random(in: 0...255) })

        let hash = HKDF<SHA256>.deriveKey(
            inputKeyMaterial: SymmetricKey(data: Data(password.utf8)),
            salt: salt,
            info: Data(),
            outputByteCount: 32)

        let hashData = hash.withUnsafeBytes { Data($0) }

        guard KeychainManager.save(hashData, account: "vaultPasswordHash") else {
            return false
        }

        guard KeychainManager.save(salt, account: "vaultPasswordSalt") else {
            let _ = KeychainManager.delete(account: "vaultPasswordHash")
            return false
        }

        return true
    }

    static func verifyVaultPassword(_ password: String) -> Bool {
        guard let storedHash = KeychainManager.loadData(account: "vaultPasswordHash"),
            let storedSalt = KeychainManager.loadData(account: "vaultPasswordSalt")
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

    static func hasVaultPassword() -> Bool {
        return KeychainManager.loadData(account: "vaultPasswordHash") != nil
    }

    static func deleteVaultPassword() -> Bool {
        let hashDeleted = KeychainManager.delete(account: "vaultPasswordHash")
        let saltDeleted = KeychainManager.delete(account: "vaultPasswordSalt")
        return hashDeleted && saltDeleted
    }
}
