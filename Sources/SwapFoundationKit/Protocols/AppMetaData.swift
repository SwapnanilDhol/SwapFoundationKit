import Foundation
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

/// App metadata containing information about the application
/// Provides sensible defaults from Bundle.main for common properties
public struct AppMetaData {
    
    // MARK: - Required Properties
    
    /// App group identifier for data sharing between app, widgets, and extensions
    public let appGroupIdentifier: String
    
    /// Unique app identifier
    public let appID: String
    
    /// App name
    public let appName: String
    
    /// App share description
    public let appShareDescription: String
    
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
    ///   - appGroupIdentifier: App group identifier (required)
    ///   - appID: App identifier (defaults to bundle identifier)
    ///   - appName: App name (defaults to bundle display name)
    ///   - appShareDescription: App share description (defaults to app name)
    ///   - appInstagramUrl: Instagram URL (optional)
    ///   - appTwitterUrl: Twitter URL (optional)
    ///   - appWebsiteUrl: Website URL (optional)
    ///   - appPrivacyPolicyUrl: Privacy policy URL (optional)
    ///   - appEULAUrl: EULA URL (optional)
    ///   - appSupportEmail: Support email (optional)
    ///   - developerWebsite: Developer website URL (optional)
    ///   - developerTwitterUrl: Developer Twitter URL (optional)
    public init(
        appGroupIdentifier: String,
        appID: String? = nil,
        appName: String? = nil,
        appShareDescription: String? = nil,
        appInstagramUrl: URL? = nil,
        appTwitterUrl: URL? = nil,
        appWebsiteUrl: URL? = nil,
        appPrivacyPolicyUrl: URL? = nil,
        appEULAUrl: URL? = nil,
        appSupportEmail: String? = nil,
        developerWebsite: URL? = nil,
        developerTwitterUrl: URL? = nil
    ) {
        self.appGroupIdentifier = appGroupIdentifier
        self.appID = appID ?? Bundle.main.bundleIdentifier
        self.appName = appName ?? Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "My App"
        self.appShareDescription = appShareDescription ?? self.appName
        self.appInstagramUrl = appInstagramUrl
        self.appTwitterUrl = appTwitterUrl
        self.appWebsiteUrl = appWebsiteUrl
        self.appPrivacyPolicyUrl = appPrivacyPolicyUrl
        self.appEULAUrl = appEULAUrl
        self.appSupportEmail = appSupportEmail
        self.developerWebsite = developerWebsite
        self.developerTwitterUrl = developerTwitterUrl
    }
}

// MARK: - App Store Utilities

extension AppMetaData {

    /// Opens the app's review page in the App Store
    public static func openAppReviewPage() {
        let reviewURL = "itms-apps:itunes.apple.com/us/app/apple-store/1480273650?mt=8&action=write-review"
        openLink(for: reviewURL)
    }

    /// Opens the app's product page in the App Store
    /// Uses the appID from the current app's metadata
    public static func openAppProductPage() {
        let productURL = "itms-apps:itunes.apple.com/us/app/apple-store/\(Bundle.main.bundleIdentifier)?mt=8"
        openLink(for: productURL)
    }

    /// Opens the developer's App Store page
    /// - Parameter developerID: The developer's Apple ID
    public static func openDeveloperPage(developerID: String) {
        let developerURL = "itms-apps:itunes.apple.com/developer/id\(developerID)?mt=8"
        openLink(for: developerURL)
    }

    /// Opens the app's privacy policy URL if available
    /// - Parameter fallbackURL: Optional fallback URL if no privacy policy URL is set
    public static func openPrivacyPolicy(fallbackURL: URL? = nil) {
        if let privacyURL = Bundle.main.infoDictionary?["NSPrivacyPolicyURL"] as? String,
           let url = URL(string: privacyURL) {
            openLink(for: url)
        } else if let fallback = fallbackURL {
            openLink(for: fallback)
        }
    }

    /// Opens the app's terms of service URL if available
    /// - Parameter fallbackURL: Optional fallback URL if no terms URL is set
    public static func openTermsOfService(fallbackURL: URL? = nil) {
        if let termsURL = Bundle.main.infoDictionary?["NSAppleTermsOfServiceURL"] as? String,
           let url = URL(string: termsURL) {
            openLink(for: url)
        } else if let fallback = fallbackURL {
            openLink(for: fallback)
        }
    }

    /// Creates a share activity for the app
    /// - Returns: Share text and URL for the app
    public static func createShareContent() -> (text: String, url: URL) {
        let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "My App"
        let shareText = "Check out \(appName)! Download it from the App Store."
        let appStoreURL = URL(string: "itms-apps:itunes.apple.com/us/app/apple-store/\(Bundle.main.bundleIdentifier)?mt=8")!
        return (shareText, appStoreURL)
    }

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

    /// Helper method to open URLs
    /// - Parameter url: URL string or URL object to open
    public static func openLink(for url: String) {
        if let url = URL(string: url) {
            openLink(for: url)
        }
    }

    /// Helper method to open URLs
    /// - Parameter url: URL object to open
    public static func openLink(for url: URL) {
        #if os(iOS)
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        #elseif os(macOS)
        NSWorkspace.shared.open(url)
        #endif
    }

    /// Opens the app's settings page
    public static func openAppSettings() {
        #if os(iOS)
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            openLink(for: settingsURL)
        }
        #endif
    }

    /// Opens the device's system settings
    public static func openSystemSettings() {
        #if os(iOS)
        if let settingsURL = URL(string: "App-Prefs:") {
            openLink(for: settingsURL)
        }
        #endif
    }

    /// Calls a phone number
    /// - Parameter phoneNumber: Phone number to call (without spaces or special characters)
    public static func callPhoneNumber(_ phoneNumber: String) {
        let cleanNumber = phoneNumber.replacingOccurrences(of: "[^0-9+]", with: "", options: .regularExpression)
        let telURL = "tel://\(cleanNumber)"
        openLink(for: telURL)
    }

    /// Sends an email
    /// - Parameter email: Email address to send to
    /// - Parameter subject: Optional email subject
    /// - Parameter body: Optional email body
    public static func sendEmail(to email: String, subject: String? = nil, body: String? = nil) {
        var mailURL = "mailto:\(email)"
        var queryItems: [String] = []

        if let subject = subject?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            queryItems.append("subject=\(subject)")
        }

        if let body = body?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            queryItems.append("body=\(body)")
        }

        if !queryItems.isEmpty {
            mailURL += "?" + queryItems.joined(separator: "&")
        }

        openLink(for: mailURL)
    }

    /// Opens a website URL
    /// - Parameter url: Website URL to open
    public static func openWebsite(_ url: URL) {
        openLink(for: url)
    }

    /// Opens a website URL string
    /// - Parameter urlString: Website URL string to open
    public static func openWebsite(_ urlString: String) {
        openLink(for: urlString)
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
            appInstagramUrl: instagramUrl,
            appTwitterUrl: twitterUrl,
            appWebsiteUrl: websiteUrl
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
            appWebsiteUrl: websiteUrl,
            appPrivacyPolicyUrl: privacyPolicyUrl,
            appEULAUrl: eulaUrl,
            appSupportEmail: supportEmail
        )
    }
}