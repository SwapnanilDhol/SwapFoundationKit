//
//  SFKTypography.swift
//  SwapFoundationKit
//
//  Created by Swapnanil Dhol on 4/30/26.
//

import SwiftUI

/// A collection of reusable typography style modifiers using the `.rounded` font design
/// for a consistent, friendly aesthetic across flows and screens.
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
        self
            .font(.system(.title, design: .rounded).weight(.bold))
            .foregroundStyle(.primary)
            .minimumScaleFactor(0.8)
    }

    /// A medium-weight subtitle style using `.body` size with rounded design.
    /// Suitable for descriptive text below titles.
    /// Uses primary at reduced opacity instead of `.secondary` so body copy stays
    /// readable on light system backgrounds (≈4.5:1 on white).
    func sfkFlowSubtitleStyle() -> some View {
        self
            .font(.system(.body, design: .rounded).weight(.medium))
            .foregroundStyle(Color.primary.opacity(0.68))
    }

    /// A semibold card title style using `.headline` size with rounded design.
    /// Suitable for titles inside cards or sections.
    func sfkFlowCardTitleStyle() -> some View {
        self
            .font(.system(.headline, design: .rounded).weight(.semibold))
            .foregroundStyle(.primary)
    }

    /// A body text style using `.subheadline` size with rounded design.
    /// Suitable for card body text and descriptions.
    func sfkFlowCardBodyStyle() -> some View {
        self
            .font(.system(.subheadline, design: .rounded))
            .foregroundStyle(.secondary)
    }

    /// A semibold chip label style using `.subheadline` size with rounded design.
    /// Suitable for text inside selectable chips and tags.
    func sfkFlowChipStyle() -> some View {
        self
            .font(.system(.subheadline, design: .rounded).weight(.semibold))
            .foregroundStyle(.primary)
    }

    /// A bold question style using `.title2` size with rounded design.
    /// Suitable for question prompts in multi-step flows.
    func sfkFlowQuestionStyle() -> some View {
        self
            .font(.system(.title2, design: .rounded).weight(.bold))
            .foregroundStyle(.primary)
            .minimumScaleFactor(0.8)
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
