//
//  FileStorageService.swift
//  SwapFoundationKit
//
//  Created by Swapnanil Dhol on 1/11/25.
//

import Foundation

/// Protocol defining file storage operations for syncable data
/// This allows for different storage implementations (App Groups, Documents, etc.)
///
/// ## Usage Example
/// ```swift
/// // Use the default App Group implementation
/// let storage = AppGroupFileStorageService(
///     appGroupIdentifier: "group.com.yourapp.widget"
/// )
///
/// // Or create a custom implementation
/// class CustomStorageService: FileStorageService {
///     func save<T: SyncableData>(_ data: T) throws {
///         // Your custom save logic
///     }
///     
///     func read<T: SyncableData>(_ type: T.Type) throws -> T {
///         // Your custom read logic
///     }
/// }
/// ```
public protocol FileStorageService {
    /// Saves syncable data to storage
    /// - Parameter data: The data to save
    /// - Throws: FileStorageError if the operation fails
    func save<T: SyncableData>(_ data: T) throws
    
    /// Reads and decodes syncable data from storage
    /// - Parameter type: The type to decode the data into
    /// - Returns: The decoded data
    /// - Throws: FileStorageError if the operation fails
    func read<T: SyncableData>(_ type: T.Type) throws -> T
    
    /// Checks if data exists for the given type
    /// - Parameter type: The type to check for
    /// - Returns: True if data exists, false otherwise
    func exists<T: SyncableData>(_ type: T.Type) -> Bool
    
    /// Deletes data for the given type
    /// - Parameter type: The type to delete
    /// - Throws: FileStorageError if the operation fails
    func delete<T: SyncableData>(_ type: T.Type) throws
}

// MARK: - Errors

/// Errors that can occur during file storage operations
public enum FileStorageError: LocalizedError {
    case invalidAppGroupIdentifier
    case fileNotFound
    case encodingFailed(Error)
    case decodingFailed(Error)
    case fileSystemError(Error)
    case invalidData
    
    public var errorDescription: String? {
        switch self {
        case .invalidAppGroupIdentifier:
            return "Invalid app group identifier"
        case .fileNotFound:
            return "File not found"
        case .encodingFailed(let error):
            return "Failed to encode data: \(error.localizedDescription)"
        case .decodingFailed(let error):
            return "Failed to decode data: \(error.localizedDescription)"
        case .fileSystemError(let error):
            return "File system error: \(error.localizedDescription)"
        case .invalidData:
            return "Invalid data format"
        }
    }
} 