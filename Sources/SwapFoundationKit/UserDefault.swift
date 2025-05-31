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

public protocol UserDefaultKeyProtocol {
    var keyString: String { get }
}

@propertyWrapper
public struct UserDefault<T: Equatable, Key: UserDefaultKeyProtocol>: DynamicProperty {
    let key: Key
    let defaultValue: T
    var container: UserDefaults = .standard

    @State private var value: T

    public var wrappedValue: T {
        get { value }
        nonmutating set {
            if value != newValue {
                value = newValue
                container.set(newValue, forKey: key.keyString)
            }
        }
    }

    public var projectedValue: Binding<T> {
        Binding(
            get: { self.wrappedValue },
            set: { self.wrappedValue = $0 }
        )
    }

    public init(_ key: Key, default defaultValue: T, container: UserDefaults = .standard) {
        self.key = key
        self.defaultValue = defaultValue
        self.container = container
        let stored = container.object(forKey: key.keyString) as? T
        _value = State(initialValue: stored ?? defaultValue)
    }
}

public extension UserDefaults {

    func incrementCounter(for key: UserDefaultKeyProtocol) {
        let currentValue = self.integer(forKey: key.keyString)
        self.set(currentValue + 1, forKey: key.keyString)
    }

    func decrementCounter(for key: UserDefaultKeyProtocol) {
        let currentValue = self.integer(forKey: key.keyString)
        self.set(currentValue - 1, forKey: key.keyString)
    }
}