//
//  SFKSettingsColorPickerRow.swift
//  SwapFoundationKit
//
//  Created by Swapnanil Dhol on 4/4/26.
//

import SwiftUI

/// A settings row that presents a ColorPicker in a sheet.
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

    private let title: String
    private let subtitle: String
    private let icon: String
    private let tint: Color
    @Binding private var selection: Color

    @State private var isPresented = false

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
        tint: Color,
        selection: Binding<Color>
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.tint = tint
        self._selection = selection
    }

    public var body: some View {
        Button {
            isPresented = true
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(selection.opacity(0.14))

                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(selection)
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

                Circle()
                    .fill(selection)
                    .frame(width: 24, height: 24)
                    .overlay(
                        Circle()
                            .strokeBorder(Color.primary.opacity(0.2), lineWidth: 1)
                    )

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $isPresented) {
            NavigationStack {
                VStack(spacing: 20) {
                    ColorPicker(
                        "Select Color",
                        selection: $selection,
                        supportsOpacity: true
                    )
                    .labelsHidden()
                    .padding()

                    Spacer()
                }
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            isPresented = false
                        }
                    }
                }
            }
            .presentationDetents([.medium])
        }
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

    private let title: String
    private let icon: String
    private let tint: Color
    @Binding private var selection: Color

    /// Creates an inline color picker settings row.
    public init(
        title: String,
        icon: String,
        tint: Color,
        selection: Binding<Color>
    ) {
        self.title = title
        self.icon = icon
        self.tint = tint
        self._selection = selection
    }

    public var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(selection.opacity(0.14))

                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(selection)
            }
            .frame(width: 36, height: 36)

            ColorPicker(title, selection: $selection, supportsOpacity: true)
                .labelsHidden()

            Spacer()
        }
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
