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

import Foundation
import UIKit

@MainActor
public extension UIApplication {
    /// Returns the safe area insets for the key window.
    var safeAreaInsets: UIEdgeInsets {
        return foregroundKeyWindow?.safeAreaInsets ?? .zero
    }
    
    /// Returns the top safe area inset.
    var topSafeAreaInset: CGFloat {
        return safeAreaInsets.top
    }
    
    /// Returns the bottom safe area inset.
    var bottomSafeAreaInset: CGFloat {
        return safeAreaInsets.bottom
    }
    
    /// Returns the left safe area inset.
    var leftSafeAreaInset: CGFloat {
        return safeAreaInsets.left
    }
    
    /// Returns the right safe area inset.
    var rightSafeAreaInset: CGFloat {
        return safeAreaInsets.right
    }
}
