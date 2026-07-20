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

// MARK: - Public Configuration

/// How prominent the glass treatment should be.
///
/// - `.prominent` uses the system `.glassProminent` button style — a filled, tinted glass
///   surface. Use it for primary actions such as "Continue" or "Save".
/// - `.regular` uses the system `.glass` button style — a translucent, tinted glass
///   surface. Use it for secondary actions such as "Maybe Later" or filter chips.
public enum SFKGlassEmphasis: Sendable {
    case prominent
    case regular
}

/// The system `Glass` preset to apply when `sfkGlass` is rendering a custom shape.
///
/// - `.regular` — standard Liquid Glass. The default.
/// - `.clear` — more transparent; lets the content behind it read more clearly.
/// - `.identity` — no glass effect; leaves the content visually unaffected.
public enum SFKGlassStyle: Sendable {
    case regular
    case clear
    case identity
}

/// The shape the glass effect is applied to.
///
/// Pass `nil` to `sfkGlass(shape:)` to use the system button style
/// (`.glassProminent` or `.glass`) instead of a custom-shape `.glassEffect`.
public enum SFKGlassShape: Sendable {
    case roundedRectangle(cornerRadius: CGFloat, style: RoundedCornerStyle = .continuous)
    case capsule
    case circle
}

// MARK: - Modifier

private struct SFKGlassModifier: ViewModifier {
    let emphasis: SFKGlassEmphasis
    let color: Color
    let style: SFKGlassStyle
    let isInteractive: Bool
    let shape: SFKGlassShape?

    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 26, macOS 26, watchOS 26, tvOS 26, visionOS 26, *) {
            switch shape {
            case .none:
                switch emphasis {
                case .prominent:
                    content
                        .buttonStyle(.glassProminent)
                        .tint(color)
                case .regular:
                    content
                        .buttonStyle(.glass)
                        .tint(color)
                }
            case let shape?:
                content
                    .glassEffect(resolvedGlass, in: resolvedShape(shape))
            }
        } else {
            content
                .background(fallback(for: shape))
        }
    }

    @available(iOS 26, macOS 26, watchOS 26, tvOS 26, visionOS 26, *)
    private var resolvedGlass: Glass {
        let base: Glass = switch style {
        case .regular: .regular
        case .clear:   .clear
        case .identity: .identity
        }
        return base
            .tint(color)
            .interactive(isInteractive)
    }

    @available(iOS 26, macOS 26, watchOS 26, tvOS 26, visionOS 26, *)
    private func resolvedShape(_ shape: SFKGlassShape) -> AnyShape {
        switch shape {
        case let .roundedRectangle(cornerRadius, style):
            return AnyShape(RoundedRectangle(cornerRadius: cornerRadius, style: style))
        case .capsule:
            return AnyShape(Capsule())
        case .circle:
            return AnyShape(Circle())
        }
    }

    @ViewBuilder
    private func fallback(for shape: SFKGlassShape?) -> some View {
        if let shape {
            switch shape {
            case let .roundedRectangle(cornerRadius, style):
                RoundedRectangle(cornerRadius: cornerRadius, style: style).fill(color)
            case .capsule:
                Capsule().fill(color)
            case .circle:
                Circle().fill(color)
            }
        } else {
            Rectangle().fill(color)
        }
    }
}

public extension View {
    /// Applies the Liquid Glass effect with a pre-iOS-26 fallback.
    ///
    /// Use the `emphasis` and `shape` parameters to pick the right treatment:
    ///
    /// - `shape: nil` — render the effect via a system button style.
    ///   - `emphasis: .prominent` → `.glassProminent` (filled, tinted). Primary actions.
    ///   - `emphasis: .regular`   → `.glass` (translucent, tinted). Secondary actions.
    /// - `shape: <some shape>` — render the effect on a custom shape via
    ///   `.glassEffect(...)`. Use this for non-button surfaces such as chips,
    ///   color swatches, or decorative blobs. In this mode `emphasis` is ignored;
    ///   control the look with `style:` and `isInteractive:`.
    ///
    /// On platforms older than iOS 26 / macOS 26, the modifier falls back to a
    /// solid tinted background (or a shape-filled tint when `shape` is non-nil)
    /// so the surface remains visible.
    ///
    /// Example — primary action:
    /// ```swift
    /// Button("Continue") {}
    ///     .sfkGlass(emphasis: .prominent, color: .blue)
    /// ```
    ///
    /// Example — secondary action:
    /// ```swift
    /// Button("Maybe Later") {}
    ///     .sfkGlass(emphasis: .regular, color: .orange)
    /// ```
    ///
    /// Example — interactive chip on a capsule:
    /// ```swift
    /// Text("Filters")
    ///     .sfkGlass(
    ///         color: .green,
    ///         isInteractive: true,
    ///         shape: .capsule
    ///     )
    /// ```
    func sfkGlass(
        emphasis: SFKGlassEmphasis = .regular,
        color: Color = .accentColor,
        style: SFKGlassStyle = .regular,
        isInteractive: Bool = false,
        shape: SFKGlassShape? = nil
    ) -> some View {
        modifier(
            SFKGlassModifier(
                emphasis: emphasis,
                color: color,
                style: style,
                isInteractive: isInteractive,
                shape: shape
            )
        )
    }
}

// MARK: - Previews

#Preview("Buttons") {
    VStack(spacing: 16) {
        Button("Continue") {}
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .sfkGlass(emphasis: .prominent, color: .blue)

        Button("Maybe Later") {}
            .padding(.horizontal, 22)
            .padding(.vertical, 10)
            .sfkGlass(emphasis: .regular, color: .orange)
    }
    .padding(24)
}

#Preview("Shapes") {
    HStack(spacing: 20) {
        Text("A")
            .font(.headline.weight(.bold))
            .frame(width: 56, height: 56)
            .sfkGlass(
                color: .blue,
                isInteractive: true,
                shape: .circle
            )

        Text("B")
            .font(.headline.weight(.bold))
            .frame(height: 44)
            .padding(.horizontal, 18)
            .sfkGlass(
                color: .green,
                isInteractive: true,
                shape: .capsule
            )
    }
    .padding(24)
}
