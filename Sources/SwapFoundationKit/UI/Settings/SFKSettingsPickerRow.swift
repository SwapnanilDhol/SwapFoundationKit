//
//  SFKSettingsPickerRow.swift
//  SwapFoundationKit
//
//  Created by Swapnanil Dhol on 4/4/26.
//

import SwiftUI

/// An option for a picker settings row.
public struct SFKSettingsPickerOption: Identifiable, Hashable {
    public let id: String
    public let label: String

    public init(id: String = UUID().uuidString, label: String) {
        self.id = id
        self.label = label
    }
}

/// A settings row that presents a picker (selection from options) in a sheet.
///
/// ## Usage
/// ```swift
/// @State private var selectedUnit = "metric"
///
/// SFKSettingsPickerRow(
///     title: "Units",
///     subtitle: "Measurement system",
///     icon: "ruler",
///     tint: .green,
///     options: [
///         SFKSettingsPickerOption(id: "metric", label: "Metric"),
///         SFKSettingsPickerOption(id: "imperial", label: "Imperial")
///     ],
///     selection: $selectedUnit,
///     displayName: { id in
///         options.first { $0.id == id }?.label ?? id
///     }
/// )
/// ```
public struct SFKSettingsPickerRow<Selection: Hashable>: View {
    @Environment(\.sfkSettingsTheme) private var theme

    private let title: String
    private let subtitle: String
    private let icon: String
    private let tint: Color?
    private let options: [SFKSettingsPickerOption]
    @Binding private var selection: Selection
    private let displayName: (Selection) -> String
    private let pickerStyle: SFKPickerStyle

    @State private var isPresented = false

    /// Creates a picker settings row.
    /// - Parameters:
    ///   - title: Primary text label.
    ///   - subtitle: Secondary text label.
    ///   - icon: SF Symbol name for the icon.
    ///   - tint: Tint color for the icon background and icon.
    ///   - options: Available options to select from.
    ///   - selection: Binding to the selected option.
    ///   - displayName: Closure to convert an option ID to display string.
    ///   - pickerStyle: How to present the picker (sheet or actionSheet).
    public init(
        title: String,
        subtitle: String,
        icon: String,
        tint: Color? = nil,
        options: [SFKSettingsPickerOption],
        selection: Binding<Selection>,
        displayName: @escaping (Selection) -> String,
        pickerStyle: SFKPickerStyle = .sheet
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.tint = tint
        self.options = options
        self._selection = selection
        self.displayName = displayName
        self.pickerStyle = pickerStyle
    }

    public var body: some View {
        Button {
            isPresented = true
        } label: {
            HStack(spacing: theme.metrics.rowSpacing) {
                ZStack {
                    RoundedRectangle(cornerRadius: theme.metrics.iconCornerRadius)
                        .fill(theme.resolvedTint(tint).opacity(theme.colors.iconBackgroundOpacity))

                    Image(systemName: icon)
                        .font(theme.typography.iconFont)
                        .foregroundStyle(theme.resolvedTint(tint))
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

                Spacer()

                Text(displayName(selection))
                    .font(theme.typography.valueFont)
                    .foregroundStyle(theme.colors.valueColor)

                Image(systemName: "chevron.right")
                    .font(theme.typography.accessoryFont)
                    .foregroundStyle(theme.colors.accessoryColor)
            }
            .padding(.vertical, theme.metrics.rowVerticalPadding)
            .contentShape(Rectangle())
        }
        .buttonStyle(SFKSettingsFormRowButtonStyle())
        .modifier(
            SFKPickerPresentationModifier(
                isPresented: $isPresented,
                pickerStyle: pickerStyle,
                title: title,
                subtitle: subtitle,
                options: options,
                onSelect: selectOption
            )
        )
    }

    private func selectOption(_ option: SFKSettingsPickerOption) {
        guard let typedSelection = option.id as? Selection else {
            return
        }
        selection = typedSelection
    }
}

private struct SFKPickerPresentationModifier: ViewModifier {
    @Environment(\.sfkSettingsTheme) private var theme
    @Binding var isPresented: Bool
    let pickerStyle: SFKPickerStyle
    let title: String
    let subtitle: String
    let options: [SFKSettingsPickerOption]
    let onSelect: (SFKSettingsPickerOption) -> Void

    func body(content: Content) -> some View {
        switch pickerStyle {
        case .actionSheet:
            content.confirmationDialog(title, isPresented: $isPresented, titleVisibility: .visible) {
                ForEach(options) { option in
                    Button(option.label) {
                        onSelect(option)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text(subtitle)
            }
        case .sheet:
            content.sheet(isPresented: $isPresented) {
                NavigationStack {
                    List {
                        ForEach(options) { option in
                            Button {
                                onSelect(option)
                                isPresented = false
                            } label: {
                                HStack {
                                    Text(option.label)
                                        .foregroundStyle(theme.colors.titleColor)
                                    Spacer()
                                }
                            }
                        }
                    }
                    .navigationTitle(title)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                isPresented = false
                            }
                        }
                    }
                }
                .presentationDetents([.medium, .large])
            }
        }
    }
}

/// How to present the picker options.
public enum SFKPickerStyle {
    /// Present options in a confirmation dialog.
    case actionSheet
    /// Present options in a full sheet with a list.
    case sheet
}

/// A settings row that presents a picker in a sheet with a List.
public struct SFKSettingsPickerSheetRow<Selection: Hashable>: View {
    @Environment(\.sfkSettingsTheme) private var theme

    private let title: String
    private let subtitle: String
    private let icon: String
    private let tint: Color?
    private let options: [SFKSettingsPickerOption]
    @Binding private var selection: Selection
    private let displayName: (Selection) -> String

    @State private var isPresented = false

    /// Creates a picker settings row with sheet presentation.
    public init(
        title: String,
        subtitle: String,
        icon: String,
        tint: Color? = nil,
        options: [SFKSettingsPickerOption],
        selection: Binding<Selection>,
        displayName: @escaping (Selection) -> String
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.tint = tint
        self.options = options
        self._selection = selection
        self.displayName = displayName
    }

    public var body: some View {
        Button {
            isPresented = true
        } label: {
            HStack(spacing: theme.metrics.rowSpacing) {
                ZStack {
                    RoundedRectangle(cornerRadius: theme.metrics.iconCornerRadius)
                        .fill(theme.resolvedTint(tint).opacity(theme.colors.iconBackgroundOpacity))

                    Image(systemName: icon)
                        .font(theme.typography.iconFont)
                        .foregroundStyle(theme.resolvedTint(tint))
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

                Spacer()

                Text(displayName(selection))
                    .font(theme.typography.valueFont)
                    .foregroundStyle(theme.colors.valueColor)

                Image(systemName: "chevron.right")
                    .font(theme.typography.accessoryFont)
                    .foregroundStyle(theme.colors.accessoryColor)
            }
            .padding(.vertical, theme.metrics.rowVerticalPadding)
            .contentShape(Rectangle())
        }
        .buttonStyle(SFKSettingsFormRowButtonStyle())
        .sheet(isPresented: $isPresented) {
            NavigationStack {
                List {
                    ForEach(options) { option in
                        Button {
                            selectOption(option)
                            isPresented = false
                        } label: {
                            HStack {
                                Text(option.label)
                                    .foregroundStyle(theme.colors.titleColor)
                                Spacer()
                                if isSelected(option) {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(theme.colors.accent)
                                }
                            }
                        }
                    }
                }
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            isPresented = false
                        }
                    }
                }
            }
            .presentationDetents([.medium, .large])
        }
    }

    private func isSelected(_ option: SFKSettingsPickerOption) -> Bool {
        guard let stringSelection = selection as? String else {
            return false
        }
        return option.id == stringSelection
    }

    private func selectOption(_ option: SFKSettingsPickerOption) {
        guard let typedSelection = option.id as? Selection else {
            return
        }
        selection = typedSelection
    }
}

// MARK: - Previews

private let previewPickerOptions = [
    SFKSettingsPickerOption(id: "metric", label: "Metric"),
    SFKSettingsPickerOption(id: "imperial", label: "Imperial"),
    SFKSettingsPickerOption(id: "customary", label: "US Customary")
]

#Preview("SFKSettingsPickerRow") {
    @Previewable @State var selection = "metric"

    List {
        SFKSettingsPickerRow(
            title: "Units",
            subtitle: "Choose the measurement system used across the app.",
            icon: "ruler.fill",
            tint: .green,
            options: previewPickerOptions,
            selection: $selection,
            displayName: { id in
                previewPickerOptions.first(where: { $0.id == id })?.label ?? id
            },
            pickerStyle: .actionSheet
        )
    }
}

#Preview("SFKSettingsPickerSheetRow") {
    @Previewable @State var selection = "imperial"

    List {
        SFKSettingsPickerSheetRow(
            title: "Default Units",
            subtitle: "Present a full sheet when you have a longer options list.",
            icon: "list.bullet.rectangle.fill",
            tint: .blue,
            options: previewPickerOptions,
            selection: $selection,
            displayName: { id in
                previewPickerOptions.first(where: { $0.id == id })?.label ?? id
            }
        )
    }
}
