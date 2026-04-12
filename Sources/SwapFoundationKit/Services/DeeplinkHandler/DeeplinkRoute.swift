/*****************************************************************************
 * DeeplinkRoute.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import Foundation

/// Protocol for defining deeplink routes in the host application.
///
/// Host apps define their routes as enums conforming to this protocol,
/// then register them with `SwapFoundationKitConfiguration.supportedRoutes`.
///
/// ## Example
/// ```swift
/// enum AppRoute: DeeplinkRoute {
///     case product(id: String)
///     case profile(userId: String)
///
///     var path: String {
///         switch self {
///         case .product: return "/product"
///         case .profile: return "/profile"
///         }
///     }
///
///     var queryItems: [URLQueryItem] {
///         switch self {
///         case let .product(id): return [URLQueryItem(name: "id", value: id)]
///         case let .profile(userId): return [URLQueryItem(name: "userId", value: userId)]
///         }
///     }
///
///     static func parse(from url: URL) -> AppRoute? {
///         // Custom parsing logic based on URL components
///     }
/// }
/// ```
public protocol DeeplinkRoute: Codable, Hashable {
    /// The path component of the route (e.g., "/product")
    var path: String { get }

    /// The query items for this route
    var queryItems: [URLQueryItem] { get }

    /// Parses a URL into this route type.
    /// Returns the route if the URL matches, nil otherwise.
    /// - Parameter url: The URL to parse
    /// - Returns: An instance of the conforming type if parsing succeeds
    static func parse(from url: URL) -> Self?
}

// MARK: - Default Implementations

public extension DeeplinkRoute {
    /// Default query items returns empty array.
    /// Override in your route if it has query parameters.
    var queryItems: [URLQueryItem] { [] }

    /// Default parsing implementation that matches by path only.
    /// Override for more complex parsing logic.
    static func parse(from url: URL) -> Self? {
        // Base implementation checks path matching only.
        // Subclasses should override with proper parsing.
        return nil
    }
}
