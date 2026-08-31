/****************************************************************************
 * AuthenticatedSessionStorageKeys.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import Foundation

/// Namespaced Keychain identifiers for one app/environment/backend-origin triple.
public struct AuthenticatedSessionStorageKeys: Sendable, Equatable {
    public let session: String
    public let enrollment: String
    public let binding: String
    public let pendingEnrollment: String
    public let appAttestKeyID: String

    public init(
        session: String,
        enrollment: String,
        binding: String,
        pendingEnrollment: String,
        appAttestKeyID: String
    ) {
        self.session = session
        self.enrollment = enrollment
        self.binding = binding
        self.pendingEnrollment = pendingEnrollment
        self.appAttestKeyID = appAttestKeyID
    }
}
