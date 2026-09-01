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
import StoreKit
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

    /// Returns the foreground active window scene, or `nil` if none is currently active.
    ///
    /// Unlike naively taking `connectedScenes.first`, this filters on
    /// `activationState == .foregroundActive` so background, inactive, or
    /// suspended scenes are never mistaken for the visible one (matters most on
    /// iPad multi-scene and Slide Over/Split View layouts).
    var foregroundActiveScene: UIWindowScene? {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }
    }

    /// Resigns the first responder, dismissing the keyboard.
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    /// Requests an App Store review prompt using the non-deprecated `AppStore.requestReview(in:)` API.
    ///
    /// Waits ~1.5 seconds before requesting so the prompt never appears mid-transition
    /// (e.g. immediately after a save or navigation animation completes) — surfacing it a beat
    /// later reads as intentional rather than jarring. Silently does nothing if there is no
    /// foreground active scene to present in.
    ///
    /// - Parameter reason: The trigger that asked for the prompt (e.g. `"textTransactionEntry"`).
    ///   iOS caps review prompts at three per user per year and gives no callback saying whether
    ///   one was actually shown, so the request is logged with its reason: without that, there is
    ///   no way to tell after the fact which trigger consumed the quota, or that a request was
    ///   dropped for want of a foreground scene.
    func requestReview(reason: String) {
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(1.5))
            // Resolve the scene *after* the delay rather than before it: the app can be
            // backgrounded while we wait, and requesting a review in a scene that is no
            // longer foreground active would target the wrong (or a dead) scene.
            guard let scene = UIApplication.shared.foregroundActiveScene else {
                Logger.info(
                    "Review request '\(reason)' dropped: no foreground active scene",
                    context: "Review"
                )
                return
            }
            Logger.info("Requesting review for reason '\(reason)'", context: "Review")
            AppStore.requestReview(in: scene)
        }
    }
}
#endif
