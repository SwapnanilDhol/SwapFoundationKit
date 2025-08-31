import Foundation

/// Example implementation showing how to use the new centralized configuration system
/// This file demonstrates the recommended way to set up and use SwapFoundationKit
///
/// ## Quick Start Example
/// ```swift
/// // 1. Define your app metadata
/// enum MyAppMetadata: AppMetaData {
///     static let appGroupIdentifier = "group.com.yourapp.widget"
///     static let appID = "com.yourapp"
///     static let appName = "My Awesome App"
///     static let appShareDescription = "Check out this amazing app!"
///     // ... other properties
/// }
///
/// // 2. Initialize the framework
/// Task {
///     await setupSwapFoundationKit()
/// }
///
/// // 3. Use services without manual configuration
/// let syncService = ItemSyncServiceFactory.create() // Automatic!
/// ```
///
/// ## Complete Setup Example
/// ```swift
/// @main
/// struct MyApp: App {
///     init() {
///         Task {
///             await setupSwapFoundationKit()
///         }
///     }
///     
///     private func setupSwapFoundationKit() async {
///         let config = SwapFoundationKitConfiguration(
///             appGroupIdentifier: "group.com.yourapp.widget",
///             appMetadata: MyAppMetadata.self,
///             enableWatchConnectivity: true,
///             enableAnalytics: true,
///             enableItemSync: true,
///             networkTimeout: 30.0,
///             enableCertificatePinning: true
///         )
///         
///         do {
///             try await SwapFoundationKit.shared.start(with: config)
///             print("✅ SwapFoundationKit initialized successfully")
///         } catch {
///             print("❌ Failed to initialize SwapFoundationKit: \(error)")
///         }
///     }
/// }
/// ```
///
/// ## Convenience Configuration Examples
/// ```swift
/// // Basic configuration
/// let basicConfig = SwapFoundationKitConfiguration.basic(
///     appGroupIdentifier: "group.com.yourapp.widget",
///     appMetadata: MyAppMetadata.self
/// )
///
/// // Watch-optimized configuration
/// let watchConfig = SwapFoundationKitConfiguration.watchOptimized(
///     appGroupIdentifier: "group.com.yourapp.widget",
///     appMetadata: MyAppMetadata.self
/// )
///
/// // Widget-optimized configuration
/// let widgetConfig = SwapFoundationKitConfiguration.widgetOptimized(
///     appGroupIdentifier: "group.com.yourapp.widget",
///     appMetadata: MyAppMetadata.self
/// )
/// ```
///
/// ## Service Usage Examples
/// ```swift
/// // After initialization, services work automatically:
///
/// // ItemSync - no need to pass appGroupIdentifier
/// let syncService = ItemSyncServiceFactory.create()
/// try await syncService.save(userProfile)
///
/// // File Storage - automatic configuration
/// let storage = AppGroupFileStorageService()
/// try storage.save(appSettings)
///
/// // Check framework status
/// if SwapFoundationKit.shared.isFrameworkInitialized {
///     // Framework is ready
/// }
///
/// // Get current configuration
/// if let config = SwapFoundationKit.shared.getConfiguration() {
///     print("App Group: \(config.appMetadata.appGroupIdentifier)")
///     print("Watch Connectivity: \(config.enableWatchConnectivity)")
/// }
/// ```
///
/// ## Migration from Old Pattern
/// ```swift
/// // OLD WAY (still works for backward compatibility)
/// let syncService = ItemSyncServiceFactory.create(
///     appGroupIdentifier: "group.com.yourapp.widget"
/// )
///
/// // NEW WAY (recommended)
/// let syncService = ItemSyncServiceFactory.create() // Automatic!
/// ```
///
/// ## Error Handling
/// ```swift
/// do {
///     try await SwapFoundationKit.shared.start(with: config)
/// } catch SwapFoundationKitError.alreadyInitialized {
///     print("Framework already initialized")
/// } catch SwapFoundationKitError.invalidConfiguration(let message) {
///     print("Invalid configuration: \(message)")
/// } catch {
///     print("Unknown error: \(error)")
/// }
/// ```
///
/// ## Testing
/// ```swift
/// // In your unit tests, you can create mock configurations
/// class MockAppMetadata: AppMetaData {
///     static let appGroupIdentifier = "group.test.app"
///     static let appID = "com.test.app"
///     // ... other properties
/// }
///
/// let testConfig = SwapFoundationKitConfiguration.basic(
///     appGroupIdentifier: "group.test.app",
///     appMetadata: MockAppMetadata.self
/// )
///
/// try await SwapFoundationKit.shared.start(with: testConfig)
/// ```
public enum ConfigurationUsageExample {
    // This enum serves as a namespace for configuration examples
    // All examples are documented above
}
