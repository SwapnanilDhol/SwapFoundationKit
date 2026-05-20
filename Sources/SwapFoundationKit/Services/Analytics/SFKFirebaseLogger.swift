import Foundation

#if canImport(FirebaseAnalytics)
import FirebaseAnalytics
#endif

/// An `AnalyticsLogger` implementation that forwards events to Firebase Analytics.
///
/// Uses `#if canImport(FirebaseAnalytics)` so this file compiles even when
/// the Firebase dependency is not linked.
///
/// ## Usage
/// ```swift
/// let firebaseLogger = SFKFirebaseLogger()
/// AnalyticsManager.shared.addLogger(firebaseLogger)
/// ```
public final class SFKFirebaseLogger: AnalyticsLogger {

    private let setupHandler: (() -> Void)?
    private let userIdentificationHandler: ((String) -> Void)?

    /// Creates a Firebase logger.
    /// - Parameters:
    ///   - setupHandler: Optional closure called during `setup()` to set user properties.
    ///   - userIdentificationHandler: Optional closure called to set the Firebase user ID.
    public init(
        setupHandler: (() -> Void)? = nil,
        userIdentificationHandler: ((String) -> Void)? = nil
    ) {
        self.setupHandler = setupHandler
        self.userIdentificationHandler = userIdentificationHandler
    }

    public func setup() {
        setupHandler?()
    }

    public func logEvent(event: any AnalyticsEvent, additionalParameters: [String: String]?) {
        #if canImport(FirebaseAnalytics)
        Analytics.logEvent(event.rawValue, parameters: additionalParameters)
        #endif
    }

    public func setUserProperty(key: String, value: String) {
        #if canImport(FirebaseAnalytics)
        Analytics.setUserProperty(value, forName: key)
        #endif
    }

    public func identifyUser(userId: String) {
        #if canImport(FirebaseAnalytics)
        Analytics.setUserID(userId)
        #endif
        userIdentificationHandler?(userId)
    }

    public func trackScreen(screenName: String, parameters: [String: String]?) {
        #if canImport(FirebaseAnalytics)
        var screenParameters: [String: Any] = parameters ?? [:]
        screenParameters["screen_name"] = screenName
        Analytics.logEvent(AnalyticsEventScreenView, parameters: screenParameters)
        #endif
    }
}
