/****************************************************************************
 * SFKWindowPaneLayout.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI

/// Whether a full-screen flow shows one column or two side-by-side panes.
///
/// iPhone Duo's inner display is regular width on a phone, and each half of it
/// is roughly one outer display. A phone-shaped column fits one half; centred
/// across the whole window it would sit on the fold. So regular width with
/// room for two phone-shaped panes gets two panes, and everything else keeps
/// a single column. This is never a question about the device.
///
/// ## Usage
/// ```swift
/// let windowWidth = proxy.size.width + proxy.safeAreaInsets.leading + proxy.safeAreaInsets.trailing
/// if SFKWindowPaneLayout.resolve(sizeClass: horizontalSizeClass, width: windowWidth) == .twoPane {
///     // hero leading, copy and controls trailing
/// }
/// ```
public enum SFKWindowPaneLayout: Equatable, Sendable {
    /// One phone-shaped column.
    case single
    /// Two panes split on the window's centre line.
    case twoPane

    /// Narrowest a pane may get and still hold a phone-shaped column.
    public static let minimumPaneWidth: CGFloat = 440

    /// Resolves the layout for a window.
    /// - Parameters:
    ///   - sizeClass: The window's horizontal size class.
    ///   - width: The full window width, horizontal safe area insets
    ///     included. The fold sits at the centre of the window, not of the
    ///     safe area, so the question is about the whole width.
    public static func resolve(sizeClass: UserInterfaceSizeClass?, width: CGFloat) -> SFKWindowPaneLayout {
        guard sizeClass == .regular, width >= minimumPaneWidth * 2 else { return .single }
        return .twoPane
    }
}
