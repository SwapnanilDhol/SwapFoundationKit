/*****************************************************************************
 * AnalyticsProtocol.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import Foundation

/// Protocol for analytics tracking
public protocol AnalyticsLogger {
    func setup()
    func logEvent(event: AnalyticsEvent, additionalParameters: [String: String]?)
}

extension AnalyticsLogger {
    func setup() {
        // Default Implementation since a lot of loggers might be setup out of the box
    }
}

/// Protocol for analytics events
public protocol AnalyticsEvent {
    var rawValue: String { get }
    var parameters: [String: String]? { get }
}

/// Default implementation for analytics events
public extension AnalyticsEvent {
    var parameters: [String: String]? {
        return nil
    }
}

/// Analytics manager for handling tracking across different services
/// Type-erased analytics logger that can wrap any concrete logger
/// Analytics manager for handling tracking across different services
public final class AnalyticsManager: @unchecked Sendable {
    public static let shared = AnalyticsManager()
    private var loggers: [any AnalyticsLogger] = []
    private var globalParameters: [String: String] = [:]

    private init() {}

    public func addLogger(_ logger: any AnalyticsLogger) {
        loggers.append(logger)
    }

    public func start() {
        loggers.forEach { $0.setup() }
    }

    public func setGlobalParameters(_ parameters: [String: String]) {
        globalParameters = parameters
    }

    public func clearGlobalParameters() {
        globalParameters = [:]
    }

    public func logEvent(event: AnalyticsEvent, parameters: [String: String]? = nil) {
        // Merge precedence: event defaults < global parameters < call-site
        let eventParameters = event.parameters ?? [:]
        let callSiteParameters = parameters ?? [:]
        let merged = eventParameters
            .merging(globalParameters) { _, new in new }
            .merging(callSiteParameters) { _, new in new }

        for logger in loggers {
            logger.logEvent(event: event, additionalParameters: merged.isEmpty ? nil : merged)
        }
    }

    public func setupAnalytics() {
        // Override in app to configure providers
    }
}

/// Default analytics event for common tracking
public struct DefaultAnalyticsEvent: AnalyticsEvent {
    public let rawValue: String
    public let parameters: [String: String]?
    
    public init(name: String, parameters: [String: String]? = nil) {
        self.rawValue = name
        self.parameters = parameters
    }
}
