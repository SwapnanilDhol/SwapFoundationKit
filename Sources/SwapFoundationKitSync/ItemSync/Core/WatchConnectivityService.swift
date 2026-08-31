/*****************************************************************************
 * WatchConnectivityService.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import Foundation
import Combine

/// Internal transport seam used by the canonical `WatchSyncService` implementation.
///
/// Watch transport details are deliberately kept inside the Sync product. Consumers
/// depend on `WatchSyncService`, rather than on a second connectivity abstraction.
internal protocol WatchConnectivityAdapter {
    /// Activates the Watch connectivity session
    func activate()
    
    /// Checks if the Watch is reachable
    var isReachable: Bool { get }
    
    /// Sends data to the Watch.
    /// - Parameters:
    ///   - data: Payload bytes
    ///   - preferredTransport: Preferred delivery strategy
    ///   - fallbackTransports: Fallback transports when preferred send is not available
    ///   - maxInlinePayloadBytes: Payload size threshold used to prefer file transport
    /// - Throws: WatchConnectivityError if the operation fails
    func sendData(
        _ data: Data,
        preferredTransport: WatchSyncTransport,
        fallbackTransports: [WatchSyncTransport],
        maxInlinePayloadBytes: Int
    ) throws
    
    /// Publisher that emits normalized payloads received from the Watch.
    var payloadReceivedPublisher: AnyPublisher<WatchConnectivityPayload, Never> { get }

    /// Backward-compatible publisher emitting just payload data.
    var dataReceivedPublisher: AnyPublisher<Data, Never> { get }
}

internal struct WatchConnectivityPayload: Sendable {
    let data: Data
    let transport: WatchSyncTransport

    init(data: Data, transport: WatchSyncTransport) {
        self.data = data
        self.transport = transport
    }
}

// MARK: - Errors

/// Errors that can occur during Watch connectivity operations.
internal enum WatchConnectivityError: LocalizedError {
    case sessionNotActivated
    case watchNotReachable
    case sendFailed(Error)
    case receiveFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .sessionNotActivated:
            return "Watch connectivity session is not activated"
        case .watchNotReachable:
            return "Watch is not reachable"
        case .sendFailed(let error):
            return "Failed to send data to Watch: \(error.localizedDescription)"
        case .receiveFailed(let error):
            return "Failed to receive data from Watch: \(error.localizedDescription)"
        }
    }
}
