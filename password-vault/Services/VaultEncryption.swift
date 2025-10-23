import CommonCrypto
import CryptoKit
import Foundation

@objc public class VaultEncryption: NSObject {

    private static let saltSize = 16
    private static let iterations = 100_000

    @objc public static func encrypt(data: Data, password: String) throws -> Data {
        var salt = Data(count: saltSize)
        let result = salt.withUnsafeMutableBytes { saltBytes in
            SecRandomCopyBytes(kSecRandomDefault, saltSize, saltBytes.baseAddress!)
        }

        guard result == errSecSuccess else {
            throw VaultEncryptionError.saltGenerationFailed
        }

        guard let passwordData = password.data(using: .utf8) else {
            throw VaultEncryptionError.invalidPassword
        }

        let key = try deriveKey(from: passwordData, salt: salt)
        let nonce = AES.GCM.Nonce()
        let sealedBox = try AES.GCM.seal(data, using: key, nonce: nonce)

        var encryptedData = Data()
        encryptedData.append(salt)
        encryptedData.append(nonce.withUnsafeBytes { Data($0) })
        encryptedData.append(sealedBox.ciphertext)
        encryptedData.append(sealedBox.tag)

        return encryptedData
    }

    @objc public static func decrypt(encryptedData: Data, password: String) throws -> Data {
        guard encryptedData.count >= 44 else {
            throw VaultEncryptionError.invalidEncryptedData
        }

        let salt = encryptedData.prefix(saltSize)
        let nonce = encryptedData.dropFirst(saltSize).prefix(12)
        let ciphertext = encryptedData.dropFirst(saltSize + 12).dropLast(16)
        let tag = encryptedData.suffix(16)

        guard let passwordData = password.data(using: .utf8) else {
            throw VaultEncryptionError.invalidPassword
        }

        let key = try deriveKey(from: passwordData, salt: salt)
        let gcmNonce = try AES.GCM.Nonce(data: nonce)
        let sealedBox = try AES.GCM.SealedBox(
            nonce: gcmNonce,
            ciphertext: ciphertext,
            tag: tag)

        let decryptedData = try AES.GCM.open(sealedBox, using: key)
        return decryptedData
    }

    private static func deriveKey(from password: Data, salt: Data) throws -> SymmetricKey {
        guard
            let derivedKey = try? PBKDF2.deriveKey(
                from: password,
                salt: salt,
                iterations: iterations,
                keyLength: 32
            )
        else {
            throw VaultEncryptionError.keyDerivationFailed
        }

        return SymmetricKey(data: derivedKey)
    }
}

private struct PBKDF2 {
    static func deriveKey(
        from password: Data,
        salt: Data,
        iterations: Int,
        keyLength: Int
    ) throws -> Data {
        var derivedKeyData = Data(count: keyLength)

        let derivationStatus = derivedKeyData.withUnsafeMutableBytes { derivedKeyBytes in
            salt.withUnsafeBytes { saltBytes in
                password.withUnsafeBytes { passwordBytes in
                    CCKeyDerivationPBKDF(
                        CCPBKDFAlgorithm(kCCPBKDF2),
                        passwordBytes.baseAddress?.assumingMemoryBound(to: Int8.self),
                        password.count,
                        saltBytes.baseAddress?.assumingMemoryBound(to: UInt8.self),
                        salt.count,
                        CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA256),
                        UInt32(iterations),
                        derivedKeyBytes.baseAddress?.assumingMemoryBound(to: UInt8.self),
                        keyLength
                    )
                }
            }
        }

        guard derivationStatus == kCCSuccess else {
            throw VaultEncryptionError.keyDerivationFailed
        }

        return derivedKeyData
    }
}

public enum VaultEncryptionError: Int, Error, LocalizedError {
    case saltGenerationFailed
    case invalidPassword
    case keyDerivationFailed
    case encryptionFailed
    case invalidEncryptedData
    case decryptionFailed

    public var errorDescription: String? {
        switch self {
        case .saltGenerationFailed:
            return "Failed to generate random salt"
        case .invalidPassword:
            return "Invalid password format"
        case .keyDerivationFailed:
            return "Failed to derive encryption key"
        case .encryptionFailed:
            return "Encryption failed"
        case .invalidEncryptedData:
            return "Invalid encrypted data format"
        case .decryptionFailed:
            return "Decryption failed"
        }
    }
}
