/****************************************************************************
 * AuthenticatedRequestPolicy.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import Foundation

/// Per-request authentication requirements. Strict mode is the default.
public struct AuthenticatedRequestPolicy: Sendable, Equatable {
    public let requireBinding: Bool
    public let compatibility: Bool

    public init(requireBinding: Bool = false, compatibility: Bool = false) {
        self.requireBinding = requireBinding
        self.compatibility = compatibility
    }

    public static let strict = AuthenticatedRequestPolicy()
    public static func compatibility(requireBinding: Bool = false) -> Self {
        Self(requireBinding: requireBinding, compatibility: true)
    }
}
