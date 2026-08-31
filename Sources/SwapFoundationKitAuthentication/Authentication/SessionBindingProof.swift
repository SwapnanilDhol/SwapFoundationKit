/****************************************************************************
 * SessionBindingProof.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import CryptoKit
import Foundation

/// An opaque, in-memory proof the host asks the server to bind to the current session.
///
/// The engine forwards `encodedPayload` untouched and persists only `fingerprint`,
/// so no purchase document ever reaches secure storage or logs.
public struct SessionBindingProof: Sendable, Equatable {
    public let identity: String
    public let fingerprint: String
    public let encodedPayload: Data

    public init(identity: String, fingerprint: String, encodedPayload: Data) {
        self.identity = identity.trimmingCharacters(in: .whitespacesAndNewlines)
        self.fingerprint = fingerprint
        self.encodedPayload = encodedPayload
    }

    /// Builds a stable deduplication fingerprint that cannot collapse adjacent parts.
    public static func fingerprint(parts: [String]) -> String {
        let data = (try? JSONEncoder().encode(parts)) ?? Data()
        return SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }
}
