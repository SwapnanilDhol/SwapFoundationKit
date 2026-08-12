/*****************************************************************************
 * UserDefault.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import Foundation

#if canImport(SwiftUI)
import SwiftUI
#endif

/// Protocol for UserDefault keys, allowing enums or other types to be used as keys.
public protocol UserDefaultKeyProtocol {
    /// The string value to use as the key in UserDefaults.
    var keyString: String { get }
}

/// A property wrapper for values shared through the app group's UserDefaults suite.
///
/// The suite is resolved internally from the `AppMetaData` installed with
/// `SwapFoundationKit.shared.configure(with:)`. Host apps declare shared
/// preferences without constructing or exposing a `UserDefaults` store.
///
/// ## Usage
/// ```swift
/// @SharedUserDefaults(AppKeys.isProEnabled, default: false)
/// private var isProEnabled
/// ```
@propertyWrapper
public struct SharedUserDefaults<Value, Key: UserDefaultKeyProtocol> {
    private let key: String
    private let defaultValue: Value

    public var wrappedValue: Value {
        get {
            sharedStore.object(forKey: key) as? Value ?? defaultValue
        }
        nonmutating set {
            sharedStore.set(newValue, forKey: key)
        }
    }

    /// Creates an app-group preference backed by configured SFK app metadata.
    /// - Parameters:
    ///   - key: The type-safe defaults key.
    ///   - defaultValue: The value returned when the key has not been stored.
    public init(_ key: Key, default defaultValue: Value) {
        self.key = key.keyString
        self.defaultValue = defaultValue
    }

    private var sharedStore: UserDefaults {
        guard let appMetadata = SwapFoundationKit.shared.getConfiguration()?.appMetadata else {
            preconditionFailure(
                "SwapFoundationKit is not configured. Call configure(with:) before accessing @SharedUserDefaults."
            )
        }

        guard let store = UserDefaults(suiteName: appMetadata.appGroupIdentifier) else {
            preconditionFailure(
                "Unable to open app-group defaults: \(appMetadata.appGroupIdentifier)"
            )
        }

        return store
    }
}

#if canImport(SwiftUI)
/// An observable box for a value stored in UserDefaults, used for property wrappers and SwiftUI bindings.
///
/// - Note: Only updates UserDefaults when the value actually changes.
final class UserDefaultBox<T: Equatable>: ObservableObject {
    /// The value stored in UserDefaults. Updates UserDefaults when changed.
    @Published var value: T {
        didSet {
            if value != oldValue {
                container.set(value, forKey: key)
            }
        }
    }

    private let key: String
    private let container: UserDefaults

    /// Initializes the box with a key, default value, and UserDefaults container.
    /// - Parameters:
    ///   - key: The key string for UserDefaults.
    ///   - defaultValue: The default value to use if no value is stored.
    ///   - container: The UserDefaults instance to use.
    init(key: String, defaultValue: T, container: UserDefaults) {
        self.key = key
        self.container = container
        let stored = container.object(forKey: key) as? T
        self.value = stored ?? defaultValue
    }
}
#endif

#if canImport(SwiftUI)
/// A property wrapper for type-safe, observable UserDefaults access with SwiftUI support.
///
/// Use with a key conforming to `UserDefaultKeyProtocol` and an `Equatable` value type.
@MainActor
@propertyWrapper
public struct UserDefault<T: Equatable, Key: UserDefaultKeyProtocol>: DynamicProperty {
    @ObservedObject private var box: UserDefaultBox<T>

    /// The value stored in UserDefaults.
    public var wrappedValue: T {
        get { box.value }
        nonmutating set { box.value = newValue }
    }

    /// A SwiftUI binding to the value.
    public var projectedValue: Binding<T> {
        Binding(get: { self.box.value }, set: { self.box.value = $0 })
    }

    /// Initializes the property wrapper.
    /// - Parameters:
    ///   - key: The key to use for UserDefaults.
    ///   - defaultValue: The default value if no value is stored.
    ///   - container: The UserDefaults instance to use (default: .standard).
    public init(_ key: Key, default defaultValue: T, container: UserDefaults = .standard) {
        self.box = UserDefaultBox(key: key.keyString, defaultValue: defaultValue, container: container)
    }
}
#endif
