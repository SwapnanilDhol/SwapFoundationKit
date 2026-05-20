import Foundation

#if canImport(PostHog)
import PostHog
#endif

/// An `AnalyticsLogger` implementation that forwards events to PostHog.
///
/// Uses `#if canImport(PostHog)` so this file compiles even when
/// the PostHog dependency is not linked. Supports session replay,
/// feature flags, and user identification.
///
/// ## Usage
/// ```swift
/// let postHogLogger = SFKPostHogLogger(apiKey: "phc_...", host: "https://us.i.posthog.com")
/// AnalyticsManager.shared.addLogger(postHogLogger)
/// ```
public final class SFKPostHogLogger: AnalyticsLogger {

    private let apiKey: String
    private let host: String

    /// Creates a PostHog logger.
    /// - Parameters:
    ///   - apiKey: The PostHog project API key.
    ///   - host: The PostHog host URL (default: `"https://us.i.posthog.com"`).
    public init(apiKey: String, host: String = "https://us.i.posthog.com") {
        self.apiKey = apiKey
        self.host = host
    }

    public func setup() {
        #if canImport(PostHog)
        guard !apiKey.isEmpty else {
            Logger.info(
                "PostHog API key is empty. Skipping setup.",
                context: "Analytics"
            )
            return
        }

        let config = PostHogConfig(apiKey: apiKey, host: host)
        config.captureApplicationLifecycleEvents = true
        config.captureScreenViews = false
        config.sessionReplay = true
        config.debug = SFKAppEnvironment.current.isDebug

        PostHogSDK.shared.setup(config)
        #endif
    }

    public func logEvent(event: any AnalyticsEvent, additionalParameters: [String: String]?) {
        #if canImport(PostHog)
        var payload: [String: Any] = additionalParameters ?? [:]
        payload["event_name"] = event.rawValue
        PostHogSDK.shared.capture(event.rawValue, properties: payload)
        #endif
    }

    public func setUserProperty(key: String, value: String) {
        #if canImport(PostHog)
        let distinctId = PostHogSDK.shared.getDistinctId()
        PostHogSDK.shared.identify(distinctId, userProperties: [key: value])
        PostHogSDK.shared.setPersonPropertiesForFlags([key: value], reloadFeatureFlags: false)
        #endif
    }

    public func identifyUser(userId: String) {
        #if canImport(PostHog)
        PostHogSDK.shared.identify(userId, userProperties: nil)
        #endif
    }

    public func setUserProperties(_ properties: [String: String]) {
        #if canImport(PostHog)
        guard !properties.isEmpty else { return }
        let sanitized = properties.reduce(into: [String: Any]()) { partialResult, entry in
            partialResult[entry.key] = entry.value
        }
        let distinctId = PostHogSDK.shared.getDistinctId()
        PostHogSDK.shared.identify(distinctId, userProperties: sanitized)
        PostHogSDK.shared.setPersonPropertiesForFlags(sanitized, reloadFeatureFlags: true)
        #endif
    }

    public func trackScreen(screenName: String, parameters: [String: String]?) {
        #if canImport(PostHog)
        var payload: [String: Any] = parameters ?? [:]
        payload["screen_name"] = screenName
        PostHogSDK.shared.capture("$screen", properties: payload)
        #endif
    }

    public func featureFlagValue(key: String) -> String? {
        #if canImport(PostHog)
        let value = PostHogSDK.shared.getFeatureFlag(key)
        if let stringValue = value as? String {
            return stringValue
        }
        if let boolValue = value as? Bool {
            return boolValue ? "true" : "false"
        }
        #endif
        return nil
    }

    public func isFeatureEnabled(key: String, sendFeatureFlagEvent: Bool = true) -> Bool {
        #if canImport(PostHog)
        return PostHogSDK.shared.isFeatureEnabled(key, sendFeatureFlagEvent: sendFeatureFlagEvent)
        #else
        return false
        #endif
    }
}
