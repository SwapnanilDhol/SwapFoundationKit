import Foundation
import Security
#if canImport(CommonCrypto)
import CommonCrypto
#endif

/// Service for handling security operations including encryption, keychain access, and secure storage
public final class SecurityService {
    
    public enum SecurityError: Error, LocalizedError {
        case encryptionFailed
        case decryptionFailed
        case keychainError(OSStatus)
        case invalidData
        case keyGenerationFailed
        case encodingFailed
        
        public var errorDescription: String? {
            switch self {
            case .encryptionFailed:
                return "Failed to encrypt data"
            case .decryptionFailed:
                return "Failed to decrypt data"
            case .keychainError(let status):
                return "Keychain error: \(status)"
            case .invalidData:
                return "Invalid data provided"
            case .keyGenerationFailed:
                return "Failed to generate encryption key"
            case .encodingFailed:
                return "Failed to encode data"
            }
        }
    }
    
    private let keychain = KeychainService()
    
    public init() {}
    
    // MARK: - Encryption/Decryption
    
    /// Encrypts data using AES encryption
    /// - Parameter data: The data to encrypt
    /// - Returns: Encrypted data
    /// - Throws: SecurityError
    public func encrypt(_ data: Data) throws -> Data {
        let key = try generateEncryptionKey()
        let encryptedData = try AESEncryption.encrypt(data, using: key)
        return encryptedData
    }
    
    /// Decrypts data using AES decryption
    /// - Parameter encryptedData: The encrypted data
    /// - Returns: Decrypted data
    /// - Throws: SecurityError
    public func decrypt(_ encryptedData: Data) throws -> Data {
        let key = try generateEncryptionKey()
        let decryptedData = try AESEncryption.decrypt(encryptedData, using: key)
        return decryptedData
    }
    
    /// Encrypts a string and returns base64 encoded result
    /// - Parameter string: The string to encrypt
    /// - Returns: Base64 encoded encrypted string
    /// - Throws: SecurityError
    public func encryptString(_ string: String) throws -> String {
        guard let data = string.data(using: .utf8) else {
            throw SecurityError.encodingFailed
        }
        
        let encryptedData = try encrypt(data)
        return encryptedData.base64EncodedString()
    }
    
    /// Decrypts a base64 encoded encrypted string
    /// - Parameter encryptedString: The base64 encoded encrypted string
    /// - Returns: Decrypted string
    /// - Throws: SecurityError
    public func decryptString(_ encryptedString: String) throws -> String {
        guard let encryptedData = Data(base64Encoded: encryptedString) else {
            throw SecurityError.invalidData
        }
        
        let decryptedData = try decrypt(encryptedData)
        guard let string = String(data: decryptedData, encoding: .utf8) else {
            throw SecurityError.encodingFailed
        }
        
        return string
    }
    
    // MARK: - Keychain Operations
    
    /// Securely stores data in the keychain
    /// - Parameters:
    ///   - data: The data to store
    ///   - key: The key to store the data under
    ///   - accessibility: The accessibility level for the keychain item
    /// - Throws: SecurityError
    public func storeInKeychain(_ data: Data, forKey key: String, accessibility: CFString = kSecAttrAccessibleWhenUnlockedThisDeviceOnly) throws {
        try keychain.store(data: data, forKey: key, accessibility: accessibility)
    }
    
    /// Retrieves data from the keychain
    /// - Parameter key: The key to retrieve data for
    /// - Returns: The stored data
    /// - Throws: SecurityError
    public func retrieveFromKeychain(forKey key: String) throws -> Data {
        return try keychain.retrieve(forKey: key)
    }
    
    /// Removes data from the keychain
    /// - Parameter key: The key to remove
    /// - Throws: SecurityError
    public func removeFromKeychain(forKey key: String) throws {
        try keychain.remove(forKey: key)
    }
    
    /// Checks if a key exists in the keychain
    /// - Parameter key: The key to check
    /// - Returns: True if the key exists
    public func keyExistsInKeychain(_ key: String) -> Bool {
        return keychain.keyExists(key)
    }
    
    // MARK: - Secure Storage
    
    /// Securely stores sensitive data with encryption
    /// - Parameters:
    ///   - data: The data to store
    ///   - key: The storage key
    /// - Throws: SecurityError
    public func storeSecurely(_ data: Data, forKey key: String) throws {
        let encryptedData = try encrypt(data)
        try storeInKeychain(encryptedData, forKey: key)
    }
    
    /// Retrieves and decrypts securely stored data
    /// - Parameter key: The storage key
    /// - Returns: The decrypted data
    /// - Throws: SecurityError
    public func retrieveSecurely(forKey key: String) throws -> Data {
        let encryptedData = try retrieveFromKeychain(forKey: key)
        return try decrypt(encryptedData)
    }
    
    // MARK: - Hash Generation
    
    /// Generates a SHA256 hash of the provided data
    /// - Parameter data: The data to hash
    /// - Returns: SHA256 hash as Data
    public func sha256Hash(_ data: Data) -> Data {
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes { buffer in
            _ = CC_SHA256(buffer.baseAddress, CC_LONG(data.count), &hash)
        }
        return Data(hash)
    }
    
    /// Generates a SHA256 hash of the provided string
    /// - Parameter string: The string to hash
    /// - Returns: SHA256 hash as hex string
    public func sha256Hash(_ string: String) -> String {
        guard let data = string.data(using: .utf8) else { return "" }
        let hash = sha256Hash(data)
        return hash.map { String(format: "%02hhx", $0) }.joined()
    }
    
    // MARK: - Private Methods
    
    private func generateEncryptionKey() throws -> Data {
        // In a production app, you'd want to use a more sophisticated key generation
        // and key derivation strategy
        let keySize = kCCKeySizeAES256
        var key = [UInt8](repeating: 0, count: keySize)
        let status = SecRandomCopyBytes(kSecRandomDefault, keySize, &key)
        
        guard status == errSecSuccess else {
            throw SecurityError.keyGenerationFailed
        }
        
        return Data(key)
    }
}

// MARK: - Keychain Service

private class KeychainService {
    
    func store(data: Data, forKey key: String, accessibility: CFString) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: accessibility
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecDuplicateItem {
            // Item already exists, update it
            let updateQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: key
            ]
            
            let updateAttributes: [String: Any] = [
                kSecValueData as String: data,
                kSecAttrAccessible as String: accessibility
            ]
            
            let updateStatus = SecItemUpdate(updateQuery as CFDictionary, updateAttributes as CFDictionary)
            guard updateStatus == errSecSuccess else {
                throw SecurityService.SecurityError.keychainError(updateStatus)
            }
        } else if status != errSecSuccess {
            throw SecurityService.SecurityError.keychainError(status)
        }
    }
    
    func retrieve(forKey key: String) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess else {
            throw SecurityService.SecurityError.keychainError(status)
        }
        
        guard let data = result as? Data else {
            throw SecurityService.SecurityError.invalidData
        }
        
        return data
    }
    
    func remove(forKey key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw SecurityService.SecurityError.keychainError(status)
        }
    }
    
    func keyExists(_ key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: false,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        let status = SecItemCopyMatching(query as CFDictionary, nil)
        return status == errSecSuccess
    }
}

// MARK: - AES Encryption

private enum AESEncryption {
    
    static func encrypt(_ data: Data, using key: Data) throws -> Data {
        let keySize = kCCKeySizeAES256
        let blockSize = kCCBlockSizeAES128
        
        let encryptedLength = size_t(data.count + blockSize)
        var encryptedData = [UInt8](repeating: 0, count: encryptedLength)
        
        let status = CCCrypt(
            CCOperation(kCCEncrypt),
            CCAlgorithm(kCCAlgorithmAES),
            CCOptions(kCCOptionPKCS7Padding),
            key.withUnsafeBytes { $0.baseAddress },
            keySize,
            nil,
            data.withUnsafeBytes { $0.baseAddress },
            data.count,
            &encryptedData,
            encryptedLength,
            nil
        )
        
        guard status == kCCSuccess else {
            throw SecurityService.SecurityError.encryptionFailed
        }
        
        return Data(encryptedData.prefix(encryptedLength))
    }
    
    static func decrypt(_ data: Data, using key: Data) throws -> Data {
        let keySize = kCCKeySizeAES256
        let blockSize = kCCBlockSizeAES128
        
        let decryptedLength = size_t(data.count)
        var decryptedData = [UInt8](repeating: 0, count: decryptedLength)
        
        let status = CCCrypt(
            CCOperation(kCCDecrypt),
            CCAlgorithm(kCCAlgorithmAES),
            CCOptions(kCCOptionPKCS7Padding),
            key.withUnsafeBytes { $0.baseAddress },
            keySize,
            nil,
            data.withUnsafeBytes { $0.baseAddress },
            data.count,
            &decryptedData,
            decryptedLength,
            nil
        )
        
        guard status == kCCSuccess else {
            throw SecurityService.SecurityError.decryptionFailed
        }
        
        return Data(decryptedData.prefix(decryptedLength))
    }
}
