//
//  SFKSettingsToggle.swift
//  SwapFoundationKit
//
//  Created by Swapnanil Dhol on 4/4/26.
//

import SwiftUI

/// A settings row component with a SwiftUI Toggle.
//
///
///
/// ## Usage
/// ```swift
/// struct MySettingsView: View {
///     @AppStorage("savePassOnCreate") private var savePassOnCreate = false
///
///     var body: some View {
///         SFKSettingsToggle(
///             title: "Save Pass on Create",
///             subtitle: "Automatically keep a draft after you generate a Wallet pass.",
///             icon: "square.and.arrow.down",
///             tint: .blue,
///             isOn: $savePassOnCreate
///         )
///     }
/// }
/// ```
public struct SFKSettingsToggle: View {

    private let title: String
    private let subtitle: String
    private let icon: String
    private let tint: Color
    @Binding private var isOn: Bool

    /// Creates a settings toggle row.
    /// - Parameters:
    ///   - title: Primary text label.
    ///   - subtitle: Secondary text label.
    ///   - icon: SF Symbol name for the icon.
    ///   - tint: Tint color for the icon background and icon.
    ///   - isOn: Binding to the toggle state.
    public init(
        title: String,
        subtitle: String,
        icon: String,
        tint: Color,
        isOn: Binding<Bool>
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.tint = tint
        self._isOn = isOn
    }

    public var body: some View {
        Toggle(isOn: $isOn) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(tint.opacity(0.14))

                    Image(systemName: icon)
                        .font(.caption.bold())
                        .foregroundStyle(tint)
                }
                .frame(width: 28, height: 28)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .foregroundStyle(.primary)

                    Text(subtitle)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .toggleStyle(.switch)
        .tint(tint)
    }
}

/// A settings toggle row using a SettingsItem-style configuration.
///
/// ## Usage
/// ```swift
/// struct MyToggleItem: SettingsItem {
///     case notifications
///
///     var id: String { "notifications" }
///     var icon: String { "bell.circle.fill" }
///     var title: String { "Notifications" }
///     var subtitle: String { "Receive push notifications" }
///     var tint: Color { .blue }
/// }
///
/// SFKSettingsToggleRow(item: MyToggleItem(), isOn: $isEnabled)
/// ```
public struct SFKSettingsToggleRow<Item: SettingsItem>: View {

    private let item: Item
    @Binding private var isOn: Bool

    /// Creates a settings toggle row from a SettingsItem.
    /// - Parameters:
    ///   - item: The settings item defining icon, title, subtitle, and tint.
    ///   - isOn: Binding to the toggle state.
    public init(
        item: Item,
        isOn: Binding<Bool>
    ) {
        self.item = item
        self._isOn = isOn
    }

    public var body: some View {
        Toggle(isOn: $isOn) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(item.tint.opacity(0.14))

                    Image(systemName: item.icon)
                        .font(.caption.bold())
                        .foregroundStyle(item.tint)
                }
                .frame(width: 28, height: 28)

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.title)
                        .font(.body)
                        .foregroundStyle(.primary)

                    Text(item.subtitle)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .toggleStyle(.switch)
        .tint(item.tint)
    }
}

// MARK: - Previews

private enum PreviewToggleItem: String, SettingsItem {
    case enabled
    case disabled

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .enabled: return "power.circle.fill"
        case .disabled: return "power.circle"
        }
    }

    var title: String { rawValue.capitalized }
    var subtitle: String { "Sample toggle item" }
    var tint: Color { .green }
}

#Preview("SFKSettingsToggle") {
    @Previewable @State var value = true

    List {
        SFKSettingsToggle(
            title: "Push Notifications",
            subtitle: "Receive push notifications",
            icon: "bell.badge.fill",
            tint: .blue,
            isOn: $value
        )

        SFKSettingsToggle(
            title: "Dark Mode",
            subtitle: "Use dark appearance",
            icon: "moon.fill",
            tint: .purple,
            isOn: .constant(false)
        )
    }
}

#Preview("SFKSettingsToggleRow") {
    @Previewable @State var value = true

    List {
        SFKSettingsToggleRow(item: PreviewToggleItem.enabled, isOn: $value)
        SFKSettingsToggleRow(item: PreviewToggleItem.disabled, isOn: .constant(false))
    }
}
