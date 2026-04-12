import Foundation
import UIKit
import Toast
import SwapFoundationKit

/// Protocol for defining app-specific toast types.
/// Conforming types provide title, subtitle, and style information
/// that ToastManager uses to present toast notifications.
public protocol ToastType: Sendable {
    var title: String { get }
    var subtitle: String? { get }
    var style: ToastStyle { get }
    var image: UIImage? { get }
}

public enum ToastStyle: Sendable {
    case success
    case error
    case warning
    case informational
}

/// Styling configuration for toast presentations.
public struct ToastConfiguration: Sendable {
    public let autoHide: Bool
    public let displayTime: TimeInterval
    public let animationTime: TimeInterval

    public init(autoHide: Bool = true, displayTime: TimeInterval = 2.5, animationTime: TimeInterval = 0.2) {
        self.autoHide = autoHide
        self.displayTime = displayTime
        self.animationTime = animationTime
    }
}

/// A generic toast manager that wraps the Toast library and exposes
/// a type-safe API for showing toasts based on a `ToastType`.
@MainActor
public final class ToastManager: Sendable {
    public static let shared = ToastManager()
    private init() {}

    /// Shows a toast for the given toast type.
    /// - Parameters:
    ///   - toastType: The toast type conforming to `ToastType` providing content and style.
    ///   - config: Optional configuration overriding the default.
    public func show(toastType: some ToastType, config: ToastConfiguration? = nil) {
        let configuration = config ?? defaultConfiguration
        let toastConfig = ToastConfiguration(
            autoHide: configuration.autoHide,
            displayTime: configuration.displayTime,
            animationTime: configuration.animationTime
        )
        let toast = Toast.default(
            image: toastType.image ?? defaultImage(for: toastType.style),
            title: toastType.title,
            subtitle: toastType.subtitle,
            config: toastConfig
        )
        toast.show(haptic: hapticType(for: toastType.style))
    }

    private var defaultConfiguration: ToastConfiguration {
        ToastConfiguration(autoHide: true, displayTime: 2.5, animationTime: 0.2)
    }

    private func defaultImage(for style: ToastStyle) -> UIImage? {
        switch style {
        case .success:
            return UIImage(systemName: "checkmark.circle")
        case .error:
            return UIImage(systemName: "xmark.circle.fill")
        case .warning:
            return UIImage(systemName: "exclamationmark.triangle")
        case .informational:
            return UIImage(systemName: "info.circle")
        }
    }

    private func hapticType(for style: ToastStyle) -> Toast.Haptic {
        switch style {
        case .success: return .success
        case .error: return .error
        case .warning: return .warning
        case .informational: return .success
        }
    }
}
