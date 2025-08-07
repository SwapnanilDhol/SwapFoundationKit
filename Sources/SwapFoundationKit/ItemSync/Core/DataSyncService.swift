//
//  DataSyncService.swift
//  SwapFoundationKit
//
//  Created by Swapnanil Dhol on 1/11/25.
//

import Foundation

#if canImport(Combine)
import Combine
#endif

#if canImport(Combine)
/// Main protocol for data synchronization across your app ecosystem
/// This service orchestrates file storage and optional Watch connectivity
///
/// ## Usage Example
/// ```swift
/// // Create the sync service
/// let syncService = DataSyncService(
///     storage: AppGroupFileStorageService(appGroupIdentifier: "group.com.yourapp.widget")
/// )
///
/// // Save data (automatically syncs to widgets/extensions)
/// try await syncService.save(userProfile)
///
/// // Read data
/// let profile = try await syncService.read(UserProfile.self)
///
/// // Check if data exists
/// if syncService.exists(UserProfile.self) {
///     // Data is available
/// }
/// ```
@available(iOS 13.0, macOS 10.15, watchOS 6.0, *)
public protocol DataSyncService {
    /// Saves data and syncs it across the app ecosystem
    /// - Parameter data: The data to save and sync
    /// - Throws: DataSyncError if the operation fails
    func save<T: SyncableData>(_ data: T) async throws
    
    /// Reads synced data of the specified type
    /// - Parameter type: The type to decode the data into
    /// - Returns: The decoded data
    /// - Throws: DataSyncError if the operation fails
    func read<T: SyncableData>(_ type: T.Type) async throws -> T
    
    /// Checks if synced data exists for the given type
    /// - Parameter type: The type to check for
    /// - Returns: True if data exists, false otherwise
    func exists<T: SyncableData>(_ type: T.Type) -> Bool
    
    /// Deletes synced data for the given type
    /// - Parameter type: The type to delete
    /// - Throws: DataSyncError if the operation fails
    func delete<T: SyncableData>(_ type: T.Type) async throws
    
    /// Publisher that emits when data is synced
    /// Use this to react to sync events in your UI
    var syncPublisher: AnyPublisher<SyncEvent, Never> { get }
}

// MARK: - Sync Events

/// Events that occur during the sync process
public enum SyncEvent {
    case dataSaved(String) // syncIdentifier
    case dataDeleted(String) // syncIdentifier
    case watchDataSent(String) // syncIdentifier
    case watchDataReceived(String) // syncIdentifier
    case error(DataSyncError)
}

// MARK: - Errors

/// Errors that can occur during data synchronization
public enum DataSyncError: LocalizedError {
    case fileStorageFailed(FileStorageError)
    case watchConnectivityFailed(Error)
    case dataEncodingFailed(Error)
    case dataDecodingFailed(Error)
    case syncOperationFailed(String)
    
    public var errorDescription: String? {
        switch self {
        case .fileStorageFailed(let error):
            return "File storage failed: \(error.localizedDescription)"
        case .watchConnectivityFailed(let error):
            return "Watch connectivity failed: \(error.localizedDescription)"
        case .dataEncodingFailed(let error):
            return "Data encoding failed: \(error.localizedDescription)"
        case .dataDecodingFailed(let error):
            return "Data decoding failed: \(error.localizedDescription)"
        case .syncOperationFailed(let message):
            return "Sync operation failed: \(message)"
        }
    }
}
#endif