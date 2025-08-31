import Foundation

/// Configuration struct for SwapFoundationKit framework
/// Contains all necessary settings for initializing and configuring the framework
public struct SwapFoundationKitConfiguration {
    
    // MARK: - App Group & Sharing
    
    /// App group identifier for sharing data between app, widgets, and extensions
    public let appGroupIdentifier: String
    
    // MARK: - App Metadata
    
    /// App metadata containing app information
    public let appMetadata: AppMetaData
    
    // MARK: - Service Flags
    
    /// Whether to enable Watch connectivity features
    public let enableWatchConnectivity: Bool
    
    /// Whether to enable analytics services
    public let enableAnalytics: Bool
    
    /// Whether to enable item synchronization services
    public let enableItemSync: Bool
    
    // MARK: - Network & Security
    
    /// Network timeout interval in seconds
    public let networkTimeout: TimeInterval
    
    /// Whether to enable certificate pinning for network requests
    public let enableCertificatePinning: Bool
    
    // MARK: - Custom Services
    
    /// Custom analytics logger implementation
    public let customAnalyticsLogger: AnalyticsLogger?
    
    /// Custom file storage service implementation
    public let customStorageService: FileStorageService?
    
    // MARK: - Initialization
    
    /// Creates a new configuration instance
    /// - Parameters:
    ///   - appGroupIdentifier: App group identifier for data sharing
    ///   - appMetadata: App metadata information
    ///   - enableWatchConnectivity: Whether to enable Watch connectivity
    ///   - enableAnalytics: Whether to enable analytics
    ///   - enableItemSync: Whether to enable item synchronization
    ///   - networkTimeout: Network timeout in seconds
    ///   - enableCertificatePinning: Whether to enable certificate pinning
    ///   - customAnalyticsLogger: Custom analytics logger
    ///   - customStorageService: Custom storage service
    public init(
        appGroupIdentifier: String,
        appMetadata: AppMetaData,
        enableWatchConnectivity: Bool = false,
        enableAnalytics: Bool = true,
        enableItemSync: Bool = true,
        networkTimeout: TimeInterval = 30.0,
        enableCertificatePinning: Bool = false,
        customAnalyticsLogger: AnalyticsLogger? = nil,
        customStorageService: FileStorageService? = nil
    ) {
        self.appGroupIdentifier = appGroupIdentifier
        self.appMetadata = appMetadata
        self.enableWatchConnectivity = enableWatchConnectivity
        self.enableAnalytics = enableAnalytics
        self.enableItemSync = enableItemSync
        self.networkTimeout = networkTimeout
        self.enableCertificatePinning = enableCertificatePinning
        self.customAnalyticsLogger = customAnalyticsLogger
        self.customStorageService = customStorageService
    }
}

// MARK: - Convenience Initializers

extension SwapFoundationKitConfiguration {
    
    /// Creates a basic configuration with minimal required parameters
    /// - Parameters:
    ///   - appGroupIdentifier: App group identifier
    ///   - appMetadata: App metadata
    /// - Returns: Configuration with default values
    public static func basic(
        appGroupIdentifier: String,
        appMetadata: AppMetaData
    ) -> SwapFoundationKitConfiguration {
        return SwapFoundationKitConfiguration(
            appGroupIdentifier: appGroupIdentifier,
            appMetadata: appMetadata
        )
    }
    
    /// Creates a configuration optimized for Watch apps
    /// - Parameters:
    ///   - appGroupIdentifier: App group identifier
    ///   - appMetadata: App metadata
    /// - Returns: Configuration with Watch-optimized settings
    public static func watchOptimized(
        appGroupIdentifier: String,
        appMetadata: AppMetaData
    ) -> SwapFoundationKitConfiguration {
        return SwapFoundationKitConfiguration(
            appGroupIdentifier: appGroupIdentifier,
            appMetadata: appMetadata,
            enableWatchConnectivity: true,
            enableAnalytics: false, // Watch apps typically don't need analytics
            enableItemSync: true,
            networkTimeout: 15.0, // Shorter timeout for Watch
            enableCertificatePinning: false
        )
    }
    
    /// Creates a configuration optimized for widget extensions
    /// - Parameters:
    ///   - appGroupIdentifier: App group identifier
    ///   - appMetadata: App metadata
    /// - Returns: Configuration with widget-optimized settings
    public static func widgetOptimized(
        appGroupIdentifier: String,
        appMetadata: AppMetaData
    ) -> SwapFoundationKitConfiguration {
        return SwapFoundationKitConfiguration(
            appGroupIdentifier: appGroupIdentifier,
            appMetadata: appMetadata,
            enableWatchConnectivity: false,
            enableAnalytics: false, // Widgets typically don't need analytics
            enableItemSync: true,
            networkTimeout: 10.0, // Very short timeout for widgets
            enableCertificatePinning: false
        )
    }
}
