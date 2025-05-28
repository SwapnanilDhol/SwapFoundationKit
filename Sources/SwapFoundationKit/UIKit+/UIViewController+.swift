/*****************************************************************************
 * UIViewController+.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI

public extension UIViewController {

    /// Present a SwiftUI view as a modal
    /// - Parameters:
    ///   - view: The SwiftUI view to present
    ///   - animated: Whether to animate the presentation
    ///   - modalPresentationStyle: The presentation style to use for the modal
    func present<T: View>(_ view: T, animated: Bool = true, modalPresentationStyle: UIModalPresentationStyle = .automatic) {
        let hostingController = UIHostingController(rootView: view)
        hostingController.modalPresentationStyle = modalPresentationStyle
        present(hostingController, animated: animated)
    }
}
