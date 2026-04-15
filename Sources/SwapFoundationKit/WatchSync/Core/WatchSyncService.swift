/*****************************************************************************
 * WatchSyncService.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import Foundation
import Combine

/// Abstraction for type-safe data sync over WatchConnectivity.
public protocol WatchSyncService {
    /// Activates connectivity and starts listening for inbound payloads.
    func activate()

    /// Sends an item over Watch connectivity using configured transport strategy.
    func send<T: SyncableData>(_ value: T) async throws

    /// Sends a pre-encoded envelope over Watch connectivity.
    func sendEnvelope(_ envelope: WatchSyncEnvelope) async throws

    /// Emits all successfully decoded envelopes.
    var envelopePublisher: AnyPublisher<WatchSyncEnvelope, Never> { get }

    /// Emits operational watch sync events.
    var eventPublisher: AnyPublisher<WatchSyncEvent, Never> { get }

    /// Emits decoded values for the requested type.
    func publisher<T: SyncableData>(for type: T.Type) -> AnyPublisher<T, Never>
}
