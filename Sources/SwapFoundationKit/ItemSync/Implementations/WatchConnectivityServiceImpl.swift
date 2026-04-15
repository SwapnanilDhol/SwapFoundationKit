/*****************************************************************************
 * WatchConnectivityServiceImpl.swift
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
    private enum PayloadKey {
        static let data = "data"
    }

    private let payloadSubject = PassthroughSubject<WatchConnectivityPayload, Never>()
    
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
    
    public func sendData(
        _ data: Data,
        preferredTransport: WatchSyncTransport = .applicationContext,
        fallbackTransports: [WatchSyncTransport] = [.userInfo, .messageData, .file],
        maxInlinePayloadBytes: Int = 50_000
    ) throws {
        guard session.activationState == .activated else {
            throw WatchConnectivityError.sessionNotActivated
        }

        let transports = [preferredTransport] + fallbackTransports
        var lastError: Error?

        for transport in transports {
            do {
                try trySend(data, transport: transport, maxInlinePayloadBytes: maxInlinePayloadBytes)
                return
            } catch {
                lastError = error
            }
        }

        if let lastError {
            if let connectivityError = lastError as? WatchConnectivityError {
                throw connectivityError
            }
            throw WatchConnectivityError.sendFailed(lastError)
        }

        throw WatchConnectivityError.sendFailed(NSError(
            domain: "SwapFoundationKit.WatchConnectivityService",
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: "No transport available for watch payload delivery."]
        ))
    }

    private func trySend(_ data: Data, transport: WatchSyncTransport, maxInlinePayloadBytes: Int) throws {
        switch transport {
        case .applicationContext:
            do {
                try session.updateApplicationContext([PayloadKey.data: data])
            } catch {
                throw WatchConnectivityError.sendFailed(error)
            }
        case .userInfo:
            _ = session.transferUserInfo([PayloadKey.data: data])
        case .messageData:
            guard session.isReachable else {
                throw WatchConnectivityError.watchNotReachable
            }
            session.sendMessageData(data, replyHandler: nil) { error in
                Logger.error("WatchConnectivityService sendMessageData failed: \(error.localizedDescription)")
            }
        case .file:
            let fileManager = FileManager.default
            let tempDir = fileManager.temporaryDirectory
            let fileURL = tempDir.appendingPathComponent(UUID().uuidString).appendingPathExtension("json")
            do {
                // File transfer is more resilient for large payloads or unreachable watch.
                _ = maxInlinePayloadBytes // Maintains API symmetry with inline transports.
                try data.write(to: fileURL, options: .atomic)
                _ = session.transferFile(fileURL, metadata: nil)
            } catch {
                throw WatchConnectivityError.sendFailed(error)
            }
        }
    }

    public var payloadReceivedPublisher: AnyPublisher<WatchConnectivityPayload, Never> {
        payloadSubject.eraseToAnyPublisher()
    }

    public var dataReceivedPublisher: AnyPublisher<Data, Never> {
        payloadReceivedPublisher
            .map(\.data)
            .eraseToAnyPublisher()
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
        guard let data = applicationContext[PayloadKey.data] as? Data else { return }
        payloadSubject.send(.init(data: data, transport: .applicationContext))
    }

    public func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) {
        guard let data = userInfo[PayloadKey.data] as? Data else { return }
        payloadSubject.send(.init(data: data, transport: .userInfo))
    }

    public func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        payloadSubject.send(.init(data: messageData, transport: .messageData))
    }

    public func session(_ session: WCSession, didReceive file: WCSessionFile) {
        guard let data = try? Data(contentsOf: file.fileURL) else { return }
        payloadSubject.send(.init(data: data, transport: .file))
    }
}
#endif 