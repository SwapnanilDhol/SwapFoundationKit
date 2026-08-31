import Foundation
import SwapFoundationKit

/// A property wrapper backed by an app-group `UserDefaults` suite.
///
/// The suite dependency is explicit so the storage boundary is visible at the
/// feature boundary and works identically in apps, widgets, and extensions.
@propertyWrapper
public struct SharedUserDefaults<Value, Key: UserDefaultKeyProtocol> {
    private let key: String
    private let defaultValue: Value
    private let suiteName: String

    public var wrappedValue: Value {
        get { store.object(forKey: key) as? Value ?? defaultValue }
        nonmutating set { store.set(newValue, forKey: key) }
    }

    public init(_ key: Key, default defaultValue: Value, appGroupIdentifier: String) {
        self.key = key.keyString
        self.defaultValue = defaultValue
        self.suiteName = appGroupIdentifier
    }

    private var store: UserDefaults {
        guard !suiteName.isEmpty, let store = UserDefaults(suiteName: suiteName) else {
            preconditionFailure(
                "SharedUserDefaults requires a valid app-group identifier. " +
                "Pass appGroupIdentifier explicitly."
            )
        }
        return store
    }
}
