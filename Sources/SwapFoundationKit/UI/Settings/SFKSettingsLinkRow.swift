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

    private let title: String
    private let subtitle: String
    private let icon: String
    private let tint: Color
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
        tint: Color,
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
            HStack(spacing: 14) {
                iconContainer

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.primary)

                    Text(subtitle)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                Image(systemName: "arrow.up.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.tertiary)

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.borderless)
    }

    private var iconContainer: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(tint.opacity(0.14))

            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(tint)
        }
        .frame(width: 36, height: 36)
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
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.red.opacity(0.14))

                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.red)
                }
                .frame(width: 36, height: 36)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.red)

                    Text(subtitle)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.borderless)
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

    private let title: String
    private let subtitle: String
    private let icon: String
    private let tint: Color
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
        tint: Color,
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
            HStack(spacing: 14) {
                iconContainer

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.primary)

                    Text(subtitle)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.borderless)
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
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(tint.opacity(0.14))

            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(tint)
        }
        .frame(width: 36, height: 36)
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
