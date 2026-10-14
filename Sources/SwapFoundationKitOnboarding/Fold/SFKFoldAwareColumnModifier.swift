/****************************************************************************
 * SFKFoldAwareColumnModifier.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI

/// A readable column that steps off the fold.
///
/// Regular width with no active fold: capped at `maxWidth` and centred.
/// Compact width: a no-op. While a division reserved region (iOS 27.1, the
/// fold of a partially folded device) crosses the container, the whole column
/// moves into one half (trailing when book-folded, bottom when tabletop, see
/// ``SFKFoldRegionLayout``) so its controls never sit on the curve. Apply it
/// to a column, not to a list or other scrolling content, and outside any
/// `GeometryReader` that derives positions from width.
///
/// Every branch keeps the same view structure, so the content's state
/// survives folding, unfolding and size-class changes.
public struct SFKFoldAwareColumnModifier: ViewModifier {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let maxWidth: CGFloat

    @State private var layout: SFKFoldRegionLayout?
    @State private var contentHeight: CGFloat?

    /// - Parameter maxWidth: Widest the column gets in regular width.
    public init(maxWidth: CGFloat) {
        self.maxWidth = maxWidth
    }

    private var isRegular: Bool {
        horizontalSizeClass == .regular
    }

    private var placement: SFKFoldColumnPlacement {
        guard isRegular, let layout else { return .centred }
        return layout.placement(maxWidth: maxWidth, contentHeight: contentHeight)
    }

    /// Cap on the column's width. `nil` in compact width leaves the content untouched.
    private var columnMaxWidth: CGFloat? {
        guard isRegular else { return nil }
        switch placement {
        case .centred:
            return maxWidth
        case .bookPane(let frame), .tabletopPane(let frame):
            return frame.width
        }
    }

    private var leadingInset: CGFloat {
        switch placement {
        case .bookPane(let frame):
            frame.minX
        case .centred, .tabletopPane:
            0
        }
    }

    private var topInset: CGFloat {
        switch placement {
        case .tabletopPane(let frame):
            frame.minY
        case .centred, .bookPane:
            0
        }
    }

    private var paneMaxHeight: CGFloat? {
        switch placement {
        case .tabletopPane(let frame):
            frame.height
        case .centred, .bookPane:
            nil
        }
    }

    private var containerMaxWidth: CGFloat? {
        isRegular ? .infinity : nil
    }

    /// Tabletop places the column vertically, so the container fills the height.
    private var containerMaxHeight: CGFloat? {
        switch placement {
        case .tabletopPane:
            .infinity
        case .centred, .bookPane:
            nil
        }
    }

    private var containerAlignment: Alignment {
        switch placement {
        case .centred:
            .center
        case .bookPane:
            .leading
        case .tabletopPane:
            .top
        }
    }

    private var placementAnimation: Animation? {
        reduceMotion ? nil : .smooth(duration: 0.3)
    }

    public func body(content: Content) -> some View {
        content
            .frame(maxWidth: columnMaxWidth)
            .onGeometryChange(for: CGFloat.self) { proxy in
                proxy.size.height
            } action: { height in
                contentHeight = height
            }
            .padding(.leading, leadingInset)
            .frame(maxHeight: paneMaxHeight, alignment: .top)
            .padding(.top, topInset)
            .frame(maxWidth: containerMaxWidth, maxHeight: containerMaxHeight, alignment: containerAlignment)
            .onGeometryChange(for: SFKFoldRegionLayout.self) { proxy in
                SFKFoldRegionLayout(proxy)
            } action: { newLayout in
                guard layout != nil else {
                    layout = newLayout
                    return
                }
                withAnimation(placementAnimation) {
                    layout = newLayout
                }
            }
    }
}
