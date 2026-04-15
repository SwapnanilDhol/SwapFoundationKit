/*****************************************************************************
 * WatchSyncTransport.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import Foundation

/// Supported WatchConnectivity payload delivery transports.
public enum WatchSyncTransport: String, Codable, Sendable {
    case applicationContext
    case userInfo
    case messageData
    case file
}
