import Foundation

#if canImport(TelemetryClient)
import TelemetryClient
#endif

/// An `AnalyticsLogger` implementation that forwards events to TelemetryDeck.
///
/// Uses `#if canImport(TelemetryClient)` so this file compiles even when
/// the TelemetryDeck dependency is not linked.
///
/// ## Usage
/// ```swift
/// let telemetryLogger = SFKTelemetryLogger(appID: "your-telemetry-app-id")
/// AnalyticsManager.shared.addLogger(telemetryLogger)
/// ```
public final class SFKTelemetryLogger: AnalyticsLogger {

    private let appID: String

    /// Creates a TelemetryDeck logger.
    /// - Parameter appID: The TelemetryDeck application ID.
    public init(appID: String) {
        self.appID = appID
    }

    public func setup() {
        #if canImport(TelemetryClient)
        guard !TelemetryManager.isInitialized else { return }
        let configuration = TelemetryManagerConfiguration(appID: appID)
        TelemetryDeck.initialize(config: configuration)
        #endif
    }

    public func logEvent(event: any AnalyticsEvent, additionalParameters: [String: String]?) {
        #if canImport(TelemetryClient)
        guard TelemetryManager.isInitialized else { return }
        TelemetryDeck.signal(event.rawValue, parameters: additionalParameters ?? [:])
        #endif
    }
}
