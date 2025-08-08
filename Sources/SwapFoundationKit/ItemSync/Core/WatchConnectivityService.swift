//
//  WatchConnectivityService.swift
//  SwapFoundationKit
//
//  Created by Swapnanil Dhol on 1/11/25.
//

import Foundation
import Combine

/// Protocol for Watch connectivity operations
/// This allows for optional Watch data synchronization
///
/// ## Usage Example
/// ```swift
/// #if os(iOS)
/// // Create Watch connectivity service
/// let watchService = WatchConnectivityServiceImpl()
/// watchService.activate()
///
/// // Use with sync service
/// let syncService = DataSyncServiceImpl(
///     storage: AppGroupFileStorageService(appGroupIdentifier: "group.com.yourapp.widget"),
///     watchConnectivity: watchService
/// )
/// #endif
/// ```
public protocol WatchConnectivityService {
    /// Activates the Watch connectivity session
    func activate()
    
    /// Checks if the Watch is reachable
    var isReachable: Bool { get }
    
    /// Sends data to the Watch
    /// - Parameter data: The data to send
    /// - Throws: WatchConnectivityError if the operation fails
    func sendData(_ data: Data) throws
    
    /// Publisher that emits when data is received from the Watch
    var dataReceivedPublisher: AnyPublisher<Data, Never> { get }
}

// MARK: - Errors

/// Errors that can occur during Watch connectivity operations
public enum WatchConnectivityError: LocalizedError {
    case sessionNotActivated
    case watchNotReachable
    case sendFailed(Error)
    case receiveFailed(Error)
    
    public var errorDescription: String? {
        switch self {
        case .sessionNotActivated:
            return "Watch connectivity session is not activated"
        case .watchNotReachable:
            return "Watch is not reachable"
        case .sendFailed(let error):
            return "Failed to send data to Watch: \(error.localizedDescription)"
        case .receiveFailed(let error):
            return "Failed to receive data from Watch: \(error.localizedDescription)"
        }
    }
} 