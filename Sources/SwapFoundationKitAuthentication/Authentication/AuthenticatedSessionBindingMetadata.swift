/****************************************************************************
 * AuthenticatedSessionBindingMetadata.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import Foundation

/// Persisted description of a completed proof binding. The proof itself is never stored.
public struct AuthenticatedSessionBindingMetadata: Codable, Sendable, Equatable {
    public let keyID: String
    public let identity: String
    public let fingerprint: String

    public init(keyID: String, identity: String, fingerprint: String) {
        self.keyID = keyID
        self.identity = identity
        self.fingerprint = fingerprint
    }
}
