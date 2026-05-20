import Foundation

/// Generic CLI launch argument and environment variable parser.
///
/// Provides helpers for reading `ProcessInfo.processInfo.arguments` flags
/// and `ProcessInfo.processInfo.environment` variables. Useful for UI testing,
/// Maestro automation, XCTest performance tests, and feature toggling at launch.
///
/// ## Usage
/// ```swift
/// if SFKLaunchArguments.hasFlag("-force-pro") {
///     // Automatically enable Pro
/// }
///
/// if SFKLaunchArguments.environmentFlag("DISABLE_ANALYTICS") {
///     AnalyticsManager.shared.clearGlobalParameters()
/// }
///
/// if SFKLaunchArguments.isAutomationMode {
///     // Skip onboarding, disable haptics, etc.
/// }
/// ```
public enum SFKLaunchArguments {

    /// Checks whether a CLI flag is present in launch arguments.
    /// - Parameter flag: The flag to search for (e.g., `"-force-pro"`).
    /// - Returns: `true` if the flag was passed.
    public static func hasFlag(_ flag: String) -> Bool {
        ProcessInfo.processInfo.arguments.contains(flag)
    }

    /// Checks whether an environment variable is truthy.
    ///
    /// Recognized truthy values: `"1"`, `"true"`, `"yes"` (case-insensitive).
    /// - Parameter key: The environment variable key.
    /// - Returns: `true` if the variable is set to a truthy value.
    public static func environmentFlag(_ key: String) -> Bool {
        let value = ProcessInfo.processInfo.environment[key]?.lowercased() ?? ""
        return value == "1" || value == "true" || value == "yes"
    }

    /// Returns the raw string value of an environment variable, or `nil`.
    /// - Parameter key: The environment variable key.
    /// - Returns: The string value, or `nil` if not set.
    public static func environmentString(_ key: String) -> String? {
        ProcessInfo.processInfo.environment[key]
    }

    /// Whether the app is running in automation mode.
    ///
    /// Checks `SFK_AUTOMATION_MODE=1` in the environment or `UserDefaults`
    /// key `SFK_AUTOMATION_MODE` set to `"enabled"`.
    public static var isAutomationMode: Bool {
        if environmentFlag("SFK_AUTOMATION_MODE") { return true }
        let defaultsValue = (UserDefaults.standard.string(forKey: "SFK_AUTOMATION_MODE") ?? "").lowercased()
        return defaultsValue == "enabled"
    }
}
