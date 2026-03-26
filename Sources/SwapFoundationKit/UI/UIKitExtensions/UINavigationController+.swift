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

import Foundation

#if canImport(UIKit) && canImport(SwiftUI) && os(iOS)
import SwiftUI
import UIKit

@MainActor
public extension UINavigationController {
    func presentView<Content: View>(view: Content) {
        let controller = UIHostingController(rootView: view)
        present(controller, animated: true)
    }

    func pushView<Content: View>(view: Content) {
        let controller = UIHostingController(rootView: view)
        pushViewController(controller, animated: true)
    }
}
#endif
