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
    @Environment(\.sfkTheme) private var theme

    private let title: String
    private let subtitle: String
    private let icon: String
    private let tint: Color?
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
        tint: Color? = nil,
        isOn: Binding<Bool>
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.tint = tint
        self._isOn = isOn
        self.action = nil
    }

    /// Creates a concise typed toggle for the v4 settings builder.
    public init(
        _ title: String,
        subtitle: String = "",
        systemImage: String = "checkmark.circle",
        tint: Color? = nil,
        isOn: Binding<Bool>,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = systemImage
        self.tint = tint
        self._isOn = isOn
        self.action = action
    }

    private let action: (() -> Void)?

    public var body: some View {
        let resolvedTint = tint ?? theme.colors.accent
        _SFKSettingsRowContent(
            title: title,
            subtitle: subtitle,
            icon: icon,
            tint: resolvedTint
        ) {
            Toggle(title, isOn: $isOn)
                .labelsHidden()
                .toggleStyle(.switch)
                .tint(tint ?? theme.colors.accent)
                .onChange(of: isOn) { _, _ in action?() }
        }
        .padding(.vertical, theme.spacing.control / 4)
    }
}

// MARK: - Previews

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
