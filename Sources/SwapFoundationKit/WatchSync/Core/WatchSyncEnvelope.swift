/*****************************************************************************
 * WatchSyncEnvelope.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import Foundation

/// Canonical payload envelope for Watch data sync.
public struct WatchSyncEnvelope: Codable, Sendable {
    public let identifier: String
    public let payload: Data
    public let version: Int
    public let timestamp: Date

    public init(
        identifier: String,
        payload: Data,
        version: Int = 1,
        timestamp: Date = Date()
    ) {
        self.identifier = identifier
        self.payload = payload
        self.version = version
        self.timestamp = timestamp
    }

    public static func make<T: SyncableData>(
        _ value: T,
        encoder: JSONEncoder = JSONEncoder()
    ) throws -> WatchSyncEnvelope {
        let encoded = try encoder.encode(value)
        return WatchSyncEnvelope(
            identifier: T.syncIdentifier,
            payload: encoded
        )
    }

    public func decodePayload<T: SyncableData>(
        _ type: T.Type,
        decoder: JSONDecoder = JSONDecoder()
    ) throws -> T {
        guard identifier == T.syncIdentifier else {
            throw WatchSyncError.identifierMismatch(expected: T.syncIdentifier, received: identifier)
        }
        do {
            return try decoder.decode(T.self, from: payload)
        } catch {
            throw WatchSyncError.payloadDecodingFailed(error)
        }
    }
}
