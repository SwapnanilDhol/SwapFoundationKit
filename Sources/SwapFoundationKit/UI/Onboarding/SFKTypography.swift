//
//  SFKTypography.swift
//  SwapFoundationKit
//
//  Created by Swapnanil Dhol on 4/30/26.
//

import SwiftUI

/// A collection of reusable typography style modifiers backed by ``SFKTheme``
/// semantic fonts across flows and screens.
///
/// ## Usage
/// ```swift
/// Text("Welcome")
///     .sfkFlowTitleStyle()
///
/// Text("Tell us about your goals")
///     .sfkFlowQuestionStyle()
///
/// Text("This helps us personalize your experience")
///     .sfkFlowSubtitleStyle()
///
/// Text("Card Title")
///     .sfkFlowCardTitleStyle()
///
/// Text("Card body text goes here")
///     .sfkFlowCardBodyStyle()
///
/// Text("Chip Label")
///     .sfkFlowChipStyle()
/// ```
public extension View {
    /// A bold title style using `.title` size with rounded design.
    /// Suitable for screen headers and welcome titles.
    func sfkFlowTitleStyle() -> some View {
        modifier(SFKFlowTypographyModifier(style: .title))
    }

    /// A medium-weight subtitle style using `.body` size with rounded design.
    /// Suitable for descriptive text below titles.
    /// Uses primary at reduced opacity instead of `.secondary` so body copy stays
    /// readable on light system backgrounds (≈4.5:1 on white).
    func sfkFlowSubtitleStyle() -> some View {
        modifier(SFKFlowTypographyModifier(style: .subtitle))
    }

    /// A semibold card title style using `.headline` size with rounded design.
    /// Suitable for titles inside cards or sections.
    func sfkFlowCardTitleStyle() -> some View {
        modifier(SFKFlowTypographyModifier(style: .cardTitle))
    }

    /// A body text style using `.subheadline` size with rounded design.
    /// Suitable for card body text and descriptions.
    func sfkFlowCardBodyStyle() -> some View {
        modifier(SFKFlowTypographyModifier(style: .cardBody))
    }

    /// A semibold chip label style using `.subheadline` size with rounded design.
    /// Suitable for text inside selectable chips and tags.
    func sfkFlowChipStyle() -> some View {
        modifier(SFKFlowTypographyModifier(style: .chip))
    }

    /// A bold question style using `.title2` size with rounded design.
    /// Suitable for question prompts in multi-step flows.
    func sfkFlowQuestionStyle() -> some View {
        modifier(SFKFlowTypographyModifier(style: .question))
    }
}

private struct SFKFlowTypographyModifier: ViewModifier {
    @Environment(\.sfkTheme) private var theme

    enum Style {
        case title
        case question
        case subtitle
        case cardTitle
        case cardBody
        case chip
    }

    let style: Style

    @ViewBuilder
    func body(content: Content) -> some View {
        switch style {
        case .title:
            content
                .font(theme.typography.title.weight(.bold))
                .foregroundStyle(theme.colors.text)
                .minimumScaleFactor(0.8)
        case .question:
            content
                .font(theme.typography.title.weight(.bold))
                .foregroundStyle(theme.colors.text)
                .minimumScaleFactor(0.8)
        case .subtitle:
            content
                .font(theme.typography.body.weight(.medium))
                .foregroundStyle(theme.colors.secondaryText)
        case .cardTitle:
            content
                .font(theme.typography.body.weight(.semibold))
                .foregroundStyle(theme.colors.text)
        case .cardBody:
            content
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.secondaryText)
        case .chip:
            content
                .font(theme.typography.caption.weight(.semibold))
                .foregroundStyle(theme.colors.text)
        }
    }
}

#Preview("SFKTypography") {
    VStack(alignment: .leading, spacing: 16) {
        Text("Flow Title Style")
            .sfkFlowTitleStyle()

        Text("Flow Question Style")
            .sfkFlowQuestionStyle()

        Text("Flow Subtitle Style — this is descriptive text that appears below a title")
            .sfkFlowSubtitleStyle()

        Text("Flow Card Title Style")
            .sfkFlowCardTitleStyle()

        Text("Flow Card Body Style — supporting text inside a card component")
            .sfkFlowCardBodyStyle()

        Text("Flow Chip Style")
            .sfkFlowChipStyle()
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Capsule().fill(Color(.secondarySystemBackground)))
    }
    .padding(24)
}
