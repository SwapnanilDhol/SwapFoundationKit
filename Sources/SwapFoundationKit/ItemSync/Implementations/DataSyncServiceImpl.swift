//
//  DataSyncServiceImpl.swift
//  SwapFoundationKit
//
//  Created by Swapnanil Dhol on 1/11/25.
//

import Foundation
import Combine

/// Main implementation of DataSyncService that orchestrates file storage and Watch connectivity
/// This is the primary service that apps will use for data synchronization
///
/// ## Usage Example
/// ```swift
/// // Create with file storage only
/// let syncService = DataSyncServiceImpl(
///     storage: AppGroupFileStorageService(appGroupIdentifier: "group.com.yourapp.widget")
/// )
///
/// // Create with Watch connectivity (iOS only)
/// #if os(iOS)
/// let syncService = DataSyncServiceImpl(
///     storage: AppGroupFileStorageService(appGroupIdentifier: "group.com.yourapp.widget"),
///     watchConnectivity: WatchConnectivityService()
/// )
/// #endif
/// ```
@available(iOS 13.0, macOS 10.15, watchOS 6.0, *)
public final class DataSyncServiceImpl: DataSyncService {
    
    // MARK: - Properties
    
    private let storage: FileStorageService
    private let watchConnectivity: WatchConnectivityService?
    private let syncSubject = PassthroughSubject<SyncEvent, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    /// Creates a new data sync service
    /// - Parameters:
    ///   - storage: The file storage service to use
    ///   - watchConnectivity: Optional Watch connectivity service (iOS only)
    public init(
        storage: FileStorageService,
        watchConnectivity: WatchConnectivityService? = nil
    ) {
        self.storage = storage
        self.watchConnectivity = watchConnectivity
        
        setupWatchConnectivity()
    }
    
    // MARK: - DataSyncService Implementation
    
    public func save<T: SyncableData>(_ data: T) async throws {
        do {
            // Save to file storage
            try storage.save(data)
            
            // Emit sync event
            syncSubject.send(.dataSaved(T.syncIdentifier))
            
            // Send to Watch if available and reachable
            if let watchConnectivity = watchConnectivity,
               watchConnectivity.isReachable {
                try await sendToWatch(data)
            }
            
        } catch let error as FileStorageError {
            let syncError = DataSyncError.fileStorageFailed(error)
            syncSubject.send(.error(syncError))
            throw syncError
        } catch {
            let syncError = DataSyncError.dataEncodingFailed(error)
            syncSubject.send(.error(syncError))
            throw syncError
        }
    }
    
    public func read<T: SyncableData>(_ type: T.Type) async throws -> T {
        do {
            return try storage.read(type)
        } catch let error as FileStorageError {
            let syncError = DataSyncError.fileStorageFailed(error)
            syncSubject.send(.error(syncError))
            throw syncError
        } catch {
            let syncError = DataSyncError.dataDecodingFailed(error)
            syncSubject.send(.error(syncError))
            throw syncError
        }
    }
    
    public func exists<T: SyncableData>(_ type: T.Type) -> Bool {
        return storage.exists(type)
    }
    
    public func delete<T: SyncableData>(_ type: T.Type) async throws {
        do {
            try storage.delete(type)
            syncSubject.send(.dataDeleted(T.syncIdentifier))
        } catch let error as FileStorageError {
            let syncError = DataSyncError.fileStorageFailed(error)
            syncSubject.send(.error(syncError))
            throw syncError
        } catch {
            let syncError = DataSyncError.syncOperationFailed(error.localizedDescription)
            syncSubject.send(.error(syncError))
            throw syncError
        }
    }
    
    public var syncPublisher: AnyPublisher<SyncEvent, Never> {
        syncSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Private Methods
    
    private func setupWatchConnectivity() {
        guard let watchConnectivity = watchConnectivity else { return }
        
        // Listen for data received from Watch
        watchConnectivity.dataReceivedPublisher
            .sink { [weak self] data in
                self?.handleWatchData(data)
            }
            .store(in: &cancellables)
    }
    
    private func sendToWatch<T: SyncableData>(_ data: T) async throws {
        guard let watchConnectivity = watchConnectivity else { return }
        
        do {
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(data)
            try watchConnectivity.sendData(jsonData)
            syncSubject.send(.watchDataSent(T.syncIdentifier))
        } catch {
            let syncError = DataSyncError.watchConnectivityFailed(error)
            syncSubject.send(.error(syncError))
            throw syncError
        }
    }
    
    private func handleWatchData(_ data: Data) {
        // This is a simplified implementation
        // In a real app, you might want to decode the data and save it
        syncSubject.send(.watchDataReceived("watch_data"))
    }
} 