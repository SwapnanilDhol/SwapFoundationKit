/*****************************************************************************
 * AppLinkOpener.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/
 
import Foundation
import CoreLocation

#if canImport(UIKit) && os(iOS)
import UIKit
#endif

/// Utility for opening app links, URLs, and map locations in iOS apps.
///
/// Provides static methods to open URLs, strings, and map coordinates in Apple Maps or Google Maps,
/// as well as constructing App Store and review URLs.
public enum AppLinkOpener {
    #if canImport(UIKit) && os(iOS)
    /// Opens a URL using UIApplication. Logs an error if the URL is nil.
    /// - Parameter url: The URL to open.
    @MainActor
    public static func open(url: URL?) {
        guard let url else {
            Logger.error("Attempted to open \(url?.absoluteString ?? "") but it was not a valid URL")
            return
        }
        UIApplication.shared.open(url, options: [:])
    }

    /// Opens a URL from a string using UIApplication. Logs an error if the string is not a valid URL.
    /// - Parameter string: The string to convert to a URL and open.
    @MainActor
    public static func open(string: String?) {
        guard let string, let url = URL(string: string) else {
            Logger.error("Attempted to open \(string ?? "") but it was not a valid URL")
            return
        }
        UIApplication.shared.open(url, options: [:])
    }

    /// Opens Apple Maps at the specified coordinates.
    /// - Parameter coordinates: The coordinates to open in Apple Maps.
    @MainActor
    public static func open(coordinates: CLLocationCoordinate2D) {
        let url = appleMapsURL(for: coordinates)
        open(url: url)
    }

    /// Opens the App Store page for the given app ID.
    /// - Parameter appID: The App Store app identifier.
    @MainActor
    public static func openAppStorePage(appID: String) {
        let url = appStoreURL(for: appID)
        open(url: url)
    }

    /// Opens the App Store review page for the given app ID.
    /// - Parameter appID: The App Store app identifier.
    @MainActor
    public static func openAppReviewPage(appID: String) {
        let url = appReviewURL(for: appID)
        open(url: url)
    }
    #endif

    // MARK: - URL Constructors

    /// Constructs an Apple Maps URL for the given coordinates.
    /// - Parameter coordinates: The coordinates to use.
    /// - Returns: A URL to open Apple Maps at the specified location.
    private static func appleMapsURL(for coordinates: CLLocationCoordinate2D) -> URL? {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "maps.apple.com"
        urlComponents.path = "/"
        urlComponents.queryItems = [
            URLQueryItem(name: "ll", value: "\(coordinates.latitude),\(coordinates.longitude)")
        ]
        return urlComponents.url
    }

    /// Constructs a Google Maps URL for the given coordinates.
    /// - Parameter coordinates: The coordinates to use.
    /// - Returns: A URL to open Google Maps at the specified location.
    private static func googleMapsURL(for coordinates: CLLocationCoordinate2D) -> URL? {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "maps.google.com"
        urlComponents.path = "/maps"
        urlComponents.queryItems = [
            URLQueryItem(name: "ll", value: "\(coordinates.latitude),\(coordinates.longitude)"),
            URLQueryItem(name: "q", value: ""),
        ]
        return urlComponents.url
    }

    /// Constructs an App Store review URL for the given app ID.
    /// - Parameter appID: The App Store app identifier.
    /// - Returns: A URL to the app's review page in the App Store.
    private static func appReviewURL(for appID: String) -> URL? {
        var urlComponents = URLComponents()
        urlComponents.scheme = "itms-apps"
        urlComponents.host = "itunes.apple.com"
        urlComponents.path = "/us/app/id\(appID)"
        urlComponents.queryItems = [
            URLQueryItem(name: "mt", value: "8"),
            URLQueryItem(name: "action", value: "write-review"),
        ]
        return urlComponents.url
    }

    /// Constructs an App Store URL for the given app ID.
    /// - Parameter appID: The App Store app identifier.
    /// - Returns: A URL to the app's page in the App Store.
    private static func appStoreURL(for appID: String) -> URL? {
        var urlComponents = URLComponents()
        urlComponents.scheme = "itms-apps"
        urlComponents.host = "itunes.apple.com"
        urlComponents.path = "/us/app/id\(appID)"
        return urlComponents.url
    }
}