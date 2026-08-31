/*****************************************************************************
 * DataSyncServiceImpl.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

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
/// let watchConnectivity = WatchConnectivityServiceImpl()
/// let watchSync = WatchSyncServiceImpl(connectivityService: watchConnectivity)
/// let syncService = DataSyncServiceImpl(
///     storage: AppGroupFileStorageService(appGroupIdentifier: "group.com.yourapp.widget"),
///     watchSyncService: watchSync
/// )
/// #endif
/// ```
public final class DataSyncServiceImpl: DataSyncService {
    
    // MARK: - Properties
    
    private let storage: FileStorageService
    private let watchSyncService: WatchSyncService?
    private let syncSubject = PassthroughSubject<SyncEvent, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    /// Creates a new data sync service
    /// - Parameters:
    ///   - storage: The file storage service to use
    ///   - watchSyncService: Optional Watch sync abstraction (iOS only)
    public init(
        storage: FileStorageService,
        watchSyncService: WatchSyncService? = nil
    ) {
        self.storage = storage
        self.watchSyncService = watchSyncService
        setupWatchSync()
    }

    /// Backward-compatible initializer for callers still passing WatchConnectivityService directly.
    public convenience init(
        storage: FileStorageService,
        watchConnectivity: WatchConnectivityService?
    ) {
        if let watchConnectivity {
            let watchSyncService = WatchSyncServiceImpl(connectivityService: watchConnectivity)
            self.init(storage: storage, watchSyncService: watchSyncService)
            watchSyncService.activate()
        } else {
            self.init(storage: storage, watchSyncService: nil)
        }
    }
    
    // MARK: - DataSyncService Implementation
    
    public func save<T: SyncableData>(_ data: T) async throws {
        do {
            // Save to file storage
            try storage.save(data)
            
            // Emit sync event
            syncSubject.send(.dataSaved(T.syncIdentifier))
            
            // Send to Watch if available and reachable
            if watchSyncService != nil {
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
    
    private func setupWatchSync() {
        guard let watchSyncService = watchSyncService else { return }

        watchSyncService.eventPublisher
            .sink { [weak self] data in
                self?.handleWatchEvent(data)
            }
            .store(in: &cancellables)
    }
    
    private func sendToWatch<T: SyncableData>(_ data: T) async throws {
        guard let watchSyncService = watchSyncService else { return }
        
        do {
            try await watchSyncService.send(data)
            syncSubject.send(.watchDataSent(T.syncIdentifier))
        } catch let watchError as WatchSyncError {
            let syncError = DataSyncError.watchConnectivityFailed(watchError)
            syncSubject.send(.error(syncError))
            throw syncError
        } catch {
            let syncError = DataSyncError.watchConnectivityFailed(error)
            syncSubject.send(.error(syncError))
            throw syncError
        }
    }
    
    private func handleWatchEvent(_ event: WatchSyncEvent) {
        switch event {
        case .received(let identifier, _):
            syncSubject.send(.watchDataReceived(identifier))
        case .error(let message):
            let syncError = DataSyncError.watchConnectivityFailed(
                NSError(
                    domain: "SwapFoundationKit.WatchSync",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: message]
                )
            )
            syncSubject.send(.error(syncError))
        default:
            break
        }
    }
}
