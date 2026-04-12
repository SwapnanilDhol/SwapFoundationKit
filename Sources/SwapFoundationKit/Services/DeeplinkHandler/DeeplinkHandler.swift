/*****************************************************************************
 * DeeplinkHandler.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import Foundation
import Combine

#if canImport(UIKit) && os(iOS)
import UIKit
#endif

// MARK: - DeeplinkHandler Protocol

/// Protocol for handling deeplinks in the application.
///
/// Implement this protocol to create a custom deeplink handler,
/// or use the default `DefaultDeeplinkHandler` implementation.
public protocol DeeplinkHandler: AnyObject {
    /// Publisher that emits deeplink events.
    /// Subscribe to this to receive deeplink callbacks in your app.
    var deeplinkPublisher: AnyPublisher<DeeplinkEvent, Never> { get }

    /// Handles a deeplink URL from `openURL` sources.
    /// - Parameters:
    ///   - url: The URL to handle
    ///   - source: The source/context of the deeplink
    /// - Returns: True if the URL was handled (matched a route), false otherwise
    @discardableResult
    func handle(url: URL?, source: DeeplinkEvent.Source) -> Bool

    /// Handles a user activity from `continueUserActivity`.
    /// - Parameter userActivity: The user activity to handle
    /// - Returns: True if the activity was handled, false otherwise
    @discardableResult
    func handle(userActivity: NSUserActivity) -> Bool
}

// MARK: - DefaultDeeplinkHandler

/// Default implementation of `DeeplinkHandler`.
///
/// This class handles:
/// - Custom scheme deeplinks (e.g., `myapp://product/123`)
/// - Universal links (e.g., `https://mysite.com/product/123`)
/// - Handoff activities
///
/// ## Setup
/// Configure routes in `SwapFoundationKitConfiguration.supportedRoutes`:
/// ```swift
/// let config = SwapFoundationKitConfiguration(
///     appMetadata: myAppMeta,
///     supportedRoutes: [AppRoute.self]
/// )
/// ```
///
/// ## Scene Delegate Integration
/// Call the handler methods from your SceneDelegate:
/// ```swift
/// func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
///     if let url = connectionOptions.urlContexts.first?.url {
///         SwapFoundationKit.shared.deeplinkHandler?.handle(url: url, source: .coldLaunch)
///     }
///     if let userActivity = connectionOptions.userActivities.first {
///         SwapFoundationKit.shared.deeplinkHandler?.handle(userActivity: userActivity)
///     }
/// }
///
/// func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
///     if let url = URLContexts.first?.url {
///         SwapFoundationKit.shared.deeplinkHandler?.handle(url: url, source: .resume)
///     }
/// }
///
/// func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
///     SwapFoundationKit.shared.deeplinkHandler?.handle(userActivity: userActivity)
/// }
/// ```
@MainActor
public final class DefaultDeeplinkHandler: NSObject, DeeplinkHandler {

    // MARK: - Singleton

    public static let shared = DefaultDeeplinkHandler()

    // MARK: - Properties

    private let subject = PassthroughSubject<DeeplinkEvent, Never>()
    private var supportedRoutes: [DeeplinkRoute.Type] = []

    // MARK: - DeeplinkHandler

    public var deeplinkPublisher: AnyPublisher<DeeplinkEvent, Never> {
        subject.eraseToAnyPublisher()
    }

    @discardableResult
    public func handle(url: URL?, source: DeeplinkEvent.Source) -> Bool {
        guard let url else { return false }

        let event = createEvent(for: url, source: source)
        subject.send(event)
        return event.route != nil
    }

    @discardableResult
    public func handle(userActivity: NSUserActivity) -> Bool {
        // Handle universal links
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb,
           let url = userActivity.webpageURL {
            let source: DeeplinkEvent.Source = .universalLink
            let event = createEvent(for: url, source: source)
            subject.send(event)
            return event.route != nil
        }

        // Handle Handoff and other user activities
        // Note: Only webpageURL is available for custom user activities
        // For Handoff, the URL is typically set via webpageURL
        if let url = userActivity.webpageURL {
            let source: DeeplinkEvent.Source = .handoff
            let event = createEvent(for: url, source: source)
            subject.send(event)
            return event.route != nil
        }

        return false
    }

    // MARK: - Configuration

    /// Configures the handler with supported route types.
    /// - Parameter routes: Array of route types to register
    public func configure(with routes: [DeeplinkRoute.Type]) {
        self.supportedRoutes = routes
    }

    // MARK: - Private

    private func createEvent(for url: URL, source: DeeplinkEvent.Source) -> DeeplinkEvent {
        // Try to parse the URL into a registered route
        for routeType in supportedRoutes {
            if let route = routeType.parse(from: url) {
                return DeeplinkEvent(route: route, url: url, source: source)
            }
        }

        // No matching route found - still emit event with nil route
        // Host app can handle this via the raw URL
        return DeeplinkEvent(route: nil, url: url, source: source)
    }
}
