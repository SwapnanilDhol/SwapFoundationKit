/*****************************************************************************
 * UIApplication+SafeArea.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import UIKit

public extension UIApplication {

    /// Returns the safe area padding for a given edge.
    /// - Parameter edge: The edge to get the safe area padding for.
    /// - Returns: The safe area padding for the given edge.
    func safeAreaPadding(for edge: UIRectEdge) -> CGFloat {
        guard let window = connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows.first else {
            return 0
        }

        let safeAreaInsets = window.safeAreaInsets

        switch edge {
        case .top:
            return safeAreaInsets.top
        case .left:
            return safeAreaInsets.left
        case .bottom:
            return safeAreaInsets.bottom
        case .right:
            return safeAreaInsets.right
        default:
            return 0
        }
    }  
}