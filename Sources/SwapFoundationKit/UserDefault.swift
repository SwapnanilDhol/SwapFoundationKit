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

/// Protocol for UserDefault keys, allowing enums or other types to be used as keys.
public protocol UserDefaultKeyProtocol {
    var keyString: String { get }
}

/// Property wrapper for type-safe UserDefaults access using protocol-based keys.
@propertyWrapper
public struct UserDefault<T, Key: UserDefaultKeyProtocol> {
    let key: Key
    let defaultValue: T
    var container: UserDefaults = .standard

    public var wrappedValue: T {
        get { container.object(forKey: key.keyString) as? T ?? defaultValue }
        set { container.set(newValue, forKey: key.keyString) }
    }

    public init(_ key: Key, default defaultValue: T, container: UserDefaults = .standard) {
        self.key = key
        self.defaultValue = defaultValue
        self.container = container
    }
}
