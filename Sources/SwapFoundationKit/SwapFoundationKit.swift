import Foundation

/// Main entry point for SwapFoundationKit framework
/// Provides centralized configuration and service management
public final class SwapFoundationKit {
    
    // MARK: - Singleton
    
    public static let shared = SwapFoundationKit()
    
    // MARK: - Properties
    
    private var configuration: SwapFoundationKitConfiguration?
    private var isInitialized = false
    
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
        guard !config.appGroupIdentifier.isEmpty else {
            throw SwapFoundationKitError.invalidConfiguration("App group identifier cannot be empty")
        }
        
        guard config.networkTimeout > 0 else {
            throw SwapFoundationKitError.invalidConfiguration("Network timeout must be greater than 0")
        }
    }
    
    private func initializeServices() async throws {
        // Initialize core services based on configuration
        // This can be expanded to initialize other services as needed
        
        // For now, we just validate that the configuration is valid
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
