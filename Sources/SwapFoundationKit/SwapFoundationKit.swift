import Foundation

/// Main entry point for SwapFoundationKit framework
/// Provides centralized configuration and service management
public final class SwapFoundationKit {
    
    // MARK: - Singleton
    
    public static let shared = SwapFoundationKit()
    
    // MARK: - Properties

    private var configuration: SwapFoundationKitConfiguration?
    private var isInitialized = false
    private var httpClient: HTTPClient?

    // MARK: - Public Accessors

    /// Shared HTTP client instance for network requests
    /// Only available if networking is enabled in configuration
    public var networkClient: HTTPClient? {
        guard isInitialized, let config = configuration, config.enableNetworking else {
            return nil
        }
        return httpClient ?? HTTPClient.shared
    }
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// Initializes the framework with the provided configuration
    /// - Parameter config: Configuration containing all necessary settings
    /// - Throws: SwapFoundationKitError if initialization fails
    public func start(with config: SwapFoundationKitConfiguration) async throws {
        guard !isInitialized else {
            throw SwapFoundationKitError.alreadyInitialized
        }
        
        // Validate configuration
        try validateConfiguration(config)
        
        self.configuration = config
        try await initializeServices()
        isInitialized = true
    }
    
    /// Returns the current configuration if the framework is initialized
    /// - Returns: Current configuration or nil if not initialized
    public func getConfiguration() -> SwapFoundationKitConfiguration? {
        return configuration
    }
    
    /// Checks if the framework has been initialized
    /// - Returns: True if initialized, false otherwise
    public var isFrameworkInitialized: Bool {
        return isInitialized
    }
    
    // MARK: - Private Methods
    
    private func validateConfiguration(_ config: SwapFoundationKitConfiguration) throws {
        guard !config.appMetadata.appGroupIdentifier.isEmpty else {
            throw SwapFoundationKitError.invalidConfiguration("App group identifier cannot be empty")
        }

        guard config.networkTimeout > 0 else {
            throw SwapFoundationKitError.invalidConfiguration("Network timeout must be greater than 0")
        }

        if config.enableNetworking, let _ = config.customHTTPClient {
            // Validate custom HTTP client if provided
            // Could add additional validation here if needed
        }
    }
    
    private func initializeServices() async throws {
        // Initialize core services based on configuration

        // Initialize HTTP client if networking is enabled
        if let config = configuration, config.enableNetworking {
            if let customClient = config.customHTTPClient {
                self.httpClient = customClient
            } else {
                // Configure default HTTP client
                let client = HTTPClient.shared
                // Configure default headers if needed
                client.defaultHeaders["User-Agent"] = "\(config.appMetadata.appName)/\(config.appMetadata.appVersion)"
                self.httpClient = client
            }
        }

        // Additional service initialization can be added here
    }
}

// MARK: - Error Types

public enum SwapFoundationKitError: Error, LocalizedError {
    case alreadyInitialized
    case notInitialized
    case invalidConfiguration(String)
    
    public var errorDescription: String? {
        switch self {
        case .alreadyInitialized:
            return "SwapFoundationKit has already been initialized"
        case .notInitialized:
            return "SwapFoundationKit has not been initialized. Call start(with:) first"
        case .invalidConfiguration(let message):
            return "Invalid configuration: \(message)"
        }
    }
}
