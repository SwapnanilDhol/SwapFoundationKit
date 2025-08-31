//
//  AppGroupFileStorageService.swift
//  SwapFoundationKit
//
//  Created by Swapnanil Dhol on 1/11/25.
//

import Foundation

/// Default file storage implementation using App Group containers
/// This allows sharing data between your main app, widgets, and extensions
///
/// ## Usage Example
/// ```swift
/// // NEW: Automatic configuration (recommended)
/// let storage = AppGroupFileStorageService()
///
/// // Legacy: Create with your app group identifier
/// let storage = AppGroupFileStorageService(
///     appGroupIdentifier: "group.com.yourapp.widget"
/// )
///
/// // Save data
/// try storage.save(userProfile)
///
/// // Read data
/// let profile = try storage.read(UserProfile.self)
/// ```
public final class AppGroupFileStorageService: FileStorageService {
    
    // MARK: - Properties
    
    private let appGroupIdentifier: String
    private let fileManager: FileManager
    
    // MARK: - Initialization
    
    /// Creates a new App Group file storage service using centralized configuration
    /// - Note: Requires SwapFoundationKit.shared.start(with:) to be called first
    public init() {
        guard let config = SwapFoundationKit.shared.getConfiguration() else {
            fatalError("SwapFoundationKit not initialized. Call SwapFoundationKit.shared.start(with:) first.")
        }
        self.appGroupIdentifier = config.appMetadata.appGroupIdentifier
        self.fileManager = .default
    }
    
    /// Creates a new App Group file storage service
    /// - Parameters:
    ///   - appGroupIdentifier: Your app group identifier (e.g., "group.com.yourapp.widget")
    ///   - fileManager: FileManager instance (defaults to .default)
    public init(
        appGroupIdentifier: String,
        fileManager: FileManager = .default
    ) {
        self.appGroupIdentifier = appGroupIdentifier
        self.fileManager = fileManager
    }
    
    // MARK: - FileStorageService Implementation
    
    public func save<T: SyncableData>(_ data: T) throws {
        guard let containerURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) else {
            throw FileStorageError.invalidAppGroupIdentifier
        }
        
        let fileURL = containerURL.appendingPathComponent(data.fullFileName)
        
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let jsonData = try encoder.encode(data)
            try jsonData.write(to: fileURL)
        } catch let error as EncodingError {
            throw FileStorageError.encodingFailed(error)
        } catch {
            throw FileStorageError.fileSystemError(error)
        }
    }
    
    public func read<T: SyncableData>(_ type: T.Type) throws -> T {
        guard let containerURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) else {
            throw FileStorageError.invalidAppGroupIdentifier
        }
        
        let fileURL = containerURL.appendingPathComponent(T.syncIdentifier).appendingPathExtension(T.fileExtension)
        
        guard fileManager.fileExists(atPath: fileURL.path) else {
            throw FileStorageError.fileNotFound
        }
        
        do {
            let jsonData = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            return try decoder.decode(type, from: jsonData)
        } catch let error as DecodingError {
            throw FileStorageError.decodingFailed(error)
        } catch {
            throw FileStorageError.fileSystemError(error)
        }
    }
    
    public func exists<T: SyncableData>(_ type: T.Type) -> Bool {
        guard let containerURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) else {
            return false
        }
        
        let fileURL = containerURL.appendingPathComponent(T.syncIdentifier).appendingPathExtension(T.fileExtension)
        return fileManager.fileExists(atPath: fileURL.path)
    }
    
    public func delete<T: SyncableData>(_ type: T.Type) throws {
        guard let containerURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) else {
            throw FileStorageError.invalidAppGroupIdentifier
        }
        
        let fileURL = containerURL.appendingPathComponent(T.syncIdentifier).appendingPathExtension(T.fileExtension)
        
        guard fileManager.fileExists(atPath: fileURL.path) else {
            throw FileStorageError.fileNotFound
        }
        
        do {
            try fileManager.removeItem(at: fileURL)
        } catch {
            throw FileStorageError.fileSystemError(error)
        }
    }
} 