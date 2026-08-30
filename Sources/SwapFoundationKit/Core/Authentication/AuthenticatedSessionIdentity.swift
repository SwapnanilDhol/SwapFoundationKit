/****************************************************************************
 * AuthenticatedSessionIdentity.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import Foundation

/// The host-owned source of the current account identity.
public protocol AuthenticatedSessionIdentityProviding: Sendable {
    var identity: String { get }
}
