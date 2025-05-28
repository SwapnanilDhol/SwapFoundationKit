/*****************************************************************************
 * UINavigationController+.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/
 
import SwiftUI

 public extension UINavigationController {
    func pushView<T: View>(_ view: T, animated: Bool = true) {
        let hostingController = UIHostingController(rootView: view)
        pushViewController(hostingController, animated: animated)
    }
 }
