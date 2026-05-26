//
//  SFKSettingsColorPickerRow.swift
//  SwapFoundationKit
//
//  Created by Swapnanil Dhol on 4/4/26.
//

import SwiftUI

/// A settings row that invokes the system ColorPicker directly.
///
/// ## Usage
/// ```swift
/// @State private var selectedColor = Color.blue
///
/// SFKSettingsColorPickerRow(
///     title: "Theme Color",
///     subtitle: "Choose your preferred color",
///     icon: "paintpalette",
///     selection: $selectedColor
/// )
/// ```
public struct SFKSettingsColorPickerRow: View {
    @Environment(\.sfkSettingsTheme) private var theme

    private let title: String
    private let subtitle: String
    private let icon: String
    private let tint: Color?
    @Binding private var selection: Color

    /// Creates a color picker settings row.
    /// - Parameters:
    ///   - title: Primary text label.
    ///   - subtitle: Secondary text label.
    ///   - icon: SF Symbol name for the icon.
    ///   - tint: Tint color for the icon background and icon (overridden by selection for swatch).
    ///   - selection: Binding to the selected color.
    public init(
        title: String,
        subtitle: String,
        icon: String,
        tint: Color? = nil,
        selection: Binding<Color>
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.tint = tint
        self._selection = selection
    }

    public var body: some View {
        let resolvedTint = theme.resolvedTint(tint)
        _SFKSettingsRowContent(
            title: title,
            subtitle: subtitle,
            icon: icon,
            tint: resolvedTint,
            iconBackgroundColor: selection.opacity(0.14)
        ) {
            ColorPicker(title, selection: $selection, supportsOpacity: true)
                .labelsHidden()
        }
        .padding(.vertical, theme.metrics.rowVerticalPadding)
        .contentShape(Rectangle())
    }
}

/// A settings row with an inline ColorPicker for direct selection.
///
/// ## Usage
/// ```swift
/// @State private var accentColor = Color.blue
///
/// SFKSettingsInlineColorPicker(
///     title: "Accent Color",
///     icon: "paintbrush",
///     tint: .purple,
///     selection: $accentColor
/// )
/// ```
public struct SFKSettingsInlineColorPicker: View {
    @Environment(\.sfkSettingsTheme) private var theme

    private let title: String
    private let icon: String
    private let tint: Color?
    @Binding private var selection: Color

    /// Creates an inline color picker settings row.
    public init(
        title: String,
        icon: String,
        tint: Color? = nil,
        selection: Binding<Color>
    ) {
        self.title = title
        self.icon = icon
        self.tint = tint
        self._selection = selection
    }

    public var body: some View {
        let resolvedTint = theme.resolvedTint(tint)
        _SFKSettingsRowContent(
            title: title,
            subtitle: "",
            icon: icon,
            tint: resolvedTint,
            iconBackgroundColor: selection.opacity(0.14)
        ) {
            ColorPicker(title, selection: $selection, supportsOpacity: true)
                .labelsHidden()
                .tint(resolvedTint)
                .buttonStyle(SFKSettingsFormRowButtonStyle())
        }
        .padding(.vertical, theme.metrics.rowVerticalPadding)
    }
}


// MARK: - Previews

#Preview("SFKSettingsColorPickerRow") {
    @Previewable @State var color = Color.blue

    List {
        SFKSettingsColorPickerRow(
            title: "Theme Color",
            subtitle: "Choose your preferred color",
            icon: "paintpalette.fill",
            tint: .purple,
            selection: $color
        )
    }
}

#Preview("SFKSettingsInlineColorPicker") {
    @Previewable @State var color = Color.purple

    List {
        SFKSettingsInlineColorPicker(
            title: "Accent Color",
            icon: "paintbrush.fill",
            tint: color,
            selection: $color
        )
    }
}
