import Foundation

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