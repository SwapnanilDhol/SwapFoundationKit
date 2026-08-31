/****************************************************************************
 * SystemAuthenticatedSessionClock.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import Foundation

public struct SystemAuthenticatedSessionClock: AuthenticatedSessionClock {
    public init() {}

    public var now: Date { Date() }
}
