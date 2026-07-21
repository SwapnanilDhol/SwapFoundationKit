/****************************************************************************
 * ChipExamplesView.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwapFoundationKit
import SwiftUI

struct ChipExamplesView: View {
    @State private var isInspectorPresented = false
    @State private var chipKind = ChipKind.action
    @State private var title = "Category"
    @State private var showsLeadingIcon = true
    @State private var leadingIconName = "tag"
    @State private var tintColor = Color.blue
    @State private var controlSize = ChipControlSize.small

    @State private var actionStyle = ActionChipStyle.secondary
    @State private var hapticStyle = ActionChipHaptic.light
    @State private var actionTapCount = 0

    @State private var isSelected = true
    @State private var selectableStyle = SelectableChipStyle.standard
    @State private var usesCustomIconTint = false
    @State private var iconTint = Color.purple
    @State private var showsTrailingAccessory = false
    @State private var trailingAccessoryIcon = "chevron.down"

    var body: some View {
        CatalogControlPlayground(
            title: "Chips",
            isInspectorPresented: $isInspectorPresented
        ) {
            CatalogExampleGroup(
                title: "Live Preview",
                apiNames: [chipKind.apiName]
            ) {
                VStack(spacing: 18) {
                    preview
                        .frame(maxWidth: .infinity, minHeight: 72)

                    Divider()

                    switch chipKind {
                    case .action:
                        LabeledContent("Taps", value: actionTapCount.formatted())
                    case .selectable:
                        LabeledContent("State", value: isSelected ? "Selected" : "Not selected")
                    }
                }
                .padding(16)
                .background(.background, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
        } configuration: {
            Form {
                Section("Component") {
                    Picker("Chip type", selection: $chipKind) {
                        ForEach(ChipKind.allCases) { kind in
                            Text(kind.title).tag(kind)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                contentConfiguration
                appearanceConfiguration
                interactionConfiguration
            }
        }
    }

    @ViewBuilder
    private var preview: some View {
        switch chipKind {
        case .action:
            SFKChip(
                title,
                leadingIconName: resolvedLeadingIcon,
                tintColor: tintColor,
                controlSize: controlSize.value,
                style: actionStyle.value,
                hapticStyle: hapticStyle.value
            ) {
                actionTapCount += 1
            }

        case .selectable:
            SFKSelectableChip(
                title,
                icon: resolvedLeadingIcon,
                isSelected: isSelected,
                tintColor: tintColor,
                iconTint: usesCustomIconTint ? iconTint : nil,
                visualStyle: selectableStyle.value,
                controlSize: controlSize.value,
                trailingAccessoryIcon: resolvedTrailingAccessory
            ) {
                isSelected.toggle()
            }
        }
    }

    @ViewBuilder
    private var contentConfiguration: some View {
        Section("Content") {
            TextField("Title", text: $title)

            Toggle("Leading icon", isOn: $showsLeadingIcon)

            if showsLeadingIcon {
                TextField("SF Symbol or text", text: $leadingIconName)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }

            if chipKind == .selectable {
                Toggle("Trailing accessory", isOn: $showsTrailingAccessory)

                if showsTrailingAccessory {
                    TextField("Accessory symbol or text", text: $trailingAccessoryIcon)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
            }
        }
    }

    @ViewBuilder
    private var appearanceConfiguration: some View {
        Section("Appearance") {
            Picker("Control size", selection: $controlSize) {
                ForEach(ChipControlSize.allCases) { size in
                    Text(size.title).tag(size)
                }
            }

            ColorPicker("Tint", selection: $tintColor, supportsOpacity: true)

            switch chipKind {
            case .action:
                Picker("Style", selection: $actionStyle) {
                    ForEach(ActionChipStyle.allCases) { style in
                        Text(style.title).tag(style)
                    }
                }
                .pickerStyle(.segmented)

            case .selectable:
                Picker("Visual style", selection: $selectableStyle) {
                    ForEach(SelectableChipStyle.allCases) { style in
                        Text(style.title).tag(style)
                    }
                }
                .pickerStyle(.segmented)

                Toggle("Custom icon tint", isOn: $usesCustomIconTint)

                if usesCustomIconTint {
                    ColorPicker("Icon tint", selection: $iconTint, supportsOpacity: true)
                }
            }
        }
    }

    @ViewBuilder
    private var interactionConfiguration: some View {
        switch chipKind {
        case .action:
            Section("Interaction") {
                Picker("Haptic", selection: $hapticStyle) {
                    ForEach(ActionChipHaptic.allCases) { haptic in
                        Text(haptic.title).tag(haptic)
                    }
                }
            }

        case .selectable:
            Section("Interaction") {
                Toggle("Selected", isOn: $isSelected)
                LabeledContent("Tap behavior", value: "Toggle selection")
            }
        }
    }

    private var resolvedLeadingIcon: String? {
        guard showsLeadingIcon else { return nil }
        let value = leadingIconName.trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? nil : value
    }

    private var resolvedTrailingAccessory: String? {
        guard chipKind == .selectable, showsTrailingAccessory else { return nil }
        let value = trailingAccessoryIcon.trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? nil : value
    }
}

private enum ChipKind: String, CaseIterable, Identifiable {
    case action
    case selectable

    var id: Self { self }
    var title: String { rawValue.capitalized }

    var apiName: String {
        switch self {
        case .action: "SFKChip"
        case .selectable: "SFKSelectableChip"
        }
    }
}

private enum ChipControlSize: String, CaseIterable, Identifiable {
    case mini
    case small
    case regular
    case large
    case extraLarge

    var id: Self { self }

    var title: String {
        switch self {
        case .mini: "Mini"
        case .small: "Small"
        case .regular: "Regular"
        case .large: "Large"
        case .extraLarge: "Extra Large"
        }
    }

    var value: ControlSize {
        switch self {
        case .mini: .mini
        case .small: .small
        case .regular: .regular
        case .large: .large
        case .extraLarge: .extraLarge
        }
    }
}

private enum ActionChipStyle: String, CaseIterable, Identifiable {
    case primary
    case secondary

    var id: Self { self }
    var title: String { rawValue.capitalized }

    var value: SFKChipStyle {
        switch self {
        case .primary: .primary
        case .secondary: .secondary
        }
    }
}

private enum ActionChipHaptic: String, CaseIterable, Identifiable {
    case none
    case light
    case medium
    case heavy

    var id: Self { self }
    var title: String { rawValue.capitalized }

    var value: SFKChipHapticStyle? {
        switch self {
        case .none: nil
        case .light: .light
        case .medium: .medium
        case .heavy: .heavy
        }
    }
}

private enum SelectableChipStyle: String, CaseIterable, Identifiable {
    case standard
    case subtle

    var id: Self { self }
    var title: String { rawValue.capitalized }

    var value: SFKSelectableChip.VisualStyle {
        switch self {
        case .standard: .standard
        case .subtle: .subtle
        }
    }
}

#Preview {
    NavigationStack {
        ChipExamplesView()
    }
}
