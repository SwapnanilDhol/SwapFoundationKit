import Foundation
import UIKit
import Toast

/// Protocol for defining app-specific toast types.
/// Conforming types provide title, subtitle, and style information
/// that ToastManager uses to present toast notifications.
public protocol SFKToastKind: Sendable {
    var title: String { get }
    var subtitle: String? { get }
    var style: SFKToastStyle { get }
    var image: UIImage? { get }
}

public enum SFKToastStyle: Sendable {
    case success
    case error
    case warning
    case informational
}

/// Styling configuration for toast presentations.
public struct SFKToastConfiguration: Sendable {
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
/// a type-safe API for showing toasts based on a `SFKToastKind`.
@MainActor
public final class ToastManager: Sendable {
    public static let shared = ToastManager()
    private init() {}

    /// Shows a toast for the given toast type.
    /// - Parameters:
    ///   - kind: The toast type conforming to `SFKToastKind` providing content and style.
    ///   - config: Optional configuration overriding the default.
    public func show(kind: some SFKToastKind, config: SFKToastConfiguration? = nil) {
        let displayDuration = config?.displayTime ?? 2.5
        let animationDuration = config?.animationTime ?? 0.2
        let allowOverlap = config?.autoHide ?? true

        let toastConfig = ToastConfiguration(
            dismissBy: [.time(time: displayDuration)],
            animationTime: animationDuration,
            allowToastOverlap: allowOverlap
        )
        let viewConfig = ToastViewConfiguration()
        let image = kind.image ?? defaultImage(for: kind.style)
        let toast = Toast.default(
            image: image!,
            title: kind.title,
            subtitle: kind.subtitle,
            viewConfig: viewConfig,
            config: toastConfig
        )

        // Present from the key window's root VC to avoid UIHostingController subview restriction
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.keyWindow?.rootViewController else {
            return
        }

        // Find the topmost presented VC to present from
        var topVC = rootVC
        while let presented = topVC.presentedViewController {
            topVC = presented
        }

        toast.show(
            presentingViewController: topVC,
            sourceView: topVC.view,
            haptic: hapticType(for: kind.style)
        )
    }

    private func defaultImage(for style: SFKToastStyle) -> UIImage? {
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

    private func hapticType(for style: SFKToastStyle) -> UINotificationFeedbackGenerator.FeedbackType {
        switch style {
        case .success: return .success
        case .error: return .error
        case .warning: return .warning
        case .informational: return .success
        }
    }
}
