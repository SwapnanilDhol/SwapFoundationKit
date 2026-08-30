/****************************************************************************
 * AuthenticatedSessionHTTPTransport.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import Foundation

/// The single request primitive the authentication layer needs from a transport.
public protocol AuthenticatedSessionHTTPTransport: Sendable {
    func send(_ request: URLRequest) async throws -> AuthenticatedSessionHTTPResponse
}
