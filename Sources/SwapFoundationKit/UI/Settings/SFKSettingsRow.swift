//
//  SFKSettingsRow.swift
//  SwapFoundationKit
//
//  Created by Swapnanil Dhol on 4/4/26.
//

import SwiftUI

/// A reusable SwiftUI row component for displaying a settings item.
///
/// Renders an icon in a colored rounded rectangle, followed by title and subtitle,
/// and optionally a trailing view (chevron, text, or custom content).
///
/// ## Usage
/// ```swift
/// // Basic usage with SettingsItem
/// ForEach(AppInfoSectionItem.allCases, id: \.id) { item in
///     SFKSettingsRow(item: item) {
///         // Handle tap
///     }
/// }
///
/// // With custom trailing view
/// SFKSettingsRow(item: versionItem, trailingView: {
///     Text("1.0.0 (100)")
///         .font(.subheadline)
///         .foregroundStyle(.secondary)
/// })
/// ```
public struct SFKSettingsRow: View {
    @Environment(\.sfkSettingsTheme) private var theme

    private let icon: String
    private let title: String
    private let subtitle: String
    private let tint: Color
    private let showChevron: Bool
    private let action: () -> Void
    private let trailingView: AnyView?

    /// Creates a settings row.
    /// - Parameters:
    ///   - item: The settings item to display.
    ///   - action: The action to perform when the row is tapped.
    ///   - showChevron: Whether to show chevron. Default is `true`.
    ///   - trailingView: Optional custom trailing view.
    public init<Item: SettingsItem>(
        item: Item,
        action: @escaping () -> Void,
        showChevron: Bool = true,
        trailingView: AnyView? = nil
    ) {
        self.icon = item.icon
        self.title = item.title
        self.subtitle = item.subtitle
        self.tint = item.tint
        self.showChevron = showChevron
        self.action = action
        self.trailingView = trailingView
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: theme.metrics.rowSpacing) {
                iconContainer
                labelStack
                Spacer()
                trailingContent
            }
            .padding(.vertical, theme.metrics.rowVerticalPadding)
            .contentShape(Rectangle())
        }
        .buttonStyle(SFKSettingsFormRowButtonStyle())
    }

    private var iconContainer: some View {
        let resolvedTint = theme.resolvedItemTint(tint)
        return ZStack {
            RoundedRectangle(cornerRadius: theme.metrics.iconCornerRadius)
                .fill(resolvedTint.opacity(theme.colors.iconBackgroundOpacity))

            Image(systemName: icon)
                .font(theme.typography.iconFont)
                .foregroundStyle(resolvedTint)
        }
        .frame(width: theme.metrics.iconTileSize, height: theme.metrics.iconTileSize)
    }

    private var labelStack: some View {
        VStack(alignment: .leading, spacing: theme.metrics.labelSpacing) {
            Text(title)
                .font(theme.typography.titleFont)
                .foregroundStyle(theme.colors.titleColor)

            if !subtitle.isEmpty {
                Text(subtitle)
                    .font(theme.typography.subtitleFont)
                    .foregroundStyle(theme.colors.subtitleColor)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var trailingContent: some View {
        HStack(alignment: .center, spacing: theme.metrics.trailingSpacing) {
            if let trailing = trailingView {
                trailing
                    .font(theme.typography.valueFont)
                    .foregroundStyle(theme.colors.valueColor)
                    .multilineTextAlignment(.trailing)
            }
            if showChevron {
                Image(systemName: "chevron.right")
                    .font(theme.typography.accessoryFont)
                    .foregroundStyle(theme.colors.accessoryColor)
            }
        }
    }
}

/// A display-only settings label row (no tap action).
public struct SFKSettingsLabel: View {
    @Environment(\.sfkSettingsTheme) private var theme

    private let title: String
    private let subtitle: String
    private let icon: String
    private let tint: Color

    /// Creates a settings label row.
    public init(
        title: String,
        subtitle: String,
        icon: String,
        tint: Color
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.tint = tint
    }

    public var body: some View {
        let resolvedTint = theme.resolvedTint(tint)
        return HStack(spacing: theme.metrics.rowSpacing) {
            ZStack {
                RoundedRectangle(cornerRadius: theme.metrics.iconCornerRadius)
                    .fill(resolvedTint.opacity(theme.colors.iconBackgroundOpacity))

                Image(systemName: icon)
                    .font(theme.typography.iconFont)
                    .foregroundStyle(resolvedTint)
            }
            .frame(width: theme.metrics.iconTileSize, height: theme.metrics.iconTileSize)

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
        }
        .padding(.vertical, theme.metrics.rowVerticalPadding)
    }
}

// MARK: - Previews

private enum PreviewSettingsItem: String, SettingsItem {
    case notifications
    case privacy
    case version

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .notifications: return "bell.circle.fill"
        case .privacy: return "lock.circle.fill"
        case .version: return "info.circle.fill"
        }
    }

    var title: String {
        switch self {
        case .notifications: return "Notifications"
        case .privacy: return "Privacy"
        case .version: return "Version"
        }
    }

    var subtitle: String {
        switch self {
        case .notifications: return "Manage notification preferences"
        case .privacy: return "Privacy settings and data"
        case .version: return "Current app version"
        }
    }

    var tint: Color {
        switch self {
        case .notifications: return .blue
        case .privacy: return .green
        case .version: return .secondary
        }
    }
}

#Preview("SFKSettingsRow") {
    List {
        ForEach([PreviewSettingsItem.notifications, .privacy, .version], id: \.id) { item in
            SFKSettingsRow(item: item) {
                print("Tapped: \(item.title)")
            }
        }

        SFKSettingsRow(
            item: PreviewSettingsItem.version,
            action: {},
            showChevron: false,
            trailingView: AnyView(
                Text("1.0.0 (100)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            )
        )
    }
}

#Preview("SFKSettingsLabel") {
    List {
        SFKSettingsLabel(
            title: "App Version",
            subtitle: "Current installed version",
            icon: "info.circle.fill",
            tint: .secondary
        )
        SFKSettingsLabel(
            title: "Build",
            subtitle: "Debug build",
            icon: "hammer.fill",
            tint: .orange
        )
    }
}
