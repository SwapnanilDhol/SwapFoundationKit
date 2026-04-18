/*****************************************************************************
 * SFKAuraGlowBackground.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI

/// A full-screen atmospheric glow effect that layers a radial gradient
/// and linear gradient over the system grouped background color.
///
/// Used to give subscription and entry views a premium feel with a
/// soft color-tinted glow radiating from the top.
///
/// ## Usage
/// ```swift
/// struct MyView: View {
///     var body: some View {
///         SFKAuraGlowBackground(color: .blue) {
///             // Your content
///         }
///     }
/// }
/// ```
public struct SFKAuraGlowBackground<Content: View>: View {

    private let color: Color
    @Environment(\.colorScheme) private var colorScheme
    @ViewBuilder private let content: () -> Content

    /// Creates an aura glow background with a given color.
    /// - Parameters:
    ///   - color: The primary tint color for the gradient layers.
    ///   - content: The content to render on top of the glow.
    public init(
        color: Color,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.color = color
        self.content = content
    }

    public var body: some View {
        ZStack(alignment: .top) {
            Color(.systemGroupedBackground)

            radialGlow

            linearGlow

            content()
        }
        .ignoresSafeArea()
    }

    @ViewBuilder
    private var radialGlow: some View {
        let isDark = colorScheme == .dark

        RadialGradient(
            colors: [
                color.opacity(isDark ? 0.46 : 0.44),
                color.opacity(isDark ? 0.24 : 0.24),
                .clear
            ],
            center: .top,
            startRadius: 18,
            endRadius: 320
        )
        .frame(height: 360)
        .blur(radius: 24)
        .offset(y: -120)
    }

    @ViewBuilder
    private var linearGlow: some View {
        let isDark = colorScheme == .dark

        LinearGradient(
            colors: [
                color.opacity(isDark ? 0.20 : 0.16),
                .clear
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(height: 240)
        .blur(radius: 12)
    }
}

#Preview("Aura Glow") {
    SFKAuraGlowBackground(color: .blue) {
        Text("Hello")
            .font(.largeTitle)
            .padding(.top, 120)
    }
}