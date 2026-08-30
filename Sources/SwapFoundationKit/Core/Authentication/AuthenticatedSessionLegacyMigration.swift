/****************************************************************************
 * AuthenticatedSessionLegacyMigration.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/
import Foundation

public struct AuthenticatedSessionLegacyMigration: Sendable {
    public let decodeSession: (@Sendable (Data) throws -> AuthenticatedSessionCredential?)?
    public let decodeBinding: (@Sendable (Data) throws -> AuthenticatedSessionBindingMetadata?)?
    public let decodeEnrollment: (@Sendable (Data) throws -> Bool?)?

    public init(
        decodeSession: (@Sendable (Data) throws -> AuthenticatedSessionCredential?)? = nil,
        decodeBinding: (@Sendable (Data) throws -> AuthenticatedSessionBindingMetadata?)? = nil,
        decodeEnrollment: (@Sendable (Data) throws -> Bool?)? = nil
    ) {
        self.decodeSession = decodeSession
        self.decodeBinding = decodeBinding
        self.decodeEnrollment = decodeEnrollment
    }
}
