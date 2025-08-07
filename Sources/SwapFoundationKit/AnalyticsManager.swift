/*****************************************************************************
 * AnalyticsManager.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import Foundation
import UIKit
import Network
#if canImport(CoreTelephony)
import CoreTelephony
#endif

// MARK: - AnalyticsEvent Protocol
/// Protocol for analytics events. Define your events in your app using this protocol.
public protocol AnalyticsEvent: Sendable {
    var name: String { get }
    var parameters: [String: any Sendable] { get }
}

// MARK: - Sendable wrapper for telemetry data
public struct TelemetryData: Sendable {
    public let data: [String: any Sendable]

    public init(_ data: [String: any Sendable]) {
        self.data = data
    }

    /// Convert to [String: Any] for compatibility with existing APIs
    public var dictionary: [String: Any] {
        data.mapValues { $0 as Any }
    }
}

// MARK: - AnalyticsManager
/// Advanced analytics manager with batching, context, and extensibility.
public actor AnalyticsManager {
    public static let shared = AnalyticsManager()
    private init() {}

    // MARK: - Public API

    /// Set this closure in your app to send telemetry to your analytics provider(s).
    /// The closure receives the event and merged parameters as TelemetryData.
    public var sendTelemetry: (@Sendable (AnalyticsEvent, TelemetryData) -> Void)?

    /// Whether analytics is enabled (can be toggled for privacy).
    public var isEnabled: Bool = true

    /// The interval (seconds) at which to automatically flush events. Set to 0 to disable auto-flush.
    public var flushInterval: TimeInterval = 10.0 {
        didSet { Task { await restartFlushTimer() } }
    }

    /// The maximum number of events to batch before flushing.
    public var maxBatchSize: Int = 20

    /// Set user properties (e.g., userId, plan, etc.).
    public var userProperties: [String: any Sendable] = [:]

    /// Set session properties (e.g., sessionId, experiment group, etc.).
    public var sessionProperties: [String: any Sendable] = [:]

    /// Log an event. Thread-safe, will batch and flush as needed.
    public func logEvent(_ event: AnalyticsEvent) async {
        guard isEnabled else { return }
        eventBuffer.append(event)
        if eventBuffer.count >= maxBatchSize {
            await flush()
        }
    }

    /// Manually flushes the event buffer (sends all batched events).
    public func flush() async {
        guard !eventBuffer.isEmpty else { return }
        let eventsToSend = eventBuffer
        eventBuffer.removeAll()
        for event in eventsToSend {
            let payload = await mergedPayload(for: event)
            sendTelemetry?(event, payload)
        }
    }

    /// Call this to clear all batched events (without sending).
    public func clearBuffer() {
        eventBuffer.removeAll()
    }

    /// Call this to set a custom dispatch queue for testing or advanced use. (No-op for actor)
    public func setQueue(_ newQueue: DispatchQueue) {}

    // MARK: - Private

    private var eventBuffer: [AnalyticsEvent] = []

    @MainActor
    private var flushTimer: Timer?

    private func mergedPayload(for event: AnalyticsEvent) async -> TelemetryData {
        var payload: [String: any Sendable] = event.parameters
        // Add user/session properties
        for (k, v) in userProperties { payload["user_\(k)"] = v }
        for (k, v) in sessionProperties { payload["session_\(k)"] = v }
        // Add context
        let context = await AnalyticsManager.telemetryContext()
        for (k, v) in context.data { payload[k] = v }
        payload["event_name"] = event.name
        payload["event_timestamp"] = Date().iso8601String
        return TelemetryData(payload)
    }

    private func restartFlushTimer() async {
        let interval = flushInterval // capture actor-isolated property before MainActor.run
        await MainActor.run { [weak self] in
            guard let self else { return }
            self.flushTimer?.invalidate()
            self.flushTimer = nil
            guard interval > 0 else { return }
            let timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
                Task { await self.flush() }
            }
            self.flushTimer = timer
#if os(iOS) || os(tvOS)
            RunLoop.main.add(timer, forMode: .common)
#endif
        }
    }

    // MARK: - Context
    /// Gathers device, OS, app, screen, battery, accessibility, system, and network context for telemetry.
    public static func telemetryContext() async -> TelemetryData {
        var context: [String: any Sendable] = [:]
        let bundle = Bundle.main
        // --- App Info ---
        context["app_bundle_id"] = bundle.bundleIdentifier
        context["app_display_name"] = bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ??
        bundle.object(forInfoDictionaryKey: "CFBundleName") as? String ?? ""
#if DEBUG
        context["app_build_type"] = "debug"
#else
        context["app_build_type"] = "release"
#endif
        // Install/update date
        if let url = bundle.bundleURL as URL?,
           let attrs = try? FileManager.default.attributesOfItem(atPath: url.path) {
            if let installDate = attrs[.creationDate] as? Date {
                context["app_install_date"] = installDate.iso8601String
            }
            if let updateDate = attrs[.modificationDate] as? Date {
                context["app_update_date"] = updateDate.iso8601String
            }
        }
        // --- Device Info ---
#if canImport(UIKit)
        let deviceInfo = await MainActor.run { () -> [String: any Sendable] in
            var dict: [String: any Sendable] = [:]
            let device = UIDevice.current
            dict["device_model"] = device.model
            dict["device_name"] = device.name
            dict["system_name"] = device.systemName
            dict["system_version"] = device.systemVersion
            dict["is_simulator"] = {
#if targetEnvironment(simulator)
                return true
#else
                return false
#endif
            }()
            dict["device_type"] = device.userInterfaceIdiom == .pad ? "iPad" : device.userInterfaceIdiom == .phone ? "iPhone" : "other"
            dict["device_orientation"] = device.orientation.isPortrait ? "portrait" : device.orientation.isLandscape ? "landscape" : "unknown"
            // --- Screen Info ---
            let screen = UIScreen.main
            dict["screen_width"] = screen.bounds.width
            dict["screen_height"] = screen.bounds.height
            dict["screen_scale"] = screen.scale
            // --- Battery Info ---
            device.isBatteryMonitoringEnabled = true
            dict["battery_level"] = device.batteryLevel
            dict["battery_state"] = {
                switch device.batteryState {
                case .charging: return "charging"
                case .full: return "full"
                case .unplugged: return "unplugged"
                default: return "unknown"
                }
            }()
            // --- Accessibility ---
            dict["is_voiceover_running"] = UIAccessibility.isVoiceOverRunning
            dict["is_reduced_motion_enabled"] = UIAccessibility.isReduceMotionEnabled
            dict["is_dark_mode_enabled"] = UIScreen.main.traitCollection.userInterfaceStyle == .dark
            // --- App State ---
            let state: String
            switch UIApplication.shared.applicationState {
            case .active: state = "active"
            case .background: state = "background"
            case .inactive: state = "inactive"
            @unknown default: state = "unknown"
            }
            dict["app_state"] = state
            return dict
        }
        for (k, v) in deviceInfo { context[k] = v }
#endif
        // --- System Info ---
        context["os"] = ProcessInfo.processInfo.operatingSystemVersionString
        context["locale"] = Locale.current.identifier
        context["timezone"] = TimeZone.current.identifier
        context["timestamp"] = Date().iso8601String
        // --- Disk/Memory Info ---
        if let attrs = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory()) {
            if let free = attrs[.systemFreeSize] as? NSNumber {
                context["free_disk_space"] = free.int64Value
            }
            if let total = attrs[.systemSize] as? NSNumber {
                context["total_disk_space"] = total.int64Value
            }
        }
        // --- Network Info ---
#if canImport(Network)
        let networkInfo = await withCheckedContinuation { (continuation: CheckedContinuation<(String, Bool), Never>) in
            let monitor = NWPathMonitor()
            let queue = DispatchQueue(label: "NetworkMonitor")

            monitor.pathUpdateHandler = { path in
                let networkType: String
                if path.usesInterfaceType(.wifi) { networkType = "wifi" }
                else if path.usesInterfaceType(.cellular) { networkType = "cellular" }
                else if path.usesInterfaceType(.wiredEthernet) { networkType = "ethernet" }
                else if path.usesInterfaceType(.loopback) { networkType = "loopback" }
                else if path.usesInterfaceType(.other) { networkType = "other" }
                else { networkType = "unknown" }

                let isVPN = path.status == .satisfied && path.availableInterfaces.contains(where: { $0.type == .other })

                monitor.cancel()
                continuation.resume(returning: (networkType, isVPN))
            }

            monitor.start(queue: queue)

            // Timeout after 100ms
            queue.asyncAfter(deadline: .now() + 0.1) {
                monitor.cancel()
                continuation.resume(returning: ("unknown", false))
            }
        }
        context["network_type"] = networkInfo.0
        context["is_vpn_active"] = networkInfo.1
#endif
        return TelemetryData(context)
    }
}

// MARK: - AnalyticsManager Configuration
public extension AnalyticsManager {
    func setUserProperties(_ properties: [String: any Sendable]) {
        self.userProperties = properties
    }

    func setSendTelemetry(_ closure: @escaping @Sendable (AnalyticsEvent, TelemetryData) -> Void) {
        self.sendTelemetry = closure
    }
}

// MARK: - Example Usage (in your app, not the framework)
/*
 public enum AppAnalyticsEvent: AnalyticsEvent {
 case appLaunched
 case userSignedIn(userId: String)
 case purchase(amount: Double, currency: String)
 // ...add more

 public var name: String {
 switch self {
 case .appLaunched: return "app_launched"
 case .userSignedIn: return "user_signed_in"
 case .purchase: return "purchase"
 }
 }
 public var parameters: [String: any Sendable] {
 switch self {
 case .appLaunched: return [:]
 case .userSignedIn(let userId): return ["user_id": userId]
 case .purchase(let amount, let currency): return ["amount": amount, "currency": currency]
 }
 }
 }

 // In your app's startup code:
 // await AnalyticsManager.shared.logEvent(AppAnalyticsEvent.userSignedIn(userId: "123"))
 */
