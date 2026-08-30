/****************************************************************************
 * AuthenticatedSessionStorage.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import Foundation

/// Device-only persistence for session, enrollment and binding state.
public protocol AuthenticatedSessionStorage: Sendable {
    func loadData(forKey key: String) throws -> Data?
    func storeData(_ data: Data, forKey key: String) throws
    func removeData(forKey key: String) throws
    func loadLegacyData(forKey key: String) throws -> Data?
}

public extension AuthenticatedSessionStorage {
    func loadLegacyData(forKey key: String) throws -> Data? {
        try loadData(forKey: key)
    }
}
