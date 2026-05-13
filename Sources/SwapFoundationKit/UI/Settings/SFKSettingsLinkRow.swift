//
//  SFKSettingsLinkRow.swift
//  SwapFoundationKit
//
//  Created by Swapnanil Dhol on 4/4/26.
//

import SwiftUI

#if canImport(UIKit) && os(iOS)
import UIKit
#endif

/// A settings row that opens a URL when tapped.
///
/// ## Usage
/// ```swift
/// SFKSettingsLinkRow(
///     title: "Privacy Policy",
///     subtitle: "Read our privacy policy",
///     icon: "hand.raised",
///     tint: .blue,
///     url: URL(string: "https://example.com/privacy")!
/// )
/// ```
public struct SFKSettingsLinkRow: View {
    @Environment(\.sfkSettingsTheme) private var theme

    private let title: String
    private let subtitle: String
    private let icon: String
    private let tint: Color?
    private let url: URL

    /// Creates a link settings row.
    /// - Parameters:
    ///   - title: Primary text label.
    ///   - subtitle: Secondary text label.
    ///   - icon: SF Symbol name for the icon.
    ///   - tint: Tint color for the icon background and icon.
    ///   - url: The URL to open when tapped.
    public init(
        title: String,
        subtitle: String,
        icon: String,
        tint: Color? = nil,
        url: URL
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.tint = tint
        self.url = url
    }

    public var body: some View {
        Button {
            openURL()
        } label: {
            HStack(spacing: theme.metrics.rowSpacing) {
                iconContainer

                VStack(alignment: .leading, spacing: theme.metrics.labelSpacing) {
                    Text(title)
                        .font(theme.typography.titleFont)
                        .foregroundStyle(theme.colors.titleColor)

                    Text(subtitle)
                        .font(theme.typography.subtitleFont)
                        .foregroundStyle(theme.colors.subtitleColor)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Spacer()

                Image(systemName: "arrow.up.right")
                    .font(theme.typography.accessoryFont)
                    .foregroundStyle(theme.colors.accessoryColor)

                Image(systemName: "chevron.right")
                    .font(theme.typography.accessoryFont)
                    .foregroundStyle(theme.colors.accessoryColor)
            }
            .padding(.vertical, theme.metrics.rowVerticalPadding)
            .contentShape(Rectangle())
        }
        .buttonStyle(SFKSettingsFormRowButtonStyle())
    }

    private var iconContainer: some View {
        let resolvedTint = theme.resolvedTint(tint)
        return ZStack {
            RoundedRectangle(cornerRadius: theme.metrics.iconCornerRadius)
                .fill(resolvedTint.opacity(theme.colors.iconBackgroundOpacity))

            Image(systemName: icon)
                .font(theme.typography.iconFont)
                .foregroundStyle(resolvedTint)
        }
        .frame(width: theme.metrics.iconTileSize, height: theme.metrics.iconTileSize)
    }

    private func openURL() {
        #if canImport(UIKit) && os(iOS)
        UIApplication.shared.open(url)
        #endif
    }
}

/// A settings row styled as a destructive action (e.g., Delete Account).
///
/// ## Usage
/// ```swift
/// SFKSettingsDestructiveRow(
///     title: "Delete Account",
///     subtitle: "Permanently delete your account and data",
///     icon: "trash",
///     action: {
///         // Handle deletion
///     }
/// )
/// ```
public struct SFKSettingsDestructiveRow: View {
    @Environment(\.sfkSettingsTheme) private var theme

    private let title: String
    private let subtitle: String
    private let icon: String
    private let action: () -> Void

    /// Creates a destructive action settings row.
    /// - Parameters:
    ///   - title: Primary text label.
    ///   - subtitle: Secondary text label.
    ///   - icon: SF Symbol name for the icon.
    ///   - action: The destructive action to perform.
    public init(
        title: String,
        subtitle: String,
        icon: String,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: theme.metrics.rowSpacing) {
                ZStack {
                    RoundedRectangle(cornerRadius: theme.metrics.iconCornerRadius)
                        .fill(theme.colors.destructiveTint.opacity(theme.colors.iconBackgroundOpacity))

                    Image(systemName: icon)
                        .font(theme.typography.iconFont)
                        .foregroundStyle(theme.colors.destructiveTint)
                }
                .frame(width: theme.metrics.iconTileSize, height: theme.metrics.iconTileSize)

                VStack(alignment: .leading, spacing: theme.metrics.labelSpacing) {
                    Text(title)
                        .font(theme.typography.titleFont)
                        .foregroundStyle(theme.colors.destructiveTint)

                    Text(subtitle)
                        .font(theme.typography.subtitleFont)
                        .foregroundStyle(theme.colors.subtitleColor)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Spacer()
            }
            .padding(.vertical, theme.metrics.rowVerticalPadding)
            .contentShape(Rectangle())
        }
        .buttonStyle(SFKSettingsFormRowButtonStyle())
    }
}

/// A settings row that requires confirmation before executing an action.
///
/// ## Usage
/// ```swift
/// SFKSettingsConfirmationRow(
///     title: "Reset All Data",
///     subtitle: "Clear all app data",
///     icon: "exclamationmark.triangle",
///     tint: .orange,
///     confirmationTitle: "Reset Data?",
///     confirmationMessage: "This action cannot be undone.",
///     confirmTitle: "Reset",
///     confirmStyle: .destructive,
///     onConfirm: {
///         // Reset data
///     }
/// )
/// ```
public struct SFKSettingsConfirmationRow: View {
    @Environment(\.sfkSettingsTheme) private var theme

    private let title: String
    private let subtitle: String
    private let icon: String
    private let tint: Color?
    private let confirmationTitle: String
    private let confirmationMessage: String
    private let confirmTitle: String
    private let confirmStyle: SFKConfirmationActionStyle
    private let onConfirm: () -> Void

    @State private var showConfirmation = false

    /// Creates a confirmation row.
    /// - Parameters:
    ///   - title: Primary text label.
    ///   - subtitle: Secondary text label.
    ///   - icon: SF Symbol name for the icon.
    ///   - tint: Tint color for the icon background and icon.
    ///   - confirmationTitle: Title of the confirmation alert.
    ///   - confirmationMessage: Message of the confirmation alert.
    ///   - confirmTitle: Title of the confirm button.
    ///   - confirmStyle: Style of the confirm button.
    ///   - onConfirm: Action to execute after confirmation.
    public init(
        title: String,
        subtitle: String,
        icon: String,
        tint: Color? = nil,
        confirmationTitle: String,
        confirmationMessage: String,
        confirmTitle: String = "Confirm",
        confirmStyle: SFKConfirmationActionStyle = .default,
        onConfirm: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.tint = tint
        self.confirmationTitle = confirmationTitle
        self.confirmationMessage = confirmationMessage
        self.confirmTitle = confirmTitle
        self.confirmStyle = confirmStyle
        self.onConfirm = onConfirm
    }

    public var body: some View {
        Button {
            showConfirmation = true
        } label: {
            HStack(spacing: theme.metrics.rowSpacing) {
                iconContainer

                VStack(alignment: .leading, spacing: theme.metrics.labelSpacing) {
                    Text(title)
                        .font(theme.typography.titleFont)
                        .foregroundStyle(theme.colors.titleColor)

                    Text(subtitle)
                        .font(theme.typography.subtitleFont)
                        .foregroundStyle(theme.colors.subtitleColor)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(theme.typography.accessoryFont)
                    .foregroundStyle(theme.colors.accessoryColor)
            }
            .padding(.vertical, theme.metrics.rowVerticalPadding)
            .contentShape(Rectangle())
        }
        .buttonStyle(SFKSettingsFormRowButtonStyle())
        .confirmationDialog(confirmationTitle, isPresented: $showConfirmation, titleVisibility: .visible) {
            Button(confirmTitle, role: confirmStyle == .destructive ? .destructive : nil) {
                onConfirm()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(confirmationMessage)
        }
    }

    private var iconContainer: some View {
        let resolvedTint = theme.resolvedTint(tint)
        return ZStack {
            RoundedRectangle(cornerRadius: theme.metrics.iconCornerRadius)
                .fill(resolvedTint.opacity(theme.colors.iconBackgroundOpacity))

            Image(systemName: icon)
                .font(theme.typography.iconFont)
                .foregroundStyle(resolvedTint)
        }
        .frame(width: theme.metrics.iconTileSize, height: theme.metrics.iconTileSize)
    }
}

/// Style for confirmation actions.
public enum SFKConfirmationActionStyle {
    case `default`
    case destructive
}


// MARK: - Previews

#Preview("SFKSettingsLinkRow") {
    List {
        SFKSettingsLinkRow(
            title: "Privacy Policy",
            subtitle: "Read our privacy policy",
            icon: "hand.raised.fill",
            tint: .blue,
            url: URL(string: "https://example.com/privacy")!
        )
        SFKSettingsLinkRow(
            title: "Terms of Service",
            subtitle: "Read our terms",
            icon: "doc.text.fill",
            tint: .green,
            url: URL(string: "https://example.com/terms")!
        )
    }
}

#Preview("SFKSettingsDestructiveRow") {
    List {
        SFKSettingsDestructiveRow(
            title: "Delete Account",
            subtitle: "Permanently delete your account and all data",
            icon: "trash.fill",
            action: {}
        )
    }
}

#Preview("SFKSettingsConfirmationRow") {
    List {
        SFKSettingsConfirmationRow(
            title: "Reset All Data",
            subtitle: "Clear all app data and settings",
            icon: "exclamationmark.triangle.fill",
            tint: .orange,
            confirmationTitle: "Reset Data?",
            confirmationMessage: "This action cannot be undone. All your data will be permanently deleted.",
            confirmTitle: "Reset",
            confirmStyle: .destructive
        ) {}
    }
}
