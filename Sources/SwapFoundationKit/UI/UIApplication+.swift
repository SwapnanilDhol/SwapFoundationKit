/*****************************************************************************
 * UIApplication+.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import Foundation

#if canImport(UIKit) && os(iOS)
import UIKit
#endif

#if canImport(UIKit) && os(iOS)
@MainActor
public extension UIApplication {
    /// Returns the top-most view controller in the application.
    /// - Parameter rootViewController: The root view controller to start from. If nil, uses the first connected scene's root view controller.
    /// - Returns: The top-most view controller, or nil if not found.
    static func topViewController(
        from rootViewController: UIViewController? = UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first?.rootViewController
    ) -> UIViewController? {

        guard let rootViewController = rootViewController else { return nil }

        if let presentedViewController = rootViewController.presentedViewController {
            return topViewController(from: presentedViewController)
        }

        if let navigationController = rootViewController as? UINavigationController {
            return topViewController(from: navigationController.visibleViewController)
        }

        if let tabBarController = rootViewController as? UITabBarController {
            return topViewController(from: tabBarController.selectedViewController)
        }

        return rootViewController
    }

    /// Returns the key window of the foreground active scene.
    var foregroundKeyWindow: UIWindow? {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }?
            .keyWindow
    }

    /// Presents an alert controller on the top view controller.
    /// - Parameters:
    ///   - title: The title of the alert.
    ///   - message: The message of the alert.
    ///   - actions: The actions to add to the alert.
    func presentAlert(title: String, message: String, actions: [UIAlertAction]) {
        guard let topViewController = UIApplication.topViewController() else { return }
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions.forEach { alertController.addAction($0) }
        topViewController.present(alertController, animated: true)
    }

    /// Presents an action sheet on the top view controller.
    /// - Parameters:
    ///   - title: The title of the sheet.
    ///   - message: The message of the sheet.
    ///   - actions: The actions to add to the sheet.
    ///   - sourceView: Optional source view for iPad popover presentation.
    ///   - sourceRect: Optional source rect for iPad popover presentation.
    func presentActionSheet(
        title: String,
        message: String? = nil,
        actions: [UIAlertAction],
        sourceView: UIView? = nil,
        sourceRect: CGRect? = nil
    ) {
        guard let topViewController = UIApplication.topViewController() else { return }
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        actions.forEach { alertController.addAction($0) }

        if let popover = alertController.popoverPresentationController {
            guard let resolvedSourceView = sourceView ?? topViewController.view else { return }
            popover.sourceView = resolvedSourceView
            popover.sourceRect = sourceRect ?? CGRect(
                x: resolvedSourceView.bounds.midX,
                y: resolvedSourceView.bounds.maxY - 1,
                width: 1,
                height: 1
            )
        }

        topViewController.present(alertController, animated: true)
    }

    /// Presents a confirmation dialog (alert) on the top view controller.
    /// - Parameters:
    ///   - title: The title of the alert.
    ///   - message: The message of the alert.
    ///   - confirmTitle: The title of the confirm button. Default is "Confirm".
    ///   - confirmStyle: The style of the confirm action. Default is `.default`.
    ///   - onConfirm: Closure to execute when confirmed.
    ///   - cancelTitle: The title of the cancel button. Default is "Cancel".
    ///   - onCancel: Optional closure to execute when cancelled.
    func presentConfirmation(
        title: String,
        message: String,
        confirmTitle: String = "Confirm",
        confirmStyle: UIAlertAction.Style = .default,
        onConfirm: @escaping () -> Void,
        cancelTitle: String = "Cancel",
        onCancel: (() -> Void)? = nil
    ) {
        let confirmAction = UIAlertAction(title: confirmTitle, style: confirmStyle) { _ in onConfirm() }
        let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel) { _ in onCancel?() }
        presentAlert(title: title, message: message, actions: [confirmAction, cancelAction])
    }
}
#endif
