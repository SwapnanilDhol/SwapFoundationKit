/****************************************************************************
 * SFKVerticalBarProbe.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI

/// Reports whether the system wants this screen's bar items laid out
/// vertically (iPhone Duo's side bar) so a screen can offer a vertical
/// variant of a custom bar item, or move a footer control into the bar.
/// Zero-sized; place it in a background.
///
/// ## Usage
/// ```swift
/// content
///     .background {
///         if #available(iOS 27.1, *) {
///             SFKVerticalBarProbe(isVertical: $barIsVertical)
///         }
///     }
/// ```
@available(iOS 27.1, *)
public struct SFKVerticalBarProbe: View {
    @Environment(\.toolbarVerticalEdge) private var toolbarVerticalEdge
    @Binding private var isVertical: Bool

    /// - Parameter isVertical: Set to `true` while bar items run vertically.
    public init(isVertical: Binding<Bool>) {
        _isVertical = isVertical
    }

    public var body: some View {
        Color.clear
            .frame(width: 0, height: 0)
            .onChange(of: toolbarVerticalEdge != nil, initial: true) { _, vertical in
                isVertical = vertical
            }
    }
}
