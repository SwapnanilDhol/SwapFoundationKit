/****************************************************************************
 * AuthenticatedSessionHTTPResponse.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import Foundation

/// A transport-agnostic HTTP result used by the authentication backend and client.
public struct AuthenticatedSessionHTTPResponse: Sendable {
    public let data: Data
    public let statusCode: Int
    public let retryAfter: TimeInterval?

    public init(data: Data, statusCode: Int, retryAfter: TimeInterval? = nil) {
        self.data = data
        self.statusCode = statusCode
        self.retryAfter = retryAfter
    }
}
