import Foundation

/// Default implementation of AppMetaData protocol
/// Provides sensible defaults for common app metadata properties
/// 
/// ## Usage Example
/// ```swift
/// enum MyAppMetadata: AppMetaData {
///     // Only override what you need
///     static let appGroupIdentifier = "group.com.yourapp.widget"
///     static let appID = "com.yourapp"
///     static let appName = "My Awesome App"
///     
///     // Everything else uses sensible defaults
/// }
/// ```
public struct AppMetaDataImpl: AppMetaData {
    
    // MARK: - Required Properties (must be provided)
    
    /// App group identifier for data sharing between app, widgets, and extensions
    /// - Note: This must be provided by the implementing type
    public static var appGroupIdentifier: String {
        fatalError("appGroupIdentifier must be provided by implementing type")
    }
    
    /// Unique app identifier
    /// - Note: This must be provided by the implementing type
    public static var appID: String {
        fatalError("appID must be provided by implementing type")
    }
    
    /// App name
    /// - Note: This must be provided by the implementing type
    public static var appName: String {
        fatalError("appName must be provided by implementing type")
    }
    
    /// App share description
    /// - Note: This must be provided by the implementing type
    public static var appShareDescription: String {
        fatalError("appShareDescription must be provided by implementing type")
    }
    
    // MARK: - Optional Properties (with sensible defaults)
    
    /// App Instagram URL
    public static var appInstagramUrl: URL? { nil }
    
    /// App Twitter URL
    public static var appTwitterUrl: URL? { nil }
    
    /// App website URL
    public static var appWebsiteUrl: URL? { nil }
    
    /// App privacy policy URL
    public static var appPrivacyPolicyUrl: URL? { nil }
    
    /// App EULA URL
    public static var appEULAUrl: URL? { nil }
    
    /// App support email
    public static var appSupportEmail: String? { nil }
    
    /// Developer website URL
    public static var appDeveloperWebsite: URL? { nil }
    
    /// Developer Twitter URL
    public static var appDeveloperTwitterUrl: URL? { nil }
}

// MARK: - Convenience Extensions

extension AppMetaDataImpl {
    
    /// Creates a basic app metadata implementation with minimal required properties
    /// - Parameters:
    ///   - appGroupIdentifier: App group identifier for data sharing
    ///   - appID: Unique app identifier
    ///   - appName: App name
    ///   - appShareDescription: App share description
    /// - Returns: Basic app metadata implementation
    public static func basic(
        appGroupIdentifier: String,
        appID: String,
        appName: String,
        appShareDescription: String
    ) -> BasicAppMetadata {
        return BasicAppMetadata(
            appGroupIdentifier: appGroupIdentifier,
            appID: appID,
            appName: appName,
            appShareDescription: appShareDescription
        )
    }
    
    /// Creates a social media focused app metadata implementation
    /// - Parameters:
    ///   - appGroupIdentifier: App group identifier for data sharing
    ///   - appID: Unique app identifier
    ///   - appName: App name
    ///   - appShareDescription: App share description
    ///   - instagramUrl: Instagram URL
    ///   - twitterUrl: Twitter URL
    ///   - websiteUrl: Website URL
    /// - Returns: Social media focused app metadata implementation
    public static func social(
        appGroupIdentifier: String,
        appID: String,
        appName: String,
        appShareDescription: String,
        instagramUrl: URL? = nil,
        twitterUrl: URL? = nil,
        websiteUrl: URL? = nil
    ) -> SocialAppMetadata {
        return SocialAppMetadata(
            appGroupIdentifier: appGroupIdentifier,
            appID: appID,
            appName: appName,
            appShareDescription: appShareDescription,
            instagramUrl: instagramUrl,
            twitterUrl: twitterUrl,
            websiteUrl: websiteUrl
        )
    }
    
    /// Creates a business-focused app metadata implementation
    /// - Parameters:
    ///   - appGroupIdentifier: App group identifier for data sharing
    ///   - appID: Unique app identifier
    ///   - appName: App name
    ///   - appShareDescription: App share description
    ///   - websiteUrl: Website URL
    ///   - privacyPolicyUrl: Privacy policy URL
    ///   - eulaUrl: EULA URL
    ///   - supportEmail: Support email
    /// - Returns: Business-focused app metadata implementation
    public static func business(
        appGroupIdentifier: String,
        appID: String,
        appName: String,
        appShareDescription: String,
        websiteUrl: URL? = nil,
        privacyPolicyUrl: URL? = nil,
        eulaUrl: URL? = nil,
        supportEmail: String? = nil
    ) -> BusinessAppMetadata {
        return BusinessAppMetadata(
            appGroupIdentifier: appGroupIdentifier,
            appID: appID,
            appName: appName,
            appShareDescription: appShareDescription,
            websiteUrl: websiteUrl,
            privacyPolicyUrl: privacyPolicyUrl,
            eulaUrl: eulaUrl,
            supportEmail: supportEmail
        )
    }
}

// MARK: - Concrete Implementations

/// Basic app metadata with minimal required properties
public struct BasicAppMetadata: AppMetaData {
    public let appGroupIdentifier: String
    public let appID: String
    public let appName: String
    public let appShareDescription: String
    
    public init(
        appGroupIdentifier: String,
        appID: String,
        appName: String,
        appShareDescription: String
    ) {
        self.appGroupIdentifier = appGroupIdentifier
        self.appID = appID
        self.appName = appName
        self.appShareDescription = appShareDescription
    }
    
    // All other properties use default implementations from AppMetaData extension
}

/// Social media focused app metadata
public struct SocialAppMetadata: AppMetaData {
    public let appGroupIdentifier: String
    public let appID: String
    public let appName: String
    public let appShareDescription: String
    public let appInstagramUrl: URL?
    public let appTwitterUrl: URL?
    public let appWebsiteUrl: URL?
    
    public init(
        appGroupIdentifier: String,
        appID: String,
        appName: String,
        appShareDescription: String,
        instagramUrl: URL? = nil,
        twitterUrl: URL? = nil,
        websiteUrl: URL? = nil
    ) {
        self.appGroupIdentifier = appGroupIdentifier
        self.appID = appID
        self.appName = appName
        self.appShareDescription = appShareDescription
        self.appInstagramUrl = instagramUrl
        self.appTwitterUrl = twitterUrl
        self.appWebsiteUrl = websiteUrl
    }
    
    // All other properties use default implementations from AppMetaData extension
}

/// Business-focused app metadata
public struct BusinessAppMetadata: AppMetaData {
    public let appGroupIdentifier: String
    public let appID: String
    public let appName: String
    public let appShareDescription: String
    public let appWebsiteUrl: URL?
    public let appPrivacyPolicyUrl: URL?
    public let appEULAUrl: URL?
    public let appSupportEmail: String?
    
    public init(
        appGroupIdentifier: String,
        appID: String,
        appName: String,
        appShareDescription: String,
        websiteUrl: URL? = nil,
        privacyPolicyUrl: URL? = nil,
        eulaUrl: URL? = nil,
        supportEmail: String? = nil
    ) {
        self.appGroupIdentifier = appGroupIdentifier
        self.appID = appID
        self.appName = appName
        self.appShareDescription = appShareDescription
        self.appWebsiteUrl = websiteUrl
        self.appPrivacyPolicyUrl = privacyPolicyUrl
        self.appEULAUrl = eulaUrl
        self.appSupportEmail = supportEmail
    }
    
    // All other properties use default implementations from AppMetaData extension
}
