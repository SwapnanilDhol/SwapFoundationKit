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
            HStack(spacing: 14) {
                iconContainer
                labelStack
                Spacer()
                trailingContent
            }
            .contentShape(Rectangle())
        }
        // Match sheet/navigation rows inside `Form`: `.plain` can fail to receive taps.
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

    private var labelStack: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.body.weight(.semibold))
                .foregroundStyle(.primary)

            if !subtitle.isEmpty {
                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    @ViewBuilder
    private var trailingContent: some View {
        HStack(alignment: .center, spacing: 8) {
            if let trailing = trailingView {
                trailing
            }
            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
        }
        .multilineTextAlignment(.trailing)
    }
}

/// A display-only settings label row (no tap action).
public struct SFKSettingsLabel: View {

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
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(tint.opacity(0.14))

                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(tint)
            }
            .frame(width: 36, height: 36)

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
