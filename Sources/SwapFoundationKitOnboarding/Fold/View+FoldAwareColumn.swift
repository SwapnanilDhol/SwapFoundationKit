/****************************************************************************
 * View+FoldAwareColumn.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI

public extension View {
    /// Caps the view at `maxWidth` and centres it in regular width, and moves
    /// it into one half while a fold divides the container. A no-op in
    /// compact width. See ``SFKFoldAwareColumnModifier``.
    ///
    /// ## Usage
    /// ```swift
    /// VStack { headline; controls }
    ///     .sfkFoldAwareColumn(maxWidth: 560)
    /// ```
    func sfkFoldAwareColumn(maxWidth: CGFloat = 720) -> some View {
        modifier(SFKFoldAwareColumnModifier(maxWidth: maxWidth))
    }
}
