/****************************************************************************
 * AuthenticatedSessionCredential.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import Foundation

/// A bearer credential issued for one attested installation and identity.
public struct AuthenticatedSessionCredential: Codable, Sendable, Equatable {
    public let token: String
    public let expiresAt: Date
    public let keyID: String
    public let identity: String

    public init(token: String, expiresAt: Date, keyID: String, identity: String) {
        self.token = token
        self.expiresAt = expiresAt
        self.keyID = keyID
        self.identity = identity
    }

    /// Reports whether the credential is still valid with the configured refresh margin applied.
    public func isUsable(at now: Date, freshness: TimeInterval = 30) -> Bool {
        !token.isEmpty && expiresAt > now.addingTimeInterval(freshness)
    }
}
