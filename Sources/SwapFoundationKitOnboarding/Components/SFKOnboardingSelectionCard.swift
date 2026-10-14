/****************************************************************************
 * SFKOnboardingSelectionCard.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwapFoundationKit
import SwiftUI

/// A selectable row for onboarding questions: an icon tile, a title, an
/// optional subtitle and a check circle, tinted per option.
///
/// The card's resting fill and text use ``SFKTheme`` colours; `tint` colours
/// the icon tile, the selected fill and stroke, and the check.
///
/// ## Usage
/// ```swift
/// SFKOnboardingSelectionCard(
///     emoji: "✈️",
///     title: "A trip",
///     subtitle: "Flights, stays, the lot",
///     tint: .blue,
///     isSelected: selection.contains(.trip),
///     accessibilityIdentifier: "onboarding.goal.trip"
/// ) {
///     toggle(.trip)
/// }
/// ```
public struct SFKOnboardingSelectionCard<Icon: View>: View {
    @Environment(\.sfkTheme) private var theme

    private let title: String
    private let subtitle: String?
    private let tint: Color
    private let isSelected: Bool
    private let accessibilityIdentifier: String?
    private let action: () -> Void
    private let icon: Icon

    /// - Parameters:
    ///   - title: The option's title.
    ///   - subtitle: An optional line or two under the title.
    ///   - tint: The option's colour.
    ///   - isSelected: Whether the option is selected.
    ///   - accessibilityIdentifier: UI-test identifier.
    ///   - action: Runs on tap; toggle the selection here.
    ///   - icon: The content of the 38 pt icon tile.
    public init(
        title: String,
        subtitle: String? = nil,
        tint: Color,
        isSelected: Bool,
        accessibilityIdentifier: String? = nil,
        action: @escaping () -> Void,
        @ViewBuilder icon: () -> Icon
    ) {
        self.title = title
        self.subtitle = subtitle
        self.tint = tint
        self.isSelected = isSelected
        self.accessibilityIdentifier = accessibilityIdentifier
        self.action = action
        self.icon = icon()
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                icon
                    .frame(width: 38, height: 38)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(tint.opacity(isSelected ? 0.20 : 0.12))
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(.subheadline, design: .rounded).weight(.semibold))
                        .foregroundStyle(theme.colors.text)

                    if let subtitle {
                        Text(subtitle)
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(theme.colors.secondaryText)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                Spacer(minLength: 8)

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? tint : theme.colors.secondaryText.opacity(0.4))
                    .contentTransition(.symbolEffect(.replace))
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(cardBackground)
            .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(SFKOnboardingPressableRowButtonStyle())
        .accessibilityIdentifier(accessibilityIdentifier ?? "")
        .accessibilityLabel(title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(
                isSelected ? tint.opacity(0.09) : theme.colors.surface
            )
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(
                        isSelected ? tint.opacity(0.36) : theme.colors.text.opacity(0.05),
                        lineWidth: 1
                    )
            }
    }
}

public extension SFKOnboardingSelectionCard where Icon == SFKOnboardingSelectionEmoji {
    /// A card whose icon tile holds an emoji.
    init(
        emoji: String,
        title: String,
        subtitle: String? = nil,
        tint: Color,
        isSelected: Bool,
        accessibilityIdentifier: String? = nil,
        action: @escaping () -> Void
    ) {
        self.init(
            title: title,
            subtitle: subtitle,
            tint: tint,
            isSelected: isSelected,
            accessibilityIdentifier: accessibilityIdentifier,
            action: action
        ) {
            SFKOnboardingSelectionEmoji(emoji)
        }
    }
}

#Preview {
    VStack(spacing: 10) {
        SFKOnboardingSelectionCard(emoji: "✈️", title: "A trip", subtitle: "Flights, stays, the lot", tint: .blue, isSelected: true) {}
        SFKOnboardingSelectionCard(emoji: "🏠", title: "A home", tint: .orange, isSelected: false) {}
        SFKOnboardingSelectionCard(title: "Something else", tint: .purple, isSelected: false, action: {}) {
            Image(systemName: "sparkles").foregroundStyle(.purple)
        }
    }
    .padding()
}
