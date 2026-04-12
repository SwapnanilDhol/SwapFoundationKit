/*****************************************************************************
 * DeeplinkEvent.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import Foundation

/// Represents a deeplink event received by the app.
///
/// Contains the parsed route (if any) and the original URL along with
/// metadata about how the deeplink was received.
public struct DeeplinkEvent: Hashable {
    /// The parsed route, or nil if no registered route matched the URL.
    /// Use this for type-safe navigation when routes are defined.
    public let route: (any DeeplinkRoute)?

    /// The original URL that triggered this deeplink event.
    /// Always available, even when `route` is nil.
    public let url: URL

    /// How the deeplink was received by the app.
    public let source: Source

    /// Describes how the app received this deeplink.
    public enum Source: Hashable {
        /// App was cold launched via a deeplink (from home screen)
        case coldLaunch

        /// App was already running and was resumed via a deeplink
        case resume

        /// Received via universal link (userActivity with browsingWeb type)
        case universalLink

        /// Received via Handoff or other NSUserActivity
        case handoff
    }

    /// Creates a new deeplink event.
    /// - Parameters:
    ///   - route: The parsed route, or nil if no registered route matched
    ///   - url: The original URL
    ///   - source: How the deeplink was received
    public init(route: (any DeeplinkRoute)?, url: URL, source: Source) {
        self.route = route
        self.url = url
        self.source = source
    }

    // MARK: - Hashable

    public static func == (lhs: DeeplinkEvent, rhs: DeeplinkEvent) -> Bool {
        lhs.url == rhs.url && lhs.source == rhs.source
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(url)
        hasher.combine(source)
    }
}
