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
        from rootViewController: UIViewController? = nil
    ) -> UIViewController? {
        let resolvedRoot = rootViewController ?? UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first?.rootViewController

        guard let rootViewController = resolvedRoot else { return nil }

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

    /// Resigns the first responder, dismissing the keyboard.
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
