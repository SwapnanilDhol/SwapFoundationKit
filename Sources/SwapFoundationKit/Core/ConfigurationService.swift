import Foundation

/// Service for managing app configuration, environment settings, and configuration values
@MainActor
public final class ConfigurationService {
    
    public enum ConfigurationError: Error, LocalizedError {
        case keyNotFound(String)
        case invalidValue(String, String)
        case environmentNotSet
        case configurationFileNotFound
        
        public var errorDescription: String? {
            switch self {
            case .keyNotFound(let key):
                return "Configuration key '\(key)' not found"
            case .invalidValue(let key, let value):
                return "Invalid value '\(value)' for configuration key '\(key)'"
            case .environmentNotSet:
                return "Environment not set in configuration"
            case .configurationFileNotFound:
                return "Configuration file not found"
            }
        }
    }
    
    public enum Environment: String, CaseIterable {
        case development = "development"
        case staging = "staging"
        case production = "production"
        case testing = "testing"
        
        public var displayName: String {
            switch self {
            case .development: return "Development"
            case .staging: return "Staging"
            case .production: return "Production"
            case .testing: return "Testing"
            }
        }
        
        public var isProduction: Bool {
            return self == .production
        }
        
        public var isDevelopment: Bool {
            return self == .development
        }
        
        public var isStaging: Bool {
            return self == .staging
        }
        
        public var isTesting: Bool {
            return self == .testing
        }
    }
    
    private var configuration: [String: Any] = [:]
    private var environment: Environment?
    
    public static let shared = ConfigurationService()
    
    private init() {
        loadConfiguration()
    }
    
    // MARK: - Configuration Loading
    
    /// Loads configuration from the main bundle
    private func loadConfiguration() {
        // Try to load from Info.plist first
        if let infoPlist = Bundle.main.infoDictionary {
            configuration.merge(infoPlist) { _, new in new }
        }
        
        // Try to load from custom configuration file
        if let configPath = Bundle.main.path(forResource: "Configuration", ofType: "plist"),
           let configData = NSDictionary(contentsOfFile: configPath) as? [String: Any] {
            configuration.merge(configData) { _, new in new }
        }
        
        // Set environment
        if let envString = configuration["APP_ENVIRONMENT"] as? String,
           let env = Environment(rawValue: envString) {
            environment = env
        } else {
            // Default to development if not specified
            #if DEBUG
            environment = .development
            #else
            environment = .production
            #endif
        }
    }
    
    // MARK: - Environment Management
    
    /// Gets the current environment
    /// - Returns: The current environment
    public func getCurrentEnvironment() -> Environment {
        return environment ?? .development
    }
    
    /// Sets the environment (useful for testing)
    /// - Parameter environment: The environment to set
    public func setEnvironment(_ environment: Environment) {
        self.environment = environment
    }
    
    /// Checks if the current environment matches the specified environment
    /// - Parameter environment: The environment to check
    /// - Returns: True if the current environment matches
    public func isEnvironment(_ environment: Environment) -> Bool {
        return getCurrentEnvironment() == environment
    }
    
    // MARK: - Configuration Values
    
    /// Gets a string value from configuration
    /// - Parameter key: The configuration key
    /// - Returns: The string value
    /// - Throws: ConfigurationError
    public func getString(for key: String) throws -> String {
        guard let value = configuration[key] as? String else {
            throw ConfigurationError.keyNotFound(key)
        }
        return value
    }
    
    /// Gets a string value from configuration with a default
    /// - Parameters:
    ///   - key: The configuration key
    ///   - defaultValue: The default value if key is not found
    /// - Returns: The string value or default
    public func getString(for key: String, defaultValue: String) -> String {
        return (configuration[key] as? String) ?? defaultValue
    }
    
    /// Gets an integer value from configuration
    /// - Parameter key: The configuration key
    /// - Returns: The integer value
    /// - Throws: ConfigurationError
    public func getInt(for key: String) throws -> Int {
        guard let value = configuration[key] as? Int else {
            throw ConfigurationError.keyNotFound(key)
        }
        return value
    }
    
    /// Gets an integer value from configuration with a default
    /// - Parameters:
    ///   - key: The configuration key
    ///   - defaultValue: The default value if key is not found
    /// - Returns: The integer value or default
    public func getInt(for key: String, defaultValue: Int) -> Int {
        return (configuration[key] as? Int) ?? defaultValue
    }
    
    /// Gets a boolean value from configuration
    /// - Parameter key: The configuration key
    /// - Returns: The boolean value
    /// - Throws: ConfigurationError
    public func getBool(for key: String) throws -> Bool {
        guard let value = configuration[key] as? Bool else {
            throw ConfigurationError.keyNotFound(key)
        }
        return value
    }
    
    /// Gets a boolean value from configuration with a default
    /// - Parameters:
    ///   - key: The configuration key
    ///   - defaultValue: The default value if key is not found
    /// - Returns: The boolean value or default
    public func getBool(for key: String, defaultValue: Bool) -> Bool {
        return (configuration[key] as? Bool) ?? defaultValue
    }
    
    /// Gets a double value from configuration
    /// - Parameter key: The configuration key
    /// - Returns: The double value
    /// - Throws: ConfigurationError
    public func getDouble(for key: String) throws -> Double {
        guard let value = configuration[key] as? Double else {
            throw ConfigurationError.keyNotFound(key)
        }
        return value
    }
    
    /// Gets a double value from configuration with a default
    /// - Parameters:
    ///   - key: The configuration key
    ///   - defaultValue: The default value if key is not found
    /// - Returns: The double value or default
    public func getDouble(for key: String, defaultValue: Double) -> Double {
        return (configuration[key] as? Double) ?? defaultValue
    }
    
    /// Gets a URL value from configuration
    /// - Parameter key: The configuration key
    /// - Returns: The URL value
    /// - Throws: ConfigurationError
    public func getURL(for key: String) throws -> URL {
        guard let urlString = configuration[key] as? String,
              let url = URL(string: urlString) else {
            throw ConfigurationError.keyNotFound(key)
        }
        return url
    }
    
    /// Gets a URL value from configuration with a default
    /// - Parameters:
    ///   - key: The configuration key
    ///   - defaultValue: The default value if key is not found
    /// - Returns: The URL value or default
    public func getURL(for key: String, defaultValue: URL) -> URL {
        if let urlString = configuration[key] as? String,
           let url = URL(string: urlString) {
            return url
        }
        return defaultValue
    }
    
    /// Gets a dictionary value from configuration
    /// - Parameter key: The configuration key
    /// - Returns: The dictionary value
    /// - Throws: ConfigurationError
    public func getDictionary(for key: String) throws -> [String: Any] {
        guard let value = configuration[key] as? [String: Any] else {
            throw ConfigurationError.keyNotFound(key)
        }
        return value
    }
    
    /// Gets an array value from configuration
    /// - Parameter key: The configuration key
    /// - Returns: The array value
    /// - Throws: ConfigurationError
    public func getArray<T>(for key: String) throws -> [T] {
        guard let value = configuration[key] as? [T] else {
            throw ConfigurationError.keyNotFound(key)
        }
        return value
    }
    
    // MARK: - Environment-Specific Configuration
    
    /// Gets a configuration value for a specific environment
    /// - Parameters:
    ///   - key: The configuration key
    ///   - environment: The environment to get the value for
    /// - Returns: The configuration value
    /// - Throws: ConfigurationError
    public func getValue<T>(for key: String, in environment: Environment) throws -> T {
        let envKey = "\(key)_\(environment.rawValue.uppercased())"
        
        if let value = configuration[envKey] as? T {
            return value
        }
        
        // Fallback to base key
        guard let value = configuration[key] as? T else {
            throw ConfigurationError.keyNotFound(key)
        }
        
        return value
    }
    
    /// Gets a configuration value for the current environment
    /// - Parameter key: The configuration key
    /// - Returns: The configuration value
    /// - Throws: ConfigurationError
    public func getValueForCurrentEnvironment<T>(for key: String) throws -> T {
        return try getValue(for: key, in: getCurrentEnvironment())
    }
    
    // MARK: - Configuration Management
    
    /// Sets a configuration value
    /// - Parameters:
    ///   - value: The value to set
    ///   - key: The configuration key
    public func setValue<T>(_ value: T, for key: String) {
        configuration[key] = value
    }
    
    /// Removes a configuration value
    /// - Parameter key: The configuration key
    public func removeValue(for key: String) {
        configuration.removeValue(forKey: key)
    }
    
    /// Checks if a configuration key exists
    /// - Parameter key: The configuration key
    /// - Returns: True if the key exists
    public func hasKey(_ key: String) -> Bool {
        return configuration[key] != nil
    }
    
    /// Gets all configuration keys
    /// - Returns: Array of configuration keys
    public func getAllKeys() -> [String] {
        return Array(configuration.keys)
    }
    
    /// Gets all configuration values
    /// - Returns: Dictionary of all configuration values
    public func getAllValues() -> [String: Any] {
        return configuration
    }
    
    // MARK: - Validation
    
    /// Validates that required configuration keys exist
    /// - Parameter requiredKeys: Array of required configuration keys
    /// - Throws: ConfigurationError if any required keys are missing
    public func validateRequiredKeys(_ requiredKeys: [String]) throws {
        for key in requiredKeys {
            guard configuration[key] != nil else {
                throw ConfigurationError.keyNotFound(key)
            }
        }
    }
    
    /// Validates that a configuration value matches expected type
    /// - Parameters:
    ///   - key: The configuration key
    ///   - expectedType: The expected type
    /// - Throws: ConfigurationError if validation fails
    public func validateType<T>(for key: String, expectedType: T.Type) throws {
        guard configuration[key] is T else {
            throw ConfigurationError.invalidValue(key, "Expected type \(T.self)")
        }
    }
}

// MARK: - Convenience Extensions

extension ConfigurationService {
    
    /// Gets the API base URL for the current environment
    /// - Returns: The API base URL
    /// - Throws: ConfigurationError
    public func getAPIBaseURL() throws -> URL {
        return try getValueForCurrentEnvironment(for: "API_BASE_URL")
    }
    
    /// Gets the API key for the current environment
    /// - Returns: The API key
    /// - Throws: ConfigurationError
    public func getAPIKey() throws -> String {
        return try getValueForCurrentEnvironment(for: "API_KEY")
    }
    
    /// Gets the app version
    /// - Returns: The app version
    public func getAppVersion() -> String {
        return getString(for: "CFBundleShortVersionString", defaultValue: "1.0.0")
    }
    
    /// Gets the build number
    /// - Returns: The build number
    public func getBuildNumber() -> String {
        return getString(for: "CFBundleVersion", defaultValue: "1")
    }
    
    /// Gets the bundle identifier
    /// - Returns: The bundle identifier
    public func getBundleIdentifier() -> String {
        return getString(for: "CFBundleIdentifier", defaultValue: "com.example.app")
    }
    
    /// Gets the app name
    /// - Returns: The app name
    public func getAppName() -> String {
        return getString(for: "CFBundleDisplayName", defaultValue: "My App")
    }
    
    /// Checks if the app is running in debug mode
    /// - Returns: True if in debug mode
    public func isDebugMode() -> Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
    
    /// Gets the maximum retry count for network requests
    /// - Returns: The maximum retry count
    public func getMaxRetryCount() -> Int {
        return getInt(for: "MAX_RETRY_COUNT", defaultValue: 3)
    }
    
    /// Gets the network timeout interval
    /// - Returns: The timeout interval in seconds
    public func getNetworkTimeout() -> TimeInterval {
        return getDouble(for: "NETWORK_TIMEOUT", defaultValue: 30.0)
    }
    
    /// Gets the cache expiration time
    /// - Returns: The cache expiration time in seconds
    public func getCacheExpiration() -> TimeInterval {
        return getDouble(for: "CACHE_EXPIRATION", defaultValue: 3600.0)
    }
}
