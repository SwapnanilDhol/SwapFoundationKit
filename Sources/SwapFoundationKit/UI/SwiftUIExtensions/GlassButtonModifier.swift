/*****************************************************************************
 * GlassButtonModifier.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI

public enum GlassEffectCompatStyle: Sendable {
    case regular
    case clear
    case identity
}

/// A compatibility wrapper around SwiftUI's `.glassProminent` button style.
public struct GlassProminentCompatModifier: ViewModifier {
    public let color: Color

    public init(
        color: Color = .accentColor
    ) {
        self.color = color
    }

    @ViewBuilder
    public func body(content: Content) -> some View {
        if #available(iOS 26, macOS 26, watchOS 26, tvOS 26, visionOS 26, *) {
            content
                .buttonStyle(.glassProminent)
                .tint(color)
        } else {
            content
                .background(color)
        }
    }
}

/// A compatibility wrapper around SwiftUI's `.glass` button style.
public struct GlassCompatModifier: ViewModifier {
    public let color: Color

    public init(
        color: Color = .accentColor
    ) {
        self.color = color
    }

    @ViewBuilder
    public func body(content: Content) -> some View {
        if #available(iOS 26, macOS 26, watchOS 26, tvOS 26, visionOS 26, *) {
            content
                .buttonStyle(.glass)
                .tint(color)
        } else {
            content
                .background(color)
        }
    }
}

/// A compatibility wrapper around SwiftUI's `glassEffect(_:in:)` modifier.
public struct GlassEffectCompatModifier<S: Shape>: ViewModifier {
    public let style: GlassEffectCompatStyle
    public let color: Color
    public let isInteractive: Bool
    public let shape: S

    public init(
        style: GlassEffectCompatStyle = .regular,
        color: Color = .white.opacity(0.18),
        isInteractive: Bool = false,
        shape: S
    ) {
        self.style = style
        self.color = color
        self.isInteractive = isInteractive
        self.shape = shape
    }

    @ViewBuilder
    public func body(content: Content) -> some View {
        if #available(iOS 26, macOS 26, watchOS 26, tvOS 26, visionOS 26, *) {
            content
                .glassEffect(resolvedGlass, in: shape)
        } else {
            content
                .background(shape.fill(color))
        }
    }

    @available(iOS 26, macOS 26, watchOS 26, tvOS 26, visionOS 26, *)
    private var resolvedGlass: Glass {
        let baseGlass: Glass = switch style {
        case .regular:
            .regular
        case .clear:
            .clear
        case .identity:
            .identity
        }

        return baseGlass
            .tint(color)
            .interactive(isInteractive)
    }
}

public extension View {
    /// Applies SwiftUI's `.glassProminent` button style with a pre-iOS 26 fallback background.
    func glassProminentCompat(
        color: Color = .accentColor
    ) -> some View {
        modifier(
            GlassProminentCompatModifier(
                color: color
            )
        )
    }

    /// Applies SwiftUI's `.glass` button style with a pre-iOS 26 fallback background.
    func glassCompat(
        color: Color = .accentColor
    ) -> some View {
        modifier(
            GlassCompatModifier(
                color: color
            )
        )
    }

    /// Applies SwiftUI's `glassEffect(_:in:)` modifier with a pre-iOS 26 fallback shape fill.
    func glassEffectCompat<S: Shape>(
        style: GlassEffectCompatStyle = .regular,
        color: Color = .white.opacity(0.18),
        isInteractive: Bool = false,
        in shape: S
    ) -> some View {
        modifier(
            GlassEffectCompatModifier(
                style: style,
                color: color,
                isInteractive: isInteractive,
                shape: shape
            )
        )
    }
}

#Preview("Glass Button Compat") {
    VStack(spacing: 16) {
        Button("Continue") {}
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .glassProminentCompat(color: .blue)

        Button("Maybe Later") {}
            .padding(.horizontal, 22)
            .padding(.vertical, 10)
            .glassCompat(color: .orange)
    }
    .padding(24)
}

#Preview("Glass Effect Compat") {
    HStack(spacing: 20) {
        Text("A")
            .font(.headline.weight(.bold))
            .frame(width: 56, height: 56)
            .glassEffectCompat(style: .regular, color: .blue, isInteractive: true, in: Circle())

        Text("B")
            .font(.headline.weight(.bold))
            .frame(height: 44)
            .padding(.horizontal, 18)
            .glassEffectCompat(style: .regular, color: .green, isInteractive: true, in: Capsule())
    }
    .padding(24)
}
