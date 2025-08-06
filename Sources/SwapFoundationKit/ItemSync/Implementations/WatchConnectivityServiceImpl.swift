//
//  WatchConnectivityServiceImpl.swift
//  SwapFoundationKit
//
//  Created by Swapnanil Dhol on 1/11/25.
//

import Foundation
import Combine
#if canImport(WatchConnectivity)
import WatchConnectivity
#endif

/// iOS-specific implementation of WatchConnectivityService using WCSession
/// This service handles communication between your iOS app and Watch app
///
/// ## Usage Example
/// ```swift
/// #if os(iOS)
/// let watchService = WatchConnectivityServiceImpl()
/// watchService.activate()
///
/// // The service will automatically handle sending/receiving data
/// // when used with DataSyncServiceImpl
/// #endif
/// ```
#if os(iOS)
public final class WatchConnectivityServiceImpl: NSObject, WatchConnectivityService {
    
    // MARK: - Properties
    
    private let session: WCSession
    private let dataSubject = PassthroughSubject<Data, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    /// Creates a new Watch connectivity service
    /// - Parameter session: WCSession instance (defaults to .default)
    public init(session: WCSession = .default) {
        self.session = session
        super.init()
    }
    
    // MARK: - WatchConnectivityService Implementation
    
    public func activate() {
        guard WCSession.isSupported() else { return }
        
        session.delegate = self
        session.activate()
    }
    
    public var isReachable: Bool {
        return session.isReachable
    }
    
    public func sendData(_ data: Data) throws {
        guard session.activationState == .activated else {
            throw WatchConnectivityError.sessionNotActivated
        }
        
        guard session.isReachable else {
            throw WatchConnectivityError.watchNotReachable
        }
        
        do {
            try session.updateApplicationContext(["data": data])
        } catch {
            throw WatchConnectivityError.sendFailed(error)
        }
    }
    
    public var dataReceivedPublisher: AnyPublisher<Data, Never> {
        dataSubject.eraseToAnyPublisher()
    }
}

// MARK: - WCSessionDelegate

extension WatchConnectivityServiceImpl: WCSessionDelegate {
    
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // Activation completed
    }
    
    public func sessionDidBecomeInactive(_ session: WCSession) {
        // Session became inactive
    }
    
    public func sessionDidDeactivate(_ session: WCSession) {
        // Session deactivated
    }
    
    public func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        if let data = applicationContext["data"] as? Data {
            dataSubject.send(data)
        }
    }
}
#endif 