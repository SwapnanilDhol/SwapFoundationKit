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

    private let title: String
    private let subtitle: String
    private let icon: String
    private let tint: Color
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
        tint: Color,
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

                Text(displayName(selection))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .confirmationDialog(title, isPresented: $isPresented, titleVisibility: .visible) {
            ForEach(options) { option in
                Button(option.label) {
                    selectOption(option)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(subtitle)
        }
    }

    private func selectOption(_ option: SFKSettingsPickerOption) {
        // The option ID should match the selection type
        if let typedOption = option as? Selection as? SFKSettingsPickerOption,
           let stringId = typedOption.id as? Selection {
            selection = stringId
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

    private let title: String
    private let subtitle: String
    private let icon: String
    private let tint: Color
    private let options: [SFKSettingsPickerOption]
    @Binding private var selection: Selection
    private let displayName: (Selection) -> String

    @State private var isPresented = false

    /// Creates a picker settings row with sheet presentation.
    public init(
        title: String,
        subtitle: String,
        icon: String,
        tint: Color,
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

                Text(displayName(selection))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
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
                                    .foregroundStyle(.primary)
                                Spacer()
                                if isSelected(option) {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.tint)
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
        guard let stringId = option.id as? String,
              let stringSelection = selection as? String else {
            return false
        }
        return stringId == stringSelection
    }

    private func selectOption(_ option: SFKSettingsPickerOption) {
        guard let stringId = option.id as? String,
              let typedSelection = stringId as? Selection else {
            return
        }
        selection = typedSelection
    }
}
