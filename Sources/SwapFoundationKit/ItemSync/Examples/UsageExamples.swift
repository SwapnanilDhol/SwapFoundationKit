//
//  UsageExamples.swift
//  SwapFoundationKit
//
//  Created by Swapnanil Dhol on 1/11/25.
//
//  This file contains comprehensive examples of how to use the ItemSyncService
//  in various scenarios. These examples can be used as reference or starting points.

import Foundation
import Combine

// MARK: - Example Data Models

/// Example user profile data model
struct UserProfile: SyncableData {
    let id: String
    let name: String
    let email: String
    let avatarURL: URL?
    let preferences: UserPreferences
    
    static let syncIdentifier = "user_profile"
}

/// Example user preferences data model
struct UserPreferences: Codable {
    let theme: String
    let notificationsEnabled: Bool
    let language: String
}

/// Example app settings data model
struct AppSettings: SyncableData {
    let isFirstLaunch: Bool
    let lastSyncDate: Date
    let syncEnabled: Bool
    
    static let syncIdentifier = "app_settings"
}

/// Example subscription data model
struct Subscription: SyncableData {
    let id: String
    let name: String
    let price: Double
    let currency: String
    let billingCycle: String
    let nextBillingDate: Date
    
    static let syncIdentifier = "subscriptions"
}

// MARK: - Basic Usage Examples

/// Example 1: Basic setup and usage
func basicUsageExample() {
    // Create sync service with App Group storage
    let syncService = ItemSyncServiceFactory.create(
        appGroupIdentifier: "group.com.yourapp.widget"
    )
    
    // Create sample data
    let userProfile = UserProfile(
        id: "user123",
        name: "John Doe",
        email: "john@example.com",
        avatarURL: URL(string: "https://example.com/avatar.jpg"),
        preferences: UserPreferences(
            theme: "dark",
            notificationsEnabled: true,
            language: "en"
        )
    )
    
    // Save data (this will automatically sync to widgets/extensions)
    Task {
        do {
            try await syncService.save(userProfile)
            print("User profile saved successfully")
        } catch {
            print("Failed to save user profile: \(error)")
        }
    }
    
    // Read data
    Task {
        do {
            let profile = try await syncService.read(UserProfile.self)
            print("Loaded user profile: \(profile.name)")
        } catch {
            print("Failed to load user profile: \(error)")
        }
    }
}

// MARK: - Watch Integration Examples

/// Example 2: Watch connectivity setup
func watchIntegrationExample() {
    #if os(iOS)
    // Create sync service with Watch support
    let syncService = ItemSyncServiceFactory.createWithWatch(
        appGroupIdentifier: "group.com.yourapp.widget"
    )
    
    // Listen to sync events
    var cancellables = Set<AnyCancellable>()
    
    syncService.syncPublisher
        .sink { event in
            switch event {
            case .dataSaved(let identifier):
                print("Data saved: \(identifier)")
            case .watchDataSent(let identifier):
                print("Data sent to Watch: \(identifier)")
            case .watchDataReceived(let identifier):
                print("Data received from Watch: \(identifier)")
            case .error(let error):
                print("Sync error: \(error.localizedDescription)")
            default:
                break
            }
        }
        .store(in: &cancellables)
    
    // Save data (will automatically sync to Watch if reachable)
    let subscription = Subscription(
        id: "sub123",
        name: "Netflix",
        price: 15.99,
        currency: "USD",
        billingCycle: "monthly",
        nextBillingDate: Date().addingTimeInterval(30 * 24 * 60 * 60)
    )
    
    Task {
        do {
            try await syncService.save(subscription)
        } catch {
            print("Failed to save subscription: \(error)")
        }
    }
    #endif
}

// MARK: - Advanced Usage Examples

/// Example 3: Custom storage implementation
func customStorageExample() {
    // Create custom storage service
    class CustomStorageService: FileStorageService {
        private var storage: [String: Data] = [:]
        
        func save<T: SyncableData>(_ data: T) throws {
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(data)
            storage[T.syncIdentifier] = jsonData
        }
        
        func read<T: SyncableData>(_ type: T.Type) throws -> T {
            guard let jsonData = storage[T.syncIdentifier] else {
                throw FileStorageError.fileNotFound
            }
            
            let decoder = JSONDecoder()
            return try decoder.decode(type, from: jsonData)
        }
        
        func exists<T: SyncableData>(_ type: T.Type) -> Bool {
            return storage[T.syncIdentifier] != nil
        }
        
        func delete<T: SyncableData>(_ type: T.Type) throws {
            storage.removeValue(forKey: T.syncIdentifier)
        }
    }
    
    // Use custom storage
    let customStorage = CustomStorageService()
    let syncService = ItemSyncServiceFactory.create(storage: customStorage)
    
    // Use the service normally
    let settings = AppSettings(
        isFirstLaunch: false,
        lastSyncDate: Date(),
        syncEnabled: true
    )
    
    Task {
        try await syncService.save(settings)
    }
}

// MARK: - Widget Integration Examples

/// Example 4: Widget data manager
@MainActor
class WidgetDataManager: ObservableObject {
    @Published var userProfile: UserProfile?
    @Published var subscriptions: [Subscription] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let syncService: DataSyncService
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Create sync service for widget
        syncService = ItemSyncServiceFactory.create(
            appGroupIdentifier: "group.com.yourapp.widget"
        )
        
        // Listen for data updates
        syncService.syncPublisher
            .sink { [weak self] event in
                switch event {
                case .dataSaved(let identifier):
                    if identifier == UserProfile.syncIdentifier {
                        Task { @MainActor in
                            await self?.loadUserProfile()
                        }
                    } else if identifier == Subscription.syncIdentifier {
                        Task { @MainActor in
                            await self?.loadSubscriptions()
                        }
                    }
                case .error(let error):
                    Task { @MainActor in
                        self?.error = error
                    }
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }
    
    func loadUserProfile() async {
        isLoading = true
        
        do {
            let profile = try await syncService.read(UserProfile.self)
            self.userProfile = profile
            self.isLoading = false
        } catch {
            self.error = error
            self.isLoading = false
        }
    }
    
    func loadSubscriptions() async {
        do {
            let subs = try await syncService.read([Subscription].self)
            self.subscriptions = subs
        } catch {
            self.error = error
        }
    }
}

// MARK: - Error Handling Examples

/// Example 5: Comprehensive error handling
func errorHandlingExample() {
    let syncService = ItemSyncServiceFactory.create(
        appGroupIdentifier: "group.com.yourapp.widget"
    )
    
    Task {
        do {
            let profile = try await syncService.read(UserProfile.self)
            print("Successfully loaded profile: \(profile.name)")
        } catch let error as DataSyncError {
            switch error {
            case .fileStorageFailed(let fileError):
                switch fileError {
                case .fileNotFound:
                    print("User profile not found. Creating new profile...")
                    // Handle missing data
                case .invalidAppGroupIdentifier:
                    print("Invalid app group identifier. Check your configuration.")
                default:
                    print("File storage error: \(fileError.localizedDescription)")
                }
            case .dataDecodingFailed(let decodingError):
                print("Failed to decode user profile: \(decodingError)")
                // Handle corrupted data
            case .watchConnectivityFailed(let watchError):
                print("Watch connectivity failed: \(watchError)")
                // Handle Watch communication issues
            default:
                print("Sync error: \(error.localizedDescription)")
            }
        } catch {
            print("Unexpected error: \(error)")
        }
    }
}

// MARK: - Batch Operations Example

/// Example 6: Batch operations
func batchOperationsExample() {
    let syncService = ItemSyncServiceFactory.create(
        appGroupIdentifier: "group.com.yourapp.widget"
    )
    
    // Save multiple data types
    Task {
        do {
            // Save user profile
            let profile = UserProfile(
                id: "user123",
                name: "John Doe",
                email: "john@example.com",
                avatarURL: nil,
                preferences: UserPreferences(
                    theme: "dark",
                    notificationsEnabled: true,
                    language: "en"
                )
            )
            try await syncService.save(profile)
            
            // Save app settings
            let settings = AppSettings(
                isFirstLaunch: false,
                lastSyncDate: Date(),
                syncEnabled: true
            )
            try await syncService.save(settings)
            
            // Save subscriptions
            let subscriptions = [
                Subscription(
                    id: "netflix",
                    name: "Netflix",
                    price: 15.99,
                    currency: "USD",
                    billingCycle: "monthly",
                    nextBillingDate: Date().addingTimeInterval(30 * 24 * 60 * 60)
                ),
                Subscription(
                    id: "spotify",
                    name: "Spotify",
                    price: 9.99,
                    currency: "USD",
                    billingCycle: "monthly",
                    nextBillingDate: Date().addingTimeInterval(30 * 24 * 60 * 60)
                )
            ]
            try await syncService.save(subscriptions)
            
            print("All data saved successfully")
        } catch {
            print("Failed to save data: \(error)")
        }
    }
} 
