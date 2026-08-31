/****************************************************************************
 * AuthenticatedSessionSleeper.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import Foundation

/// Injectable delay used for operation deadlines and bounded backoff.
public protocol AuthenticatedSessionSleeper: Sendable {
    func sleep(seconds: TimeInterval) async throws
}
