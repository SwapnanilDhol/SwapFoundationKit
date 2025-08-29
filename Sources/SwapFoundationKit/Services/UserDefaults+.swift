//
//  UserDefaults+.swift
//  SwapFoundationKit
//
//  Created by Swapnanil Dhol  on 8/27/25.
//

import Foundation

public extension UserDefaults {

    func set(_ value: Any, for key: UserDefaultKeyProtocol) {
        self.set(value, forKey: key.keyString)
    }

    func bool(for key: UserDefaultKeyProtocol) -> Bool {
        return self.bool(forKey: key.keyString)
    }

    func data(for key: UserDefaultKeyProtocol) -> Data? {
        return self.data(forKey: key.keyString)
    }

    func string(for key: UserDefaultKeyProtocol) -> String? {
        return self.string(forKey: key.keyString)
    }

    func stringArray(for key: UserDefaultKeyProtocol) -> [String]? {
        return self.stringArray(forKey: key.keyString)
    }

    func integer(for key: UserDefaultKeyProtocol) -> Int? {
        return self.integer(forKey: key.keyString)
    }

    func float(for key: UserDefaultKeyProtocol) -> Float? {
        return self.float(forKey: key.keyString)
    }

    func double(for key: UserDefaultKeyProtocol) -> Double {
        return self.double(forKey: key.keyString)
    }

    func url(for key: UserDefaultKeyProtocol) -> URL? {
        return self.url(forKey: key.keyString)
    }

    func value(for key: UserDefaultKeyProtocol) -> Any? {
        return self.value(forKey: key.keyString)
    }

    func date(for key: UserDefaultKeyProtocol) -> Date? {
        self.value(for: key) as? Date
    }

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

import SwiftUI
@available(watchOS 7.0, *)
public extension AppStorage {

    init(wrappedValue: Value, _ key: UserDefaultKeyProtocol, store: UserDefaults? = nil) where Value == Bool {
        self.init(wrappedValue: wrappedValue, key.keyString, store: store)
    }

    init(wrappedValue: Value, _ key: UserDefaultKeyProtocol, store: UserDefaults? = nil) where Value == Int {
        self.init(wrappedValue: wrappedValue, key.keyString, store: store)
    }

    init(wrappedValue: Value, _ key: UserDefaultKeyProtocol, store: UserDefaults? = nil) where Value == Double {
        self.init(wrappedValue: wrappedValue, key.keyString, store: store)
    }

    init(wrappedValue: Value, _ key: UserDefaultKeyProtocol, store: UserDefaults? = nil) where Value == URL {
        self.init(wrappedValue: wrappedValue, key.keyString, store: store)
    }

    init(wrappedValue: Value, _ key: UserDefaultKeyProtocol, store: UserDefaults? = nil) where Value == String {
        self.init(wrappedValue: wrappedValue, key.keyString, store: store)
    }

    init(wrappedValue: Value, _ key: UserDefaultKeyProtocol, store: UserDefaults? = nil) where Value == Data {
        self.init(wrappedValue: wrappedValue, key.keyString, store: store)
    }
}
