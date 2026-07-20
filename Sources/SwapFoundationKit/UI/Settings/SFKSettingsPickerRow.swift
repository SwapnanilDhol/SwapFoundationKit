/****************************************************************************
 * SFKSettingsPickerRow.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI

/// A strongly typed option displayed by ``SFKSettingsPickerRow``.
public struct SFKSettingsPickerOption<Value: Hashable>: Identifiable, Hashable {
    public let value: Value
    public let label: String

    public var id: Value { value }

    public init(value: Value, label: String) {
        self.value = value
        self.label = label
    }

    /// Compatibility spelling for callers that model the option value as its ID.
    public init(id: Value, label: String) {
        self.init(value: id, label: label)
    }
}

/// How a settings picker presents its options.
public enum SFKPickerStyle {
    case actionSheet
    case sheet
}

/// A settings row that presents a strongly typed single-selection picker.
public struct SFKSettingsPickerRow<Selection: Hashable>: View {
    @Environment(\.sfkSettingsTheme) private var theme

    private let title: String
    private let subtitle: String
    private let icon: String
    private let tint: Color?
    private let options: [SFKSettingsPickerOption<Selection>]
    @Binding private var selection: Selection
    private let displayName: (Selection) -> String
    private let pickerStyle: SFKPickerStyle

    @State private var isPresented = false

    public init(
        title: String,
        subtitle: String,
        icon: String,
        tint: Color? = nil,
        options: [SFKSettingsPickerOption<Selection>],
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
        Button(action: presentPicker) {
            _SFKSettingsRowContent(
                title: title,
                subtitle: subtitle,
                icon: icon,
                tint: theme.resolvedTint(tint)
            ) {
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
            SFKSettingsPickerPresentation(
                isPresented: $isPresented,
                pickerStyle: pickerStyle,
                title: title,
                subtitle: subtitle,
                options: options,
                selection: $selection
            )
        )
    }

    private func presentPicker() {
        isPresented = true
    }
}

/// Compatibility alias. Sheet presentation is now a style of ``SFKSettingsPickerRow``.
@available(*, deprecated, renamed: "SFKSettingsPickerRow")
public typealias SFKSettingsPickerSheetRow<Selection: Hashable> = SFKSettingsPickerRow<Selection>

private struct SFKSettingsPickerPresentation<Selection: Hashable>: ViewModifier {
    @Binding var isPresented: Bool
    let pickerStyle: SFKPickerStyle
    let title: String
    let subtitle: String
    let options: [SFKSettingsPickerOption<Selection>]
    @Binding var selection: Selection

    func body(content: Content) -> some View {
        switch pickerStyle {
        case .actionSheet:
            content.confirmationDialog(title, isPresented: $isPresented, titleVisibility: .visible) {
                ForEach(options) { option in
                    Button(option.label) {
                        selection = option.value
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text(subtitle)
            }
        case .sheet:
            content.sheet(isPresented: $isPresented) {
                SFKSettingsPickerSheet(
                    title: title,
                    options: options,
                    selection: $selection,
                    onDismiss: { isPresented = false }
                )
            }
        }
    }
}

private struct SFKSettingsPickerSheet<Selection: Hashable>: View {
    private let title: String
    private let valuesByPickerID: [String: Selection]
    @Binding private var selection: Selection
    private let onDismiss: () -> Void

    @StateObject private var viewModel: SFKItemPickerViewModel

    init(
        title: String,
        options: [SFKSettingsPickerOption<Selection>],
        selection: Binding<Selection>,
        onDismiss: @escaping () -> Void
    ) {
        let items = options.enumerated().map(SFKSettingsPickerItem.init)
        let selectedItems = items.filter { $0.value == selection.wrappedValue }

        self.title = title
        self.valuesByPickerID = Dictionary(uniqueKeysWithValues: items.map { ($0.pickableItemId, $0.value) })
        self._selection = selection
        self.onDismiss = onDismiss
        self._viewModel = StateObject(
            wrappedValue: SFKItemPickerViewModel(
                items: items,
                selectionType: .single,
                initialSelection: selectedItems
            )
        )
    }

    var body: some View {
        SFKItemPickerView(
            pageTitle: title,
            viewModel: viewModel,
            onSelect: select,
            onDismiss: onDismiss
        )
        .presentationDetents([.medium, .large])
    }

    private func select(_ item: any SFKPickableItem) {
        guard let value = valuesByPickerID[item.pickableItemId] else { return }
        selection = value
    }
}

private struct SFKSettingsPickerItem<Value: Hashable>: SFKPickableItem {
    let value: Value
    let label: String
    let index: Int

    init(offset: Int, element: SFKSettingsPickerOption<Value>) {
        self.value = element.value
        self.label = element.label
        self.index = offset
    }

    var id: String { pickableItemId }
    var pickableItemId: String { String(index) }
    var pickableItemIconKind: SFKPickableItemIconKind { .none }
    var pickableItemTitle: String { label }
    var pickableItemSubtitle: String? { nil }
}

#Preview("Typed Settings Picker") {
    @Previewable @State var selection = 2

    List {
        SFKSettingsPickerRow(
            title: "Priority",
            subtitle: "Choose a numeric priority.",
            icon: "flag.fill",
            tint: .orange,
            options: [
                SFKSettingsPickerOption(value: 1, label: "Low"),
                SFKSettingsPickerOption(value: 2, label: "Normal"),
                SFKSettingsPickerOption(value: 3, label: "High")
            ],
            selection: $selection,
            displayName: { String($0) }
        )
    }
}
