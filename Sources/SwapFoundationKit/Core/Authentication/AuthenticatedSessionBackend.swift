/****************************************************************************
 * AuthenticatedSessionBackend.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/
import Foundation
public protocol AuthenticatedSessionBackend: Sendable {
    func challenge(purpose: String, identity: String, deadline: Date) async throws -> AuthenticatedSessionChallenge
    func enroll(challenge: AuthenticatedSessionChallenge, keyID: String, attestationObject: Data, identity: String, deadline: Date) async throws
    func issueSession(challenge: AuthenticatedSessionChallenge, keyID: String, assertion: Data, identity: String, deadline: Date) async throws -> AuthenticatedSessionCredential
    func bind(proof: SessionBindingProof, credential: AuthenticatedSessionCredential, identity: String, deadline: Date) async throws
}
