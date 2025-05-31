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

import SwiftUI

/// Protocol for UserDefault keys, allowing enums or other types to be used as keys.
public protocol UserDefaultKeyProtocol {
    /// The string value to use as the key in UserDefaults.
    var keyString: String { get }
}

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

/// A property wrapper for type-safe, observable UserDefaults access with SwiftUI support.
///
/// Use with a key conforming to `UserDefaultKeyProtocol` and an `Equatable` value type.
@propertyWrapper
struct UserDefault<T: Equatable, Key: UserDefaultKeyProtocol>: DynamicProperty {
    @ObservedObject private var box: UserDefaultBox<T>

    /// The value stored in UserDefaults.
    var wrappedValue: T {
        get { box.value }
        nonmutating set { box.value = newValue }
    }

    /// A SwiftUI binding to the value.
    var projectedValue: Binding<T> {
        Binding(get: { self.box.value }, set: { self.box.value = $0 })
    }

    /// Initializes the property wrapper.
    /// - Parameters:
    ///   - key: The key to use for UserDefaults.
    ///   - defaultValue: The default value if no value is stored.
    ///   - container: The UserDefaults instance to use (default: .standard).
    init(_ key: Key, default defaultValue: T, container: UserDefaults = .standard) {
        self.box = UserDefaultBox(key: key.keyString, defaultValue: defaultValue, container: container)
    }
}

public extension UserDefaults {
    /// Increments an integer counter for the given key in UserDefaults.
    /// - Parameter key: The key for the counter.
    func incrementCounter(for key: UserDefaultKeyProtocol) {
        let currentValue = self.integer(forKey: key.keyString)
        self.set(currentValue + 1, forKey: key.keyString)
    }

    /// Decrements an integer counter for the given key in UserDefaults.
    /// - Parameter key: The key for the counter.
    func decrementCounter(for key: UserDefaultKeyProtocol) {
        let currentValue = self.integer(forKey: key.keyString)
        self.set(currentValue - 1, forKey: key.keyString)
    }
}