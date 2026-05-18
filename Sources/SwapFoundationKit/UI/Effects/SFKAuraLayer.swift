/*****************************************************************************
 * SFKAuraLayer.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI

/// A tab-root aura layer that renders a top gradient glow, gated by accessibility reduce-motion.
///
/// Use this as a decorative background layer in a `ZStack` behind your content.
/// When the user has "Reduce Motion" enabled, this view renders as `EmptyView`.
///
/// ## Usage
/// ```swift
/// ZStack(alignment: .top) {
///     Color(.systemGroupedBackground).ignoresSafeArea()
///     SFKAuraLayer(glowColor: .blue, opacity: 0.25, height: 200)
///         .allowsHitTesting(false)
///     MyContent()
/// }
/// ```
public struct SFKAuraLayer: View {

    private let glowColor: Color
    private let opacity: Double
    private let blurRadius: CGFloat
    private let height: CGFloat
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(
        glowColor: Color,
        opacity: Double = 0.25,
        blurRadius: CGFloat = 40,
        height: CGFloat = 200
    ) {
        self.glowColor = glowColor
        self.opacity = opacity
        self.blurRadius = blurRadius
        self.height = height
    }

    public var body: some View {
        if reduceMotion {
            EmptyView()
        } else {
            TopAuraBackground(
                glowColor: glowColor,
                opacity: opacity,
                blurRadius: blurRadius,
                bandHeight: height
            )
        }
    }
}
