/*****************************************************************************
 * WatchSyncError.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import Foundation

public enum WatchSyncError: LocalizedError {
    case identifierMismatch(expected: String, received: String)
    case payloadEncodingFailed(Error)
    case payloadDecodingFailed(Error)
    case envelopeDecodingFailed(Error)
    case transportFailed(Error)

    public var errorDescription: String? {
        switch self {
        case .identifierMismatch(let expected, let received):
            return "Watch sync identifier mismatch. Expected: \(expected), received: \(received)"
        case .payloadEncodingFailed(let error):
            return "Watch sync payload encoding failed: \(error.localizedDescription)"
        case .payloadDecodingFailed(let error):
            return "Watch sync payload decoding failed: \(error.localizedDescription)"
        case .envelopeDecodingFailed(let error):
            return "Watch sync envelope decoding failed: \(error.localizedDescription)"
        case .transportFailed(let error):
            return "Watch sync transport failed: \(error.localizedDescription)"
        }
    }
}
