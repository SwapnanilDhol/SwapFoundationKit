/*****************************************************************************
 * UIKitTabBarMinimizeBehavior.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import UIKit

public extension UITabBarController {
    /// Sets the tab bar to minimize (hide) on scroll down and reappear on scroll up.
    /// No-op on iOS versions earlier than iOS 26.
    func setTabBarMinimizeBehaviorOnScrollDown() {
        if #available(iOS 26, *) {
            tabBarMinimizeBehavior = .onScrollDown
        }
    }
}
