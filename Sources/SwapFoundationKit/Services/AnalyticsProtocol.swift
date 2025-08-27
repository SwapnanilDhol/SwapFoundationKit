import Foundation

/// Protocol for analytics tracking
public protocol AnalyticsLogger {
    func logEvent(event: AnalyticsEvent, parameters: [String: String]?)
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
public final class AnalyticsManager: AnalyticsLogger, @unchecked Sendable {
    public static let shared = AnalyticsManager()
    private var loggers: [any AnalyticsLogger] = []

    private init() {}
    
    public func addLogger(_ logger: any AnalyticsLogger) {
        loggers.append(logger)
    }
    
    public func logEvent(event: AnalyticsEvent, parameters: [String: String]? = nil) {
        for logger in loggers {
            logger.logEvent(event: event, parameters: parameters)
        }
    }
    
    public func setupAnalytics() {
        // Override in subclasses or implementations
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
