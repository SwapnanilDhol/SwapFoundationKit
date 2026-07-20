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

/// The Liquid Glass material used by a custom glass surface.
///
/// Button hierarchy is configured separately with ``SFKButtonStyle``.
public enum SFKGlassMaterial: Sendable {
    /// The default material, optimized for foreground legibility.
    case regular
    /// A highly translucent material intended for controls over rich media.
    case clear
}

/// Legacy button-glass emphasis retained for source compatibility.
///
/// New button code should use ``SFKButtonStyle``.
public enum SFKGlassEmphasis: Sendable {
    case prominent
    case regular
}

/// Legacy custom-glass style retained for source compatibility.
///
/// New custom surfaces should use ``SFKGlassMaterial``. Omitting the modifier replaces
/// the former `identity` case.
public enum SFKGlassStyle: Sendable {
    case regular
    case clear
    case identity
}

/// The shape the glass effect is applied to.
public enum SFKGlassShape: Sendable {
    case roundedRectangle(cornerRadius: CGFloat, style: RoundedCornerStyle = .continuous)
    case capsule
    case circle
}

// MARK: - Custom Glass Surface

private struct SFKGlassSurfaceModifier: ViewModifier {
    let material: SFKGlassMaterial
    let tint: Color?
    let isInteractive: Bool
    let shape: SFKGlassShape

    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 26, macOS 26, watchOS 26, tvOS 26, visionOS 26, *) {
            content
                .glassEffect(resolvedGlass, in: resolvedShape(shape))
        } else {
            content
                .background(fallback(for: shape))
        }
    }

    @available(iOS 26, macOS 26, watchOS 26, tvOS 26, visionOS 26, *)
    private var resolvedGlass: Glass {
        let glass: Glass = switch material {
        case .regular: .regular
        case .clear: .clear
        }

        return glass
            .tint(tint)
            .interactive(isInteractive)
    }

    private func resolvedShape(_ shape: SFKGlassShape) -> AnyShape {
        switch shape {
        case let .roundedRectangle(cornerRadius, style):
            AnyShape(RoundedRectangle(cornerRadius: cornerRadius, style: style))
        case .capsule:
            AnyShape(Capsule())
        case .circle:
            AnyShape(Circle())
        }
    }

    @ViewBuilder
    private func fallback(for shape: SFKGlassShape) -> some View {
        switch shape {
        case let .roundedRectangle(cornerRadius, style):
            fallbackShape(RoundedRectangle(cornerRadius: cornerRadius, style: style))
        case .capsule:
            fallbackShape(Capsule())
        case .circle:
            fallbackShape(Circle())
        }
    }

    private func fallbackShape<ShapeType: Shape>(_ shape: ShapeType) -> some View {
        shape
            .fill(.ultraThinMaterial)
            .overlay {
                if let tint {
                    shape.fill(tint)
                }
            }
    }
}

// MARK: - Legacy Compatibility

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
    /// Applies Liquid Glass to a custom surface with a pre-iOS-26 fallback.
    ///
    /// Use ``SFKButton`` with ``SFKButtonStyle`` for buttons. This modifier is for
    /// custom controls and surfaces that need an explicit shape.
    func sfkGlass(
        material: SFKGlassMaterial,
        tint: Color? = nil,
        isInteractive: Bool = false,
        shape: SFKGlassShape
    ) -> some View {
        modifier(
            SFKGlassSurfaceModifier(
                material: material,
                tint: tint,
                isInteractive: isInteractive,
                shape: shape
            )
        )
    }

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
    @available(*, deprecated, message: "Use SFKButton(style:) for buttons, or sfkGlass(material:tint:isInteractive:shape:) for custom surfaces.")
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

#Preview("Custom Glass Surfaces") {
    HStack(spacing: 20) {
        Text("A")
            .font(.headline.weight(.bold))
            .frame(width: 56, height: 56)
            .sfkGlass(
                material: .regular,
                tint: .blue,
                isInteractive: true,
                shape: .circle
            )

        Text("B")
            .font(.headline.weight(.bold))
            .frame(height: 44)
            .padding(.horizontal, 18)
            .sfkGlass(
                material: .clear,
                tint: .green,
                isInteractive: true,
                shape: .capsule
            )
    }
    .padding(24)
}
