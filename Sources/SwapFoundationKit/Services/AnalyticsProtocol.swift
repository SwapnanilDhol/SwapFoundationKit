import Foundation

/// Protocol for analytics tracking
public protocol AnalyticsLogger {
    func logEvent(event: AnalyticsEvent, additionalParameters: [String: String]?)
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

    private init() {}

    public func addLogger(_ logger: any AnalyticsLogger) {
        loggers.append(logger)
    }

    public func logEvent(event: AnalyticsEvent, parameters: [String: String]? = nil) {
        // Merge event.parameters with additional parameters; additional overrides defaults
        var merged: [String: String]? = event.parameters
        if let extras = parameters {
            if merged == nil { merged = [:] }
            for (k, v) in extras { merged![k] = v }
        }
        for logger in loggers {
            logger.logEvent(event: event, additionalParameters: merged)
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
