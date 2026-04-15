/*****************************************************************************
 * WatchSyncEvent.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import Foundation

public enum WatchSyncEvent: Sendable {
    case activated
    case sent(identifier: String, transport: WatchSyncTransport)
    case received(identifier: String, transport: WatchSyncTransport)
    case error(String)
}
