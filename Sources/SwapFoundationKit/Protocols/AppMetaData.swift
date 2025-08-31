/*****************************************************************************
 * AppMetaData.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import Foundation

public protocol AppMetaData {
    // MARK: - Required Properties for Configuration
    
    /// App group identifier for data sharing between app, widgets, and extensions
    static var appGroupIdentifier: String { get }
    
    /// Bundle identifier of the app
    static var bundleIdentifier: String { get }
    
    /// App version string
    static var appVersion: String { get }
    
    /// Build number string
    static var buildNumber: String { get }
    
    // MARK: - Existing Properties (for backward compatibility)
    
    /// Unique app identifier
    static var appID: String { get }
    
    /// App name
    static var appName: String { get }
    
    /// App share description
    static var appShareDescription: String { get }
    
    /// App Instagram URL
    static var appInstagramUrl: URL? { get }
    
    /// App Twitter URL
    static var appTwitterUrl: URL? { get }
    
    /// App website URL
    static var appWebsiteUrl: URL? { get }
    
    /// App privacy policy URL
    static var appPrivacyPolicyUrl: URL? { get }
    
    /// App EULA URL
    static var appEULAUrl: URL? { get }
    
    /// App support email
    static var appSupportEmail: String? { get }
    
    /// Developer website URL
    static var developerWebsite: URL? { get }
    
    /// Developer Twitter URL
    static var developerTwitterUrl: URL? { get }
}

// MARK: - Default Implementations

public extension AppMetaData {
    
    /// Default implementation for bundle identifier using Bundle.main
    static var bundleIdentifier: String {
        return Bundle.main.bundleIdentifier ?? "unknown"
    }
    
    /// Default implementation for app version using Bundle.main
    static var appVersion: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    /// Default implementation for build number using Bundle.main
    static var buildNumber: String {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    /// Default implementation for app name using Bundle.main
    static var appName: String {
        return Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "My App"
    }
}
