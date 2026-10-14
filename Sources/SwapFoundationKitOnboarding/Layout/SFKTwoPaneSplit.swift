/****************************************************************************
 * SFKTwoPaneSplit.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI

/// Pane widths for a two-pane window, measured inside the safe area.
///
/// The split lands on the window's physical centre (the fold on iPhone Duo),
/// not the centre of the safe area: a vertical bar on one side makes the
/// insets asymmetric, and splitting the safe area would put the gap on the
/// fold's wrong side. A gutter either side of the centre keeps controls out
/// of the curve.
///
/// Flow roots resolve it once per size change (``SFKOnboardingWindow`` does
/// this for you) and publish it with the `twoPaneSplit` environment value.
///
/// ## Usage
/// ```swift
/// GeometryReader { proxy in
///     let split = SFKTwoPaneSplit.resolve(
///         sizeClass: horizontalSizeClass,
///         size: proxy.size,
///         safeAreaInsets: proxy.safeAreaInsets
///     )
///     HStack(spacing: SFKTwoPaneSplit.gutter) {
///         preview.frame(width: split?.leadingWidth)
///         form.frame(width: split?.trailingWidth)
///     }
/// }
/// ```
public struct SFKTwoPaneSplit: Equatable, Sendable {
    /// Leading pane width, from the safe area's leading edge to the gutter.
    public let leadingWidth: CGFloat
    /// Trailing pane width, from the gutter to the safe area's trailing edge.
    public let trailingWidth: CGFloat

    /// Space between the panes, centred on the window's centre line.
    public static let gutter: CGFloat = 24

    /// Widest a pane's content gets, so a large iPad does not stretch it.
    public static let maximumContentWidth: CGFloat = 480

    /// Horizontal inset of a pane's content from the pane's edges.
    public static let contentInset: CGFloat = 20

    /// Splits a safe area on the window's centre line.
    /// - Parameters:
    ///   - safeAreaWidth: Width inside the horizontal safe area insets.
    ///   - leadingInset: The window's leading safe area inset.
    ///   - trailingInset: The window's trailing safe area inset.
    public init(safeAreaWidth: CGFloat, leadingInset: CGFloat, trailingInset: CGFloat) {
        let windowWidth = safeAreaWidth + leadingInset + trailingInset
        let centreInSafeArea = windowWidth / 2 - leadingInset
        leadingWidth = max(centreInSafeArea - Self.gutter / 2, 0)
        trailingWidth = max(safeAreaWidth - centreInSafeArea - Self.gutter / 2, 0)
    }

    /// The split for a root `GeometryReader`, or `nil` when the window keeps
    /// a single column.
    public static func resolve(
        sizeClass: UserInterfaceSizeClass?,
        size: CGSize,
        safeAreaInsets: EdgeInsets
    ) -> SFKTwoPaneSplit? {
        let windowWidth = size.width + safeAreaInsets.leading + safeAreaInsets.trailing
        guard SFKWindowPaneLayout.resolve(sizeClass: sizeClass, width: windowWidth) == .twoPane else {
            return nil
        }
        return SFKTwoPaneSplit(
            safeAreaWidth: size.width,
            leadingInset: safeAreaInsets.leading,
            trailingInset: safeAreaInsets.trailing
        )
    }
}
