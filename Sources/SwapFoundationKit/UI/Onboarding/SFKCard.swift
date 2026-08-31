//
//  SFKCard.swift
//  SwapFoundationKit
//
//  Created by Swapnanil Dhol on 4/30/26.
//

import SwiftUI

/// A generic rounded-rectangle card container with a configurable background,
/// corner radius, and padding.
///
/// Use this component to wrap content that needs a distinct card-like appearance,
/// such as solution cards, testimonial cards, feature summaries, or any grouped content.
///
/// ## Usage
/// ```swift
/// // Simple card with default styling
/// SFKCard {
///     Text("Card content goes here")
/// }
///
/// // Card with custom surface and corner radius
/// SFKCard(cornerRadius: 16, backgroundFill: .blue.opacity(0.1)) {
///     VStack {
///         Text("Custom Card")
///             .sfkFlowCardTitleStyle()
///         Text("With custom styling")
///             .sfkFlowCardBodyStyle()
///     }
/// }
///
/// // Card with leading icon
/// SFKCard(icon: "star.fill", iconTint: .yellow) {
///     Text("Featured content")
/// }
/// ```
public struct SFKCard<Content: View>: View {
    @Environment(\.sfkTheme) private var theme
    /// The card content.
    public let content: Content

    /// The corner radius of the card.
    public var cornerRadius: CGFloat

    /// The background fill color.
    public var backgroundFill: Color

    /// An optional leading icon SF Symbol name.
    public var icon: String?

    /// The tint color for the optional icon background.
    public var iconTint: Color

    /// The padding applied to the card content.
    public var padding: CGFloat

    /// The alignment of the card content.
    public var alignment: Alignment

    private let usesThemeCornerRadius: Bool
    private let usesThemeBackground: Bool

    /// Creates a card with default styling.
    /// - Parameters:
    ///   - cornerRadius: The corner radius. Defaults to 12.
    ///   - backgroundFill: The background color. Defaults to `.secondarySystemBackground`.
    ///   - icon: An optional leading icon. Defaults to `nil`.
    ///   - iconTint: The icon background tint. Defaults to `.orange`.
    ///   - padding: Content padding. Defaults to 16.
    ///   - alignment: Content alignment. Defaults to `.leading`.
    ///   - content: The card content.
    public init(
        cornerRadius: CGFloat? = nil,
        backgroundFill: Color? = nil,
        icon: String? = nil,
        iconTint: Color = .orange,
        padding: CGFloat = 16,
        alignment: Alignment = .leading,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius ?? 12
        self.backgroundFill = backgroundFill ?? Color(.secondarySystemBackground)
        self.usesThemeCornerRadius = cornerRadius == nil
        self.usesThemeBackground = backgroundFill == nil
        self.icon = icon
        self.iconTint = iconTint
        self.padding = padding
        self.alignment = alignment
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: alignment.horizontal, spacing: theme.spacing.inline) {
            if let icon {
                HStack(spacing: theme.spacing.inline) {
                    ZStack {
                        RoundedRectangle(cornerRadius: theme.radii.control, style: .continuous)
                            .fill(iconTint.opacity(0.14))
                        Image(systemName: icon)
                            .font(theme.typography.caption.bold())
                            .foregroundStyle(iconTint)
                    }
                    .frame(width: 28, height: 28)

                    Spacer()
                }
            }

            content
        }
        .padding(padding)
        .frame(maxWidth: .infinity, alignment: alignment)
        .background(
            RoundedRectangle(cornerRadius: resolvedCornerRadius, style: .continuous)
                .fill(resolvedBackgroundFill)
            .overlay {
                    RoundedRectangle(cornerRadius: resolvedCornerRadius, style: .continuous)
                        .strokeBorder(theme.colors.border, lineWidth: 1)
                }
        )
    }

    private var resolvedCornerRadius: CGFloat {
        usesThemeCornerRadius ? theme.radii.card : cornerRadius
    }

    private var resolvedBackgroundFill: Color {
        usesThemeBackground ? theme.colors.surface : backgroundFill
    }
}

#Preview("SFKCard") {
    VStack(spacing: 16) {
        SFKCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("Simple Card")
                    .sfkFlowCardTitleStyle()
                Text("This is a basic card with default styling and secondary system background.")
                    .sfkFlowCardBodyStyle()
            }
        }

        SFKCard(icon: "star.fill", iconTint: .yellow) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Card with Icon")
                    .sfkFlowCardTitleStyle()
                Text("This card has a leading star icon with yellow tint.")
                    .sfkFlowCardBodyStyle()
            }
        }

        SFKCard(cornerRadius: 16, backgroundFill: Color.blue.opacity(0.08), icon: "info.circle.fill", iconTint: .blue) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Custom Styled Card")
                    .sfkFlowCardTitleStyle()
                Text("Custom corner radius, background tint, and icon color.")
                    .sfkFlowCardBodyStyle()
            }
        }
    }
    .padding(24)
}
