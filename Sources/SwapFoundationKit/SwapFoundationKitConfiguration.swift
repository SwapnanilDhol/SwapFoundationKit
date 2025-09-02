import Foundation

/// Configuration struct for SwapFoundationKit framework
/// Contains all necessary settings for initializing and configuring the framework
public struct SwapFoundationKitConfiguration {
    
    // MARK: - App Metadata
    
    /// App metadata containing app information including app group identifier
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
    ///   - appMetadata: App metadata information (must include appGroupIdentifier)
    ///   - enableWatchConnectivity: Whether to enable Watch connectivity
    ///   - enableAnalytics: Whether to enable analytics
    ///   - enableItemSync: Whether to enable item synchronization
    ///   - networkTimeout: Network timeout in seconds
    ///   - enableCertificatePinning: Whether to enable certificate pinning
    ///   - customAnalyticsLogger: Custom analytics logger
    ///   - customStorageService: Custom storage service
    public init(
        appMetadata: AppMetaData,
        enableWatchConnectivity: Bool = false,
        enableAnalytics: Bool = true,
        enableItemSync: Bool = true,
        networkTimeout: TimeInterval = 30.0,
        enableCertificatePinning: Bool = false,
        customAnalyticsLogger: AnalyticsLogger? = nil,
        customStorageService: FileStorageService? = nil
    ) {
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
    /// - Parameter appMetadata: App metadata (must include appGroupIdentifier)
    /// - Returns: Configuration with default values
    public static func basic(
        appMetadata: AppMetaData
    ) -> SwapFoundationKitConfiguration {
        return SwapFoundationKitConfiguration(
            appMetadata: appMetadata
        )
    }
}
