import Foundation
import SwapFoundationKit

/// An `AnalyticsLogger` implementation that forwards events to a host's Firebase Analytics setup.
///
/// The handlers are required so an opt-in product cannot silently discard analytics when the host
/// chooses a different Firebase package layout. Each closure should call the corresponding
/// Firebase API in the host application.
///
/// ## Usage
/// ```swift
/// let firebaseLogger = SFKFirebaseLogger(
///     userIdentificationHandler: { hostFirebaseSetUserID($0) },
///     eventHandler: { hostFirebaseLog($0, $1) },
///     userPropertyHandler: { hostFirebaseSetProperty($0, $1) },
///     screenHandler: { hostFirebaseTrackScreen($0, $1) }
/// )
/// let analytics = AnalyticsManager()
/// analytics.addLogger(firebaseLogger)
/// ```
public final class SFKFirebaseLogger: AnalyticsLogger {

    private let setupHandler: (() -> Void)?
    private let userIdentificationHandler: (String) -> Void
    private let eventHandler: (any AnalyticsEvent, [String: String]?) -> Void
    private let userPropertyHandler: (String, String) -> Void
    private let screenHandler: (String, [String: String]?) -> Void

    /// Creates a Firebase logger.
    /// - Parameters:
    ///   - setupHandler: Optional closure called during `setup()` to set user properties.
    ///   - userIdentificationHandler: Closure called to set the Firebase user ID.
    public init(
        setupHandler: (() -> Void)? = nil,
        userIdentificationHandler: @escaping (String) -> Void,
        eventHandler: @escaping (any AnalyticsEvent, [String: String]?) -> Void,
        userPropertyHandler: @escaping (String, String) -> Void,
        screenHandler: @escaping (String, [String: String]?) -> Void
    ) {
        self.setupHandler = setupHandler
        self.userIdentificationHandler = userIdentificationHandler
        self.eventHandler = eventHandler
        self.userPropertyHandler = userPropertyHandler
        self.screenHandler = screenHandler
    }

    public func setup() {
        setupHandler?()
    }

    public func logEvent(event: any AnalyticsEvent, additionalParameters: [String: String]?) {
        eventHandler(event, additionalParameters)
    }

    public func setUserProperty(key: String, value: String) {
        userPropertyHandler(key, value)
    }

    public func identifyUser(userId: String) {
        userIdentificationHandler(userId)
    }

    public func trackScreen(screenName: String, parameters: [String: String]?) {
        screenHandler(screenName, parameters)
    }
}
