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
    
    enum _MinimizeBehavior : Int, @unchecked Sendable {

        /// Resolves to the system default minimize behavior.
        case automatic = 0

        /// The tab bar does not minimize.
        case never = 1

        /// The tab bar minimizes when scrolling down, and expands when scrolling back up.
        case onScrollDown = 2

        /// The tab bar minimizes when scrolling up, and expands when scrolling back down.
        /// Recommended if the scroll view content is aligned to the bottom.
        case onScrollUp = 3
    }
    
    /// Sets the tab bar to minimize (hide) on scroll down and reappear on scroll up.
    /// No-op on iOS versions earlier than iOS 26.
    func setTabBarMinimizeBehavior(on scrollDirection: _MinimizeBehavior = .onScrollDown) {
        if #available(iOS 26, *) {
            tabBarMinimizeBehavior = MinimizeBehavior(rawValue: scrollDirection.rawValue) ?? .onScrollDown
        }
    }
}
