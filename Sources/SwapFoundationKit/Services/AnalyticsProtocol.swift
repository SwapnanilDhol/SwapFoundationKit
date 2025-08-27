import Foundation

/// Protocol for analytics tracking
public protocol AnalyticsLogger {
    associatedtype T: AnalyticsEvent
    func logEvent(event: T, parameters: [String: String]?)
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
public struct AnyAnalyticsLogger {
    private let _log: (AnalyticsEvent, [String: String]?) -> Void

    public init<L: AnalyticsLogger>(_ logger: L) {
        self._log = { event, parameters in
            if let typedEvent = event as? L.T {
                logger.logEvent(event: typedEvent, parameters: parameters)
            }
        }
    }

    public func logEvent(event: AnalyticsEvent, parameters: [String: String]? = nil) {
        _log(event, parameters)
    }
}

/// Analytics manager for handling tracking across different services
public final class AnalyticsManager: @unchecked Sendable {
    public static let shared = AnalyticsManager()
    private var loggers: [AnyAnalyticsLogger] = []

    private init() {}

    public func addLogger<L: AnalyticsLogger>(_ logger: L) {
        loggers.append(AnyAnalyticsLogger(logger))
    }

    public func logEvent(event: AnalyticsEvent, parameters: [String: String]? = nil) {
        for logger in loggers {
            logger.logEvent(event: event, parameters: parameters)
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
