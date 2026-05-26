/*****************************************************************************
 * SFKPulseService.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import Foundation
#if canImport(Pulse)
import Pulse
#endif
#if canImport(PulseProxy)
import PulseProxy
#endif

internal protocol SFKURLSessionPerforming {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: SFKURLSessionPerforming {}

#if canImport(Pulse)
extension URLSessionProxy: SFKURLSessionPerforming {}
#endif

/// Controls how Pulse captures network requests emitted by SFK and the host app.
public enum SFKPulseNetworkCaptureMode: Sendable {
    /// Capture no network traffic.
    case disabled
    /// Capture only requests executed by `HTTPClient`.
    case sfkHTTPClientOnly
    /// Capture `HTTPClient` requests and, in debug builds, attempt to capture all `URLSession` traffic using PulseProxy.
    case debugProxyAllURLSessions
}

/// Controls where Pulse stores logs.
public enum SFKPulseStoreLocation: Sendable {
    /// Use Pulse's shared default store location.
    case shared
    /// Use a custom Pulse store directory.
    case custom(URL)
}

/// Configuration for enabling Pulse inside SwapFoundationKit.
public struct SFKPulseConfiguration: Sendable {
    public var storeLocation: SFKPulseStoreLocation
    public var networkCaptureMode: SFKPulseNetworkCaptureMode
    public var sizeLimitBytes: Int64?
    public var enableRemoteLogging: Bool
    public var sensitiveHeaders: Set<String>
    public var sensitiveQueryItems: Set<String>
    public var sensitiveBodyFields: Set<String>

    public init(
        storeLocation: SFKPulseStoreLocation = .shared,
        networkCaptureMode: SFKPulseNetworkCaptureMode = .sfkHTTPClientOnly,
        sizeLimitBytes: Int64? = nil,
        enableRemoteLogging: Bool = false,
        sensitiveHeaders: Set<String> = ["Authorization", "Cookie", "Set-Cookie", "X-API-Key", "Proxy-Authorization"],
        sensitiveQueryItems: Set<String> = [],
        sensitiveBodyFields: Set<String> = []
    ) {
        self.storeLocation = storeLocation
        self.networkCaptureMode = networkCaptureMode
        self.sizeLimitBytes = sizeLimitBytes
        self.enableRemoteLogging = enableRemoteLogging
        self.sensitiveHeaders = sensitiveHeaders
        self.sensitiveQueryItems = sensitiveQueryItems
        self.sensitiveBodyFields = sensitiveBodyFields
    }
}

/// SwapFoundationKit integration layer for Pulse logging and in-app inspection.
public enum SFKPulseService {
    private static let lock = NSLock()
    private static var isConfigured = false
    private static var configuration = SFKPulseConfiguration()

    public static var isEnabled: Bool {
        lock.withLock {
            isConfigured
        }
    }

    public static var currentConfiguration: SFKPulseConfiguration? {
        lock.withLock {
            isConfigured ? configuration : nil
        }
    }

    /// Enables Pulse for SFK logs and networking.
    public static func configure(_ configuration: SFKPulseConfiguration = .init()) {
        #if canImport(Pulse)
        let store = makeStore(for: configuration.storeLocation)

        if let sizeLimitBytes = configuration.sizeLimitBytes {
            store.configuration.sizeLimit = sizeLimitBytes
        }

        LoggerStore.shared = store
        NetworkLogger.shared = NetworkLogger(store: store) {
            $0.sensitiveHeaders = configuration.sensitiveHeaders
            $0.sensitiveQueryItems = configuration.sensitiveQueryItems
            $0.sensitiveDataFields = configuration.sensitiveBodyFields
        }

        #if DEBUG
        if configuration.enableRemoteLogging {
            Task { @MainActor in
                RemoteLogger.shared.isAutomaticConnectionEnabled = true
            }
        }
        #if canImport(PulseProxy)
        if configuration.networkCaptureMode == .debugProxyAllURLSessions {
            NetworkLogger.enableProxy(logger: NetworkLogger.shared)
        }
        #endif
        #endif

        lock.withLock {
            self.configuration = configuration
            self.isConfigured = true
        }
        #else
        lock.withLock {
            self.configuration = configuration
            self.isConfigured = false
        }
        #endif
    }

    internal static func makeSession(configuration: URLSessionConfiguration) -> (session: URLSession, performer: any SFKURLSessionPerforming) {
        #if canImport(Pulse)
        let pulseConfiguration = lock.withLock {
            isConfigured ? self.configuration : nil
        }
        let captureMode = pulseConfiguration?.networkCaptureMode ?? .disabled

        switch captureMode {
        case .disabled:
            let session = URLSession(configuration: configuration)
            return (session, session)
        case .sfkHTTPClientOnly, .debugProxyAllURLSessions:
            let proxy = URLSessionProxy(configuration: configuration, logger: NetworkLogger.shared)
            return (proxy.session, proxy)
        }
        #else
        let session = URLSession(configuration: configuration)
        return (session, session)
        #endif
    }

    internal static func recordMessage(
        level: LogLevel,
        message: String,
        context: String?,
        function: String,
        file: String,
        line: Int
    ) {
        #if canImport(Pulse)
        guard isEnabled else { return }

        LoggerStore.shared.storeMessage(
            label: context ?? "SFK",
            level: pulseLevel(for: level),
            message: message,
            metadata: [
                "context": .string(context ?? ""),
                "source": .string("SwapFoundationKit")
            ],
            file: file,
            function: function,
            line: UInt(line)
        )
        #endif
    }

    #if canImport(Pulse)
    private static func makeStore(for location: SFKPulseStoreLocation) -> LoggerStore {
        switch location {
        case .shared:
            return LoggerStore.shared
        case .custom(let url):
            do {
                return try LoggerStore(storeURL: url, options: [.create, .sweep])
            } catch {
                Logger.error("Failed to open custom Pulse store at \(url.path): \(error.localizedDescription)", context: "Pulse")
                return LoggerStore.shared
            }
        }
    }

    private static func pulseLevel(for level: LogLevel) -> LoggerStore.Level {
        switch level {
        case .debug:
            return .debug
        case .info:
            return .info
        case .warning:
            return .warning
        case .error:
            return .error
        }
    }
    #endif
}

private extension NSLock {
    func withLock<T>(_ operation: () -> T) -> T {
        lock()
        defer { unlock() }
        return operation()
    }
}
