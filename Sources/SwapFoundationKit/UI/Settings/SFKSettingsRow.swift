//
//  SFKSettingsRow.swift
//  SwapFoundationKit
//
//  Created by Swapnanil Dhol on 4/4/26.
//

import SwiftUI

/// A simple text view styled by the settings theme for use as trailing row content.
struct SFKSettingsValueText: View {
    @Environment(\.sfkTheme) private var theme

    let text: String

    init(_ text: String) { self.text = text }

    var body: some View {
        Text(text)
            .font(theme.typography.body)
            .foregroundStyle(theme.colors.secondaryText)
            .multilineTextAlignment(.trailing)
    }
}

/// A reusable SwiftUI row component for displaying an action or navigation item.
///
/// Renders an icon in a colored rounded rectangle, followed by title and subtitle,
/// and optionally a themed trailing value and chevron.
///
/// ## Usage
/// ```swift
/// SFKSettingsRow("About", subtitle: "Learn more", systemImage: "info.circle") { ... }
/// ```
public struct SFKSettingsRow: View {
    @Environment(\.sfkTheme) private var theme
    private let hapticsHelper = HapticsHelper()

    private let icon: String
    private let title: String
    private let subtitle: String
    private let tint: Color?
    private var showChevron = true
    private let action: () -> Void
    private var trailingText: String?

    /// Creates an action or navigation row.
    /// This is the concise v4 builder-path initializer.
    public init(
        _ title: String,
        subtitle: String = "",
        systemImage: String = "arrow.forward",
        tint: Color? = nil,
        action: @escaping () -> Void
    ) {
        self.icon = systemImage
        self.title = title
        self.subtitle = subtitle
        self.tint = tint
        self.action = action
    }

    /// Overrides whether the row shows its disclosure chevron.
    public func settingsRowChevron(_ isVisible: Bool) -> Self {
        var copy = self
        copy.showChevron = isVisible
        return copy
    }

    /// Adds a themed trailing value while retaining the row's native rendering.
    public func settingsRowValue(_ value: String?) -> Self {
        var copy = self
        copy.trailingText = value
        return copy
    }

    public var body: some View {
        Button {
            hapticsHelper.mediumImpact()
            action()
        } label: {
            _SFKSettingsRowContent(
                title: title,
                subtitle: subtitle,
                icon: icon,
                tint: tint ?? theme.colors.accent
            ) {
                trailingContent
            }
            .padding(.vertical, theme.spacing.control / 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(SFKSettingsFormRowButtonStyle())
    }

    @ViewBuilder
    private var trailingContent: some View {
        HStack(alignment: .center, spacing: theme.spacing.inline) {
            if let trailingText {
                SFKSettingsValueText(trailingText)
            }
            if showChevron {
                Image(systemName: "chevron.right")
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.secondaryText)
            }
        }
    }
}

struct _SFKSettingsRowContent<Trailing: View>: View {
    @Environment(\.sfkTheme) private var theme

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
        HStack(spacing: theme.spacing.inline) {
            ZStack {
                RoundedRectangle(cornerRadius: theme.radii.control)
                    .fill(iconBackgroundColor ?? tint.opacity(0.14))

                Image(systemName: icon)
                    .font(theme.typography.caption.weight(.semibold))
                    .foregroundStyle(tint)
            }
            .frame(width: 28, height: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(theme.typography.body.weight(.semibold))
                    .foregroundStyle(titleColor ?? theme.colors.text)

                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(theme.typography.caption)
                        .foregroundStyle(subtitleColor ?? theme.colors.secondaryText)
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

#Preview("SFKSettingsRow") {
    List {
        SFKSettingsRow(
            "Version",
            subtitle: "Current installed version",
            systemImage: "info.circle.fill",
            tint: .secondary,
            action: {}
        )
        .settingsRowChevron(false)
        .settingsRowValue("1.0.0 (100)")
        SFKSettingsRow("Privacy", subtitle: "Privacy settings and data", systemImage: "lock.circle.fill", tint: .green) {}
    }
}
