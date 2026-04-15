/*****************************************************************************
 * ItemSyncServiceFactory.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import Foundation

/// Factory class for creating and configuring ItemSyncService instances
/// This provides convenient methods to create sync services with common configurations
///
/// ## Usage Examples
/// ```swift
/// // NEW: Centralized configuration (recommended)
/// let syncService = ItemSyncServiceFactory.create()
///
/// // Legacy: Quick setup with just app group identifier
/// let syncService = ItemSyncServiceFactory.create(
///     appGroupIdentifier: "group.com.yourapp.widget"
/// )
///
/// // Legacy: Setup with Watch connectivity (iOS only)
/// #if os(iOS)
/// let syncService = ItemSyncServiceFactory.createWithWatch(
///     appGroupIdentifier: "group.com.yourapp.widget"
/// )
/// #endif
///
/// // Legacy: Custom configuration
/// let storage = AppGroupFileStorageService(appGroupIdentifier: "group.com.yourapp.widget")
/// let watchService = WatchConnectivityServiceImpl()
/// let syncService = ItemSyncServiceFactory.create(
///     storage: storage,
///     watchConnectivity: watchService
/// )
/// ```
public final class ItemSyncServiceFactory {
    
    // MARK: - Factory Methods
    
    /// Creates a sync service using the centralized framework configuration
    /// - Returns: Configured DataSyncService instance
    /// - Note: Requires SwapFoundationKit.shared.start(with:) to be called first
    public static func create() -> DataSyncService {
        guard let config = SwapFoundationKit.shared.getConfiguration() else {
            fatalError("SwapFoundationKit not initialized. Call SwapFoundationKit.shared.start(with:) first.")
        }
        
        guard config.enableItemSync else {
            fatalError("ItemSync is disabled in the current configuration.")
        }
        
        let storage: FileStorageService
        
        if let customStorage = config.customStorageService {
            storage = customStorage
        } else {
            storage = AppGroupFileStorageService(appGroupIdentifier: config.appMetadata.appGroupIdentifier)
        }
        
        #if os(iOS)
        if config.enableWatchConnectivity {
            let watchService = WatchConnectivityServiceImpl()
            let watchSyncService = WatchSyncServiceImpl(
                connectivityService: watchService,
                options: config.watchSyncOptions
            )
            watchSyncService.activate()
            return DataSyncServiceImpl(storage: storage, watchSyncService: watchSyncService)
        }
        #endif
        
        return DataSyncServiceImpl(storage: storage)
    }
    
    /// Creates a sync service with the default App Group storage
    /// - Parameter appGroupIdentifier: Your app group identifier
    /// - Returns: Configured DataSyncService instance
    public static func create(appGroupIdentifier: String) -> DataSyncService {
        let storage = AppGroupFileStorageService(appGroupIdentifier: appGroupIdentifier)
        return DataSyncServiceImpl(storage: storage)
    }
    
    /// Creates a sync service with custom storage
    /// - Parameter storage: Custom file storage service
    /// - Returns: Configured DataSyncService instance
    public static func create(storage: FileStorageService) -> DataSyncService {
        return DataSyncServiceImpl(storage: storage)
    }
    
    /// Creates a sync service with custom storage and Watch connectivity
    /// - Parameters:
    ///   - storage: Custom file storage service
    ///   - watchConnectivity: Watch connectivity service
    /// - Returns: Configured DataSyncService instance
    public static func create(
        storage: FileStorageService,
        watchConnectivity: WatchConnectivityService
    ) -> DataSyncService {
        let watchSyncService = WatchSyncServiceImpl(connectivityService: watchConnectivity)
        watchSyncService.activate()
        return DataSyncServiceImpl(storage: storage, watchSyncService: watchSyncService)
    }

    /// Creates a sync service with custom storage and WatchSync abstraction.
    /// - Parameters:
    ///   - storage: Custom file storage service
    ///   - watchSyncService: Watch sync service abstraction
    /// - Returns: Configured DataSyncService instance
    public static func create(
        storage: FileStorageService,
        watchSyncService: WatchSyncService
    ) -> DataSyncService {
        watchSyncService.activate()
        return DataSyncServiceImpl(storage: storage, watchSyncService: watchSyncService)
    }
    
    #if os(iOS)
    /// Creates a sync service with App Group storage and Watch connectivity
    /// - Parameter appGroupIdentifier: Your app group identifier
    /// - Returns: Configured DataSyncService instance with Watch support
    public static func createWithWatch(appGroupIdentifier: String) -> DataSyncService {
        createWithWatch(appGroupIdentifier: appGroupIdentifier, options: .default)
    }

    /// Creates a sync service with App Group storage and Watch connectivity options.
    /// - Parameters:
    ///   - appGroupIdentifier: Your app group identifier
    ///   - options: Watch sync options controlling transport/fallback behavior
    /// - Returns: Configured DataSyncService instance with Watch support
    public static func createWithWatch(
        appGroupIdentifier: String,
        options: WatchSyncOptions
    ) -> DataSyncService {
        let storage = AppGroupFileStorageService(appGroupIdentifier: appGroupIdentifier)
        let watchService = WatchConnectivityServiceImpl()
        let watchSyncService = WatchSyncServiceImpl(connectivityService: watchService, options: options)
        watchSyncService.activate()

        return DataSyncServiceImpl(storage: storage, watchSyncService: watchSyncService)
    }
    #endif
} 