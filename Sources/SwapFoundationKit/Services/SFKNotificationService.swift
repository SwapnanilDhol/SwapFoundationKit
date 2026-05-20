import Foundation
import UserNotifications

/// Generic local notification service wrapping `UNUserNotificationCenter`.
///
/// Provides authorization, posting, badge management, and category registration.
/// App-specific scheduling logic should be built on top of this primitive service.
///
/// ## Usage
/// ```swift
/// // Request authorization
/// let granted = await SFKNotificationService.shared.requestAuthorization()
///
/// // Post a simple notification
/// await SFKNotificationService.shared.post(
///     title: "Reminder",
///     body: "Your subscription renews tomorrow"
/// )
///
/// // Register a category with actions
/// SFKNotificationService.shared.registerCategory(
///     SFKNotificationCategory(
///         identifier: "REMINDER",
///         actions: [
///             SFKNotificationAction(identifier: "VIEW", title: "View", options: .foreground)
///         ]
///     )
/// )
/// ```
public final class SFKNotificationService {

    public static let shared = SFKNotificationService()

    private let notificationCenter = UNUserNotificationCenter.current()

    private init() {}

    // MARK: - Authorization

    /// Requests notification authorization from the user.
    /// - Parameter options: The authorization options (default: alert, badge, sound).
    /// - Returns: `true` if authorization was granted.
    @discardableResult
    public func requestAuthorization(options: UNAuthorizationOptions = [.alert, .badge, .sound]) async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: options)
            return granted
        } catch {
            Logger.error("Failed to request notification authorization: \(error)")
            return false
        }
    }

    /// Asynchronously checks whether notifications are authorized.
    public func hasAuthorization() async -> Bool {
        let status = await checkAuthorizationStatus()
        return status == .authorized || status == .provisional || status == .ephemeral
    }

    /// Returns the current notification authorization status.
    public func checkAuthorizationStatus() async -> UNAuthorizationStatus {
        let settings = await notificationCenter.notificationSettings()
        return settings.authorizationStatus
    }

    // MARK: - Categories

    /// Registers custom notification categories and actions.
    /// - Parameter categories: The categories to register.
    public func registerCategories(_ categories: [SFKNotificationCategory]) {
        let unCategories = categories.map { category in
            let actions = category.actions.map { action in
                UNNotificationAction(
                    identifier: action.identifier,
                    title: action.title,
                    options: action.options
                )
            }
            return UNNotificationCategory(
                identifier: category.identifier,
                actions: actions,
                intentIdentifiers: category.intentIdentifiers,
                options: category.options
            )
        }
        notificationCenter.setNotificationCategories(Set(unCategories))
    }

    // MARK: - Posting

    /// Posts a local notification immediately (fires after 1 second).
    /// - Parameters:
    ///   - title: The notification title.
    ///   - body: The notification body.
    ///   - identifier: Unique identifier for the notification (default: a new UUID).
    ///   - categoryIdentifier: Optional category identifier for actions.
    ///   - userInfo: Optional user info dictionary.
    ///   - sound: Optional sound (default: `.default`).
    /// - Returns: `true` if the notification was scheduled successfully.
    @discardableResult
    public func post(
        title: String,
        body: String,
        identifier: String = UUID().uuidString,
        categoryIdentifier: String? = nil,
        userInfo: [AnyHashable: Any] = [:],
        sound: UNNotificationSound? = .default
    ) async -> Bool {
        guard await hasAuthorization() else {
            Logger.debug("Notifications not authorized, skipping local notification")
            return false
        }

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = sound
        if let categoryIdentifier {
            content.categoryIdentifier = categoryIdentifier
        }
        content.userInfo = userInfo

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        do {
            try await notificationCenter.add(request)
            return true
        } catch {
            Logger.error("Failed to schedule notification: \(error)")
            return false
        }
    }

    /// Schedules a calendar-based notification.
    /// - Parameters:
    ///   - title: The notification title.
    ///   - body: The notification body.
    ///   - identifier: Unique identifier.
    ///   - dateComponents: The date components for the trigger.
    ///   - repeats: Whether to repeat (default: `false`).
    ///   - categoryIdentifier: Optional category identifier.
    ///   - userInfo: Optional user info dictionary.
    public func schedule(
        title: String,
        body: String,
        identifier: String,
        dateComponents: DateComponents,
        repeats: Bool = false,
        categoryIdentifier: String? = nil,
        userInfo: [AnyHashable: Any] = [:]
    ) async {
        guard await hasAuthorization() else { return }

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        if let categoryIdentifier {
            content.categoryIdentifier = categoryIdentifier
        }
        content.userInfo = userInfo

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: repeats)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        do {
            try await notificationCenter.add(request)
        } catch {
            Logger.error("Failed to schedule calendar notification: \(error)")
        }
    }

    // MARK: - Badge

    /// Sets the app icon badge count on the main actor.
    @MainActor
    public func setBadgeCount(_ count: Int) {
        notificationCenter.setBadgeCount(count)
    }

    /// Clears the app icon badge count on the main actor.
    @MainActor
    public func clearBadge() {
        notificationCenter.setBadgeCount(0)
    }

    // MARK: - Removal

    /// Removes all pending notification requests.
    public func removeAllPending() {
        notificationCenter.removeAllPendingNotificationRequests()
    }

    /// Removes all delivered notification requests.
    public func removeAllDelivered() {
        notificationCenter.removeAllDeliveredNotifications()
    }

    /// Removes specific notifications by identifier.
    /// - Parameter identifiers: The notification identifiers to remove.
    public func remove(identifiers: [String]) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
        notificationCenter.removeDeliveredNotifications(withIdentifiers: identifiers)
    }
}

// MARK: - Supporting Types

/// A notification action for use in notification categories.
public struct SFKNotificationAction {
    public let identifier: String
    public let title: String
    public let options: UNNotificationActionOptions

    public init(identifier: String, title: String, options: UNNotificationActionOptions = []) {
        self.identifier = identifier
        self.title = title
        self.options = options
    }
}

/// A notification category grouping related actions.
public struct SFKNotificationCategory {
    public let identifier: String
    public let actions: [SFKNotificationAction]
    public let intentIdentifiers: [String]
    public let options: UNNotificationCategoryOptions

    public init(
        identifier: String,
        actions: [SFKNotificationAction] = [],
        intentIdentifiers: [String] = [],
        options: UNNotificationCategoryOptions = []
    ) {
        self.identifier = identifier
        self.actions = actions
        self.intentIdentifiers = intentIdentifiers
        self.options = options
    }
}
