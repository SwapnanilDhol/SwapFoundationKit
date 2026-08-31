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

/// App metadata containing information about the application
/// Provides sensible defaults from Bundle.main for common properties
public struct AppMetaData {

    /// Optional links and contact details associated with an app.
    /// Keeping these values together leaves the primary metadata initializer small.
    public struct Links: Sendable {
        public let instagramURL: URL?
        public let twitterURL: URL?
        public let websiteURL: URL?
        public let privacyPolicyURL: URL?
        public let eulaURL: URL?
        public let supportEmail: String?
        public let developerWebsiteURL: URL?
        public let developerTwitterURL: URL?

        public init(
            instagramURL: URL? = nil,
            twitterURL: URL? = nil,
            websiteURL: URL? = nil,
            privacyPolicyURL: URL? = nil,
            eulaURL: URL? = nil,
            supportEmail: String? = nil,
            developerWebsiteURL: URL? = nil,
            developerTwitterURL: URL? = nil
        ) {
            self.instagramURL = instagramURL
            self.twitterURL = twitterURL
            self.websiteURL = websiteURL
            self.privacyPolicyURL = privacyPolicyURL
            self.eulaURL = eulaURL
            self.supportEmail = supportEmail
            self.developerWebsiteURL = developerWebsiteURL
            self.developerTwitterURL = developerTwitterURL
        }
    }
    
    // MARK: - Required Properties
    
    /// App group identifier for data sharing between app, widgets, and extensions
    public let appGroupIdentifier: String
    
    /// Unique app identifier
    public let appID: String
    
    /// App name
    public let appName: String
    
    /// App share description
    public let appShareDescription: String

    /// Optional links and contact details supplied at initialization.
    public let links: Links
    
    // MARK: - Optional Properties
    
    /// App Instagram URL
    public let appInstagramUrl: URL?
    
    /// App Twitter URL
    public let appTwitterUrl: URL?
    
    /// App website URL
    public let appWebsiteUrl: URL?
    
    /// App privacy policy URL
    public let appPrivacyPolicyUrl: URL?
    
    /// App EULA URL
    public let appEULAUrl: URL?
    
    /// App support email
    public let appSupportEmail: String?
    
    /// Developer website URL
    public let developerWebsite: URL?
    
    /// Developer Twitter URL
    public let developerTwitterUrl: URL?
    
    // MARK: - Computed Properties (from Bundle)
    
    /// Bundle identifier of the app (from Bundle.main)
    public var bundleIdentifier: String {
        return Bundle.main.bundleIdentifier
    }
    
    /// App version string (from Bundle.main)
    public var appVersion: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    /// Build number string (from Bundle.main)
    public var buildNumber: String {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    // MARK: - Initialization
    
    /// Creates a new AppMetaData instance
    /// - Parameters:
    ///   - appGroupIdentifier: App group identifier (empty when unused)
    ///   - appID: App identifier (defaults to bundle identifier)
    ///   - appName: App name (defaults to bundle display name)
    ///   - appShareDescription: App share description (defaults to app name)
    ///   - links: Optional URLs and contact information grouped in `Links`.
    public init(
        appGroupIdentifier: String = "",
        appID: String? = nil,
        appName: String? = nil,
        appShareDescription: String? = nil,
        links: Links = Links()
    ) {
        self.appGroupIdentifier = appGroupIdentifier
        self.appID = appID ?? Bundle.main.bundleIdentifier
        self.appName = appName ?? Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "My App"
        self.appShareDescription = appShareDescription ?? self.appName
        self.links = links
        self.appInstagramUrl = links.instagramURL
        self.appTwitterUrl = links.twitterURL
        self.appWebsiteUrl = links.websiteURL
        self.appPrivacyPolicyUrl = links.privacyPolicyURL
        self.appEULAUrl = links.eulaURL
        self.appSupportEmail = links.supportEmail
        self.developerWebsite = links.developerWebsiteURL
        self.developerTwitterUrl = links.developerTwitterURL
    }
}

// MARK: - Bundle data

extension AppMetaData {

    /// Gets the app's current version string
    public static var currentVersion: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    /// Gets the app's current build number
    public static var currentBuild: String {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    /// Checks if the app is running from TestFlight
    public static var isRunningFromTestFlight: Bool {
        return Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
    }

    /// Gets the app's display name
    public static var displayName: String {
        return Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "My App"
    }

    /// Gets the app's bundle identifier
    public static var bundleID: String {
        return Bundle.main.bundleIdentifier
    }

    /// Creates share text and the app's App Store URL without opening anything.
    public static func createShareContent() -> (text: String, url: URL) {
        let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String
            ?? Bundle.main.infoDictionary?["CFBundleName"] as? String
            ?? "My App"
        let shareText = "Check out \(appName)! Download it from the App Store."
        let appStoreURL = URL(string: "itms-apps:itunes.apple.com/us/app/apple-store/\(bundleID)?mt=8")!
        return (shareText, appStoreURL)
    }

}

// MARK: - Convenience Initializers

extension AppMetaData {
    
    /// Creates a basic AppMetaData with minimal required parameters
    /// - Parameter appGroupIdentifier: App group identifier
    /// - Returns: AppMetaData with sensible defaults from bundle
    public static func basic(appGroupIdentifier: String) -> AppMetaData {
        return AppMetaData(appGroupIdentifier: appGroupIdentifier)
    }
    
    /// Creates a social media focused AppMetaData
    /// - Parameters:
    ///   - appGroupIdentifier: App group identifier
    ///   - instagramUrl: Instagram URL
    ///   - twitterUrl: Twitter URL
    ///   - websiteUrl: Website URL
    /// - Returns: AppMetaData configured for social media apps
    public static func social(
        appGroupIdentifier: String,
        instagramUrl: URL? = nil,
        twitterUrl: URL? = nil,
        websiteUrl: URL? = nil
    ) -> AppMetaData {
        return AppMetaData(
            appGroupIdentifier: appGroupIdentifier,
            links: Links(
                instagramURL: instagramUrl,
                twitterURL: twitterUrl,
                websiteURL: websiteUrl
            )
        )
    }
    
    /// Creates a business focused AppMetaData
    /// - Parameters:
    ///   - appGroupIdentifier: App group identifier
    ///   - websiteUrl: Website URL
    ///   - privacyPolicyUrl: Privacy policy URL
    ///   - eulaUrl: EULA URL
    ///   - supportEmail: Support email
    /// - Returns: AppMetaData configured for business apps
    public static func business(
        appGroupIdentifier: String,
        websiteUrl: URL? = nil,
        privacyPolicyUrl: URL? = nil,
        eulaUrl: URL? = nil,
        supportEmail: String? = nil
    ) -> AppMetaData {
        return AppMetaData(
            appGroupIdentifier: appGroupIdentifier,
            links: Links(
                websiteURL: websiteUrl,
                privacyPolicyURL: privacyPolicyUrl,
                eulaURL: eulaUrl,
                supportEmail: supportEmail
            )
        )
    }
}
