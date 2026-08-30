/****************************************************************************
 * AuthenticatedOrigin.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import Foundation

public struct AuthenticatedOrigin: Hashable, Sendable {
    public let scheme: String
    public let host: String
    public let port: Int?

    public init(scheme: String = "https", host: String, port: Int? = nil) {
        self.scheme = scheme.lowercased()
        self.host = host.lowercased()
        self.port = port
    }

    public init?(url: URL) {
        guard let scheme = url.scheme, let host = url.host else { return nil }
        self.init(scheme: scheme, host: host, port: url.port)
    }
}
