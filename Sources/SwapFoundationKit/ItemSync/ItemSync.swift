//
//  ItemSync.swift
//  SwapFoundationKit
//
//  Created by Swapnanil Dhol on 1/11/25.
//

import Foundation

/// ItemSync module for SwapFoundationKit
/// 
/// This module provides a generic, reusable data synchronization service
/// for iOS apps that need to share data between the main app, widgets, and Watch apps.
///
/// ## Quick Start
/// ```swift
/// import SwapFoundationKit.ItemSync
///
/// // Define your data model
/// struct UserProfile: SyncableData {
///     let id: String
///     let name: String
///     static let syncIdentifier = "user_profile"
/// }
///
/// // Create sync service
/// let syncService = ItemSyncServiceFactory.create(
///     appGroupIdentifier: "group.com.yourapp.widget"
/// )
///
/// // Use the service
/// try await syncService.save(userProfile)
/// let profile = try await syncService.read(UserProfile.self)
/// ```
///
/// ## Features
/// - ✅ Generic & Reusable: Works with any `Codable` data type
/// - ✅ Widget Support: Automatic data sharing with widgets via App Groups
/// - ✅ Watch Support: Optional Watch connectivity for data sync
/// - ✅ Simple API: Easy to use with minimal setup
/// - ✅ Error Handling: Comprehensive error handling with detailed messages
/// - ✅ Combine Support: Reactive programming with publishers
/// - ✅ Protocol-Based: Highly testable and extensible
///
/// ## Requirements
/// - iOS 13.0+ / watchOS 6.0+ / macOS 10.15+
/// - Swift 5.0+
/// - App Group capability (for widget support)
/// - Watch Connectivity capability (for Watch support)
///
/// For detailed documentation and examples, see the README.md file.
public enum ItemSync {
    // This enum serves as a namespace for the ItemSync module
    // All public APIs are exposed through the individual types
} 