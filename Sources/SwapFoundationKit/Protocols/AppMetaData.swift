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
    var appGroupIdentifier: String { get }
    
    /// Bundle identifier of the app
    var bundleIdentifier: String { get }
    
    /// App version string
    var appVersion: String { get }
    
    /// Build number string
    var buildNumber: String { get }
    
    // MARK: - Existing Properties (for backward compatibility)
    
    /// Unique app identifier
    var appID: String { get }
    
    /// App name
    var appName: String { get }
    
    /// App share description
    var appShareDescription: String { get }
    
    /// App Instagram URL
    var appInstagramUrl: URL? { get }
    
    /// App Twitter URL
    var appTwitterUrl: URL? { get }
    
    /// App website URL
    var appWebsiteUrl: URL? { get }
    
    /// App privacy policy URL
    var appPrivacyPolicyUrl: URL? { get }
    
    /// App EULA URL
    var appEULAUrl: URL? { get }
    
    /// App support email
    var appSupportEmail: String? { get }
    
    /// Developer website URL
    var developerWebsite: URL? { get }
    
    /// Developer Twitter URL
    var developerTwitterUrl: URL? { get }
}

// MARK: - Default Implementations

public extension AppMetaData {
    
    /// Default implementation for bundle identifier using Bundle.main
    var bundleIdentifier: String {
        return Bundle.main.bundleIdentifier
    }
    
    /// Default implementation for app version using Bundle.main
    var appVersion: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    /// Default implementation for build number using Bundle.main
    var buildNumber: String {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    /// Default implementation for app name using Bundle.main
    var appName: String {
        return Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "My App"
    }
}
