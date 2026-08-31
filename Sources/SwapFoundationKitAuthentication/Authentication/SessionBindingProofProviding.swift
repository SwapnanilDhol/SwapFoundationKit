/****************************************************************************
 * SessionBindingProofProviding.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import Foundation

/// The host-owned source of a verified proof to bind to the current session.
public protocol SessionBindingProofProviding: Sendable {
    func currentProof() async throws -> SessionBindingProof
}
