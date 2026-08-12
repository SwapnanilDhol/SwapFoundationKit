import Foundation
import Security

public final class SFKFeedbackInstallationIdentifierStore: @unchecked Sendable {
    private let service: String
    private let account = "feedback-installation-id"

    public init(bundleIdentifier: String = Bundle.main.bundleIdentifier ?? "app") {
        service = "\(bundleIdentifier).feedback"
    }

    public func identifier() throws -> UUID {
        if let existing = try readIdentifier() {
            return existing
        }
        let identifier = UUID()
        let status = SecItemAdd(
            [
                kSecClass: kSecClassGenericPassword,
                kSecAttrService: service,
                kSecAttrAccount: account,
                kSecAttrSynchronizable: false,
                kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
                kSecValueData: Data(identifier.uuidString.utf8)
            ] as CFDictionary,
            nil
        )
        if status == errSecDuplicateItem, let existing = try readIdentifier() {
            return existing
        }
        guard status == errSecSuccess else { throw StoreError.keychain(status) }
        return identifier
    }

    private func readIdentifier() throws -> UUID? {
        var item: CFTypeRef?
        let status = SecItemCopyMatching(
            [
                kSecClass: kSecClassGenericPassword,
                kSecAttrService: service,
                kSecAttrAccount: account,
                kSecAttrSynchronizable: false,
                kSecReturnData: true,
                kSecMatchLimit: kSecMatchLimitOne
            ] as CFDictionary,
            &item
        )
        if status == errSecItemNotFound { return nil }
        guard status == errSecSuccess,
              let data = item as? Data,
              let value = String(data: data, encoding: .utf8),
              let identifier = UUID(uuidString: value)
        else { throw StoreError.keychain(status) }
        return identifier
    }

    private enum StoreError: Error {
        case keychain(OSStatus)
    }
}
