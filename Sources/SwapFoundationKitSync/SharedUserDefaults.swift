import Foundation
import SwapFoundationKit

/// Runtime bridge retained for the deprecated bootstrap compatibility product.
/// New code should pass an app-group identifier to `SharedUserDefaults` directly.
public enum SFKSharedDefaultsRuntime {
    private static let lock = NSLock()
    private static var suiteName: String?

    public static func configure(appGroupIdentifier: String) {
        lock.lock()
        suiteName = appGroupIdentifier
        lock.unlock()
    }

    public static func reset() {
        lock.lock()
        suiteName = nil
        lock.unlock()
    }

    fileprivate static func configuredSuiteName() -> String? {
        lock.lock()
        defer { lock.unlock() }
        return suiteName
    }
}

/// A property wrapper backed by an app-group `UserDefaults` suite.
///
/// Prefer the explicit initializer so the storage dependency is visible at the
/// feature boundary. The no-identifier overload remains only for the legacy
/// bootstrap product and is deprecated.
@propertyWrapper
public struct SharedUserDefaults<Value, Key: UserDefaultKeyProtocol> {
    private let key: String
    private let defaultValue: Value
    private let suiteName: String?

    public var wrappedValue: Value {
        get { store.object(forKey: key) as? Value ?? defaultValue }
        nonmutating set { store.set(newValue, forKey: key) }
    }

    public init(_ key: Key, default defaultValue: Value, appGroupIdentifier: String) {
        self.key = key.keyString
        self.defaultValue = defaultValue
        self.suiteName = appGroupIdentifier
    }

    @available(*, deprecated, message: "Pass appGroupIdentifier explicitly; this overload is for SwapFoundationKitLegacy only.")
    public init(_ key: Key, default defaultValue: Value) {
        self.key = key.keyString
        self.defaultValue = defaultValue
        self.suiteName = nil
    }

    private var store: UserDefaults {
        guard let suiteName = suiteName ?? SFKSharedDefaultsRuntime.configuredSuiteName(),
              let store = UserDefaults(suiteName: suiteName) else {
            preconditionFailure(
                "SharedUserDefaults requires a valid app-group identifier. " +
                "Pass appGroupIdentifier explicitly or configure SwapFoundationKitLegacy first."
            )
        }
        return store
    }
}
