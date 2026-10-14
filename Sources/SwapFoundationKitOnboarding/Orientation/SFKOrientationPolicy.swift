/****************************************************************************
 * SFKOrientationPolicy.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import UIKit

/// Keeps a window's supported orientations in step with its size classes.
///
/// Apps that decide orientation by size class (only a window that is regular
/// in both width and height may turn) need UIKit to re-ask whenever those
/// classes change. Folding iPhone Duo swaps a regular window for a compact one
/// mid-session; without a re-ask, a flow opened landscape on the inner display
/// stays landscape on the outer one.
///
/// ## Usage
/// ```swift
/// func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options: UIScene.ConnectionOptions) {
///     let window = UIWindow(windowScene: scene as! UIWindowScene)
///     SFKOrientationPolicy.keepOrientationCurrent(in: window)
/// }
/// ```
public enum SFKOrientationPolicy {

    /// Asks the top-most presented view controller to update its supported
    /// interface orientations whenever `window`'s horizontal or vertical size
    /// class changes.
    @MainActor
    public static func keepOrientationCurrent(in window: UIWindow) {
        window.registerForTraitChanges(
            [UITraitHorizontalSizeClass.self, UITraitVerticalSizeClass.self]
        ) { (window: UIWindow, _) in
            var controller = window.rootViewController
            while let presented = controller?.presentedViewController {
                controller = presented
            }
            controller?.setNeedsUpdateOfSupportedInterfaceOrientations()
        }
    }
}
