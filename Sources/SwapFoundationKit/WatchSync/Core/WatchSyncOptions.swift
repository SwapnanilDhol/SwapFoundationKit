/*****************************************************************************
 * WatchSyncOptions.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import Foundation

/// Options controlling Watch sync transport strategy and compatibility behavior.
public struct WatchSyncOptions: Sendable {
    public let preferredTransport: WatchSyncTransport
    public let fallbackOrder: [WatchSyncTransport]
    public let maxInlinePayloadBytes: Int
    public let enableLegacyPayloadDecoding: Bool

    public init(
        preferredTransport: WatchSyncTransport = .applicationContext,
        fallbackOrder: [WatchSyncTransport] = [.userInfo, .messageData, .file],
        maxInlinePayloadBytes: Int = 50_000,
        enableLegacyPayloadDecoding: Bool = true
    ) {
        self.preferredTransport = preferredTransport
        self.fallbackOrder = fallbackOrder
        self.maxInlinePayloadBytes = maxInlinePayloadBytes
        self.enableLegacyPayloadDecoding = enableLegacyPayloadDecoding
    }

    public static let `default` = WatchSyncOptions()
}
