/****************************************************************************
 * AuthenticatedSessionClock.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import Foundation

/// Injectable time source so expiry and cooldown rules stay testable.
public protocol AuthenticatedSessionClock: Sendable {
    var now: Date { get }
}
