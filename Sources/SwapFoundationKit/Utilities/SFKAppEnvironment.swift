import Foundation

/// Compile-time application environment detection.
///
/// Use to gate debug-only features, enable test fixtures, or adjust behavior
/// for UI automation. The current environment is detected from Swift compilation
/// flags and can be overridden via environment variables for CI automation.
///
/// ## Usage
/// ```swift
/// if SFKAppEnvironment.current.isDebug {
///     // Enable debug tools
/// }
///
/// // Check launch arguments
/// if SFKLaunchArguments.hasFlag("-force-pro") {
///     // Override behavior
/// }
/// ```
public enum SFKAppEnvironment: Sendable {
    case debug
    case release
    case testing

    /// The current environment, detected at compile time.
    public static var current: SFKAppEnvironment {
        #if TESTING
        return .testing
        #elseif DEBUG
        return .debug
        #else
        return .release
        #endif
    }

    public var isDebug: Bool { self == .debug }
    public var isRelease: Bool { self == .release }
    public var isTesting: Bool { self == .testing }

    public var rawValue: String {
        switch self {
        case .debug: return "debug"
        case .release: return "release"
        case .testing: return "testing"
        }
    }
}
