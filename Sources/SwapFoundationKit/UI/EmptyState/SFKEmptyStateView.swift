/*****************************************************************************
 * SFKEmptyStateView.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI

/// Centered empty / error placeholder with optional primary action.
///
/// Use for list and screen empty states. Pass host-app brand color via
/// `actionColor` when the optional CTA should match product accent.
@available(iOS 16, *)
public struct SFKEmptyStateView: View {
    private enum MessageContent {
        case key(LocalizedStringKey)
        case verbatim(String)
    }

    @Environment(\.sfkTheme) private var theme
    private let title: LocalizedStringKey
    private let message: MessageContent
    private let systemImage: String
    private let actionTitle: String?
    private let actionSystemImage: String?
    private let actionColor: Color?
    private let actionAccessibilityIdentifier: String?
    private let action: (() -> Void)?

    public init(
        title: LocalizedStringKey,
        message: LocalizedStringKey,
        systemImage: String,
        actionTitle: String? = nil,
        actionSystemImage: String? = nil,
        actionColor: Color? = nil,
        actionAccessibilityIdentifier: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.message = .key(message)
        self.systemImage = systemImage
        self.actionTitle = actionTitle
        self.actionSystemImage = actionSystemImage
        self.actionColor = actionColor
        self.actionAccessibilityIdentifier = actionAccessibilityIdentifier
        self.action = action
    }

    /// Use when `message` is an already-localized runtime string (e.g. an error
    /// description) rather than a lookup key.
    public init(
        title: LocalizedStringKey,
        message: String,
        systemImage: String,
        actionTitle: String? = nil,
        actionSystemImage: String? = nil,
        actionColor: Color? = nil,
        actionAccessibilityIdentifier: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.message = .verbatim(message)
        self.systemImage = systemImage
        self.actionTitle = actionTitle
        self.actionSystemImage = actionSystemImage
        self.actionColor = actionColor
        self.actionAccessibilityIdentifier = actionAccessibilityIdentifier
        self.action = action
    }

    @ViewBuilder
    private var messageText: some View {
        switch message {
        case .key(let key):
            Text(key)
        case .verbatim(let string):
            Text(verbatim: string)
        }
    }

    public var body: some View {
        VStack(spacing: theme.spacing.section) {
            Image(systemName: systemImage)
                .font(.system(size: 38, weight: .medium))
                .symbolRenderingMode(.monochrome)
                .foregroundStyle(theme.colors.secondaryText)
                .accessibilityHidden(true)

            VStack(spacing: theme.spacing.inline) {
                Text(title)
                    .font(theme.typography.title)
                    .foregroundStyle(theme.colors.text)

                messageText
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
            }

            if let actionTitle, let action {
                SFKButton(actionTitle, role: .primary, action: action)
                    .sfkIcon(actionSystemImage)
                    .sfkFullWidth(false)
                    .sfkTint(actionColor)
                .accessibilityIdentifier(actionAccessibilityIdentifier ?? "emptyStateActionButton")
            }
        }
        .padding(.horizontal, theme.spacing.section)
        .padding(.vertical, theme.spacing.section + theme.spacing.inline / 2)
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .contain)
    }
}

#if DEBUG
#Preview("With Action") {
    SFKEmptyStateView(
        title: "No Items Yet",
        message: "Add your first item to get started.",
        systemImage: "tray",
        actionTitle: "Add Item",
        actionSystemImage: "plus"
    ) {}
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("Informational") {
    SFKEmptyStateView(
        title: "No Data",
        message: "Nothing matched the selected filters.",
        systemImage: "chart.bar.xaxis"
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}
#endif
