/****************************************************************************
 * KeychainAuthenticatedSessionStorage.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/
import Foundation
import Security

public final class KeychainAuthenticatedSessionStorage: AuthenticatedSessionStorage, @unchecked Sendable {
    private let security: SecurityService

    public init(security: SecurityService = SecurityService()) { self.security = security }

    public func loadData(forKey key: String) throws -> Data? {
        do { return try security.retrieveFromKeychain(forKey: key) }
        catch let error as SecurityService.SecurityError where Self.isMissing(error) { return nil }
        catch { throw AuthenticatedSessionError.keychainFailure }
    }

    public func loadLegacyData(forKey key: String) throws -> Data? {
        try loadData(forKey: key)
    }

    public func storeData(_ data: Data, forKey key: String) throws {
        do { try security.storeInKeychain(data, forKey: key, accessibility: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly) }
        catch { throw AuthenticatedSessionError.keychainFailure }
    }

    public func removeData(forKey key: String) throws {
        do { try security.removeFromKeychain(forKey: key) }
        catch let error as SecurityService.SecurityError where Self.isMissing(error) { return }
        catch { throw AuthenticatedSessionError.keychainFailure }
    }

    private static func isMissing(_ error: SecurityService.SecurityError) -> Bool {
        if case .keychainError(errSecItemNotFound) = error { return true }
        return false
    }
}
