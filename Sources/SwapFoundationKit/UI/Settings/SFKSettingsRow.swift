//
//  SFKSettingsRow.swift
//  SwapFoundationKit
//
//  Created by Swapnanil Dhol on 4/4/26.
//

import SwiftUI

/// Trailing content for a settings row — either a themed value string or a fully custom view.
public enum SFKSettingsTrailing {
    /// A string rendered with the theme's `valueFont` and `valueColor`.
    case value(String)
    /// A fully custom trailing view. Theme styling is applied automatically (font + color).
    case custom(AnyView)
}

/// A simple text view styled by the settings theme for use as trailing row content.
public struct SFKSettingsValueText: View {
    @Environment(\.sfkSettingsTheme) private var theme

    let text: String

    public init(_ text: String) { self.text = text }

    public var body: some View {
        Text(text)
            .font(theme.typography.valueFont)
            .foregroundStyle(theme.colors.valueColor)
            .multilineTextAlignment(.trailing)
    }
}

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
/// // With themed trailing value
/// SFKSettingsRow(item: versionItem, trailingView: .value("1.0.0 (100)")) {}
/// ```
public struct SFKSettingsRow: View {
    @Environment(\.sfkSettingsTheme) private var theme

    private let icon: String
    private let title: String
    private let subtitle: String
    private let tint: Color
    private let showChevron: Bool
    private let action: () -> Void
    private let trailingView: SFKSettingsTrailing?

    /// Creates a settings row.
    /// - Parameters:
    ///   - item: The settings item to display.
    ///   - action: The action to perform when the row is tapped.
    ///   - showChevron: Whether to show chevron. Default is `true`.
    ///   - trailingView: Optional themed or custom trailing content.
    public init<Item: SettingsItem>(
        item: Item,
        action: @escaping () -> Void,
        showChevron: Bool = true,
        trailingView: SFKSettingsTrailing? = nil
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
            _SFKSettingsRowContent(
                title: title,
                subtitle: subtitle,
                icon: icon,
                tint: theme.resolvedItemTint(tint)
            ) {
                trailingContent
            }
            .padding(.vertical, theme.metrics.rowVerticalPadding)
            .contentShape(Rectangle())
        }
        .buttonStyle(SFKSettingsFormRowButtonStyle())
    }

    @ViewBuilder
    private var trailingContent: some View {
        HStack(alignment: .center, spacing: theme.metrics.trailingSpacing) {
            switch trailingView {
            case .value(let text):
                SFKSettingsValueText(text)
            case .custom(let view):
                view
                    .font(theme.typography.valueFont)
                    .foregroundStyle(theme.colors.valueColor)
                    .multilineTextAlignment(.trailing)
            case nil:
                EmptyView()
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
        return _SFKSettingsRowContent(
            title: title,
            subtitle: subtitle,
            icon: icon,
            tint: resolvedTint
        )
        .padding(.vertical, theme.metrics.rowVerticalPadding)
    }
}

struct _SFKSettingsRowContent<Trailing: View>: View {
    @Environment(\.sfkSettingsTheme) private var theme

    let title: String
    let subtitle: String
    let icon: String
    let tint: Color
    let iconBackgroundColor: Color?
    let titleColor: Color?
    let subtitleColor: Color?
    let trailing: Trailing

    init(
        title: String,
        subtitle: String,
        icon: String,
        tint: Color,
        iconBackgroundColor: Color? = nil,
        titleColor: Color? = nil,
        subtitleColor: Color? = nil,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.tint = tint
        self.iconBackgroundColor = iconBackgroundColor
        self.titleColor = titleColor
        self.subtitleColor = subtitleColor
        self.trailing = trailing()
    }

    var body: some View {
        HStack(spacing: theme.metrics.rowSpacing) {
            ZStack {
                RoundedRectangle(cornerRadius: theme.metrics.iconCornerRadius)
                    .fill(iconBackgroundColor ?? tint.opacity(theme.colors.iconBackgroundOpacity))

                Image(systemName: icon)
                    .font(theme.typography.iconFont)
                    .foregroundStyle(tint)
            }
            .frame(width: theme.metrics.iconTileSize, height: theme.metrics.iconTileSize)

            VStack(alignment: .leading, spacing: theme.metrics.labelSpacing) {
                Text(title)
                    .font(theme.typography.titleFont)
                    .foregroundStyle(titleColor ?? theme.colors.titleColor)

                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(theme.typography.subtitleFont)
                        .foregroundStyle(subtitleColor ?? theme.colors.subtitleColor)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            trailing
        }
    }
}

extension _SFKSettingsRowContent where Trailing == EmptyView {
    init(
        title: String,
        subtitle: String,
        icon: String,
        tint: Color,
        iconBackgroundColor: Color? = nil,
        titleColor: Color? = nil,
        subtitleColor: Color? = nil
    ) {
        self.init(
            title: title,
            subtitle: subtitle,
            icon: icon,
            tint: tint,
            iconBackgroundColor: iconBackgroundColor,
            titleColor: titleColor,
            subtitleColor: subtitleColor
        ) {
            EmptyView()
        }
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
            trailingView: .value("1.0.0 (100)")
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
