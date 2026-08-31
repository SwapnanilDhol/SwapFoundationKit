/*****************************************************************************
 * ItemPickerExamplesView.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI
import SwapFoundationKit

struct ItemPickerExamplesView: View {
    @State private var selectedItems: Set<CatalogPickableItem> = [.swift]
    @State private var presentedPicker: PresentedPicker?

    var body: some View {
        List {
            Section {
                Button("Show Multi-Select Picker") {
                    presentedPicker = .multiSelect
                }
            } footer: {
                    Text("The typed picker supports search, badges, and multi-selection without a public view model.")
            }

            Section("Selected") {
                if selectedItems.isEmpty {
                    Text("Nothing selected")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(selectedItems.sorted { $0.rawValue < $1.rawValue }) { item in
                        Label(item.pickableItemTitle, systemImage: "checkmark.circle.fill")
                    }
                }
            }

            Section("Included APIs") {
                ForEach(CatalogDestination.itemPicker.apiNames, id: \.self) { apiName in
                    Text(apiName)
                        .font(.body.monospaced())
                }
            }
        }
        .navigationTitle("Item Picker")
        .sheet(item: $presentedPicker) { _ in
            SFKItemPickerView(
                "Frameworks",
                items: CatalogPickableItem.allCases,
                selections: $selectedItems,
                onSelect: { _ in }
            )
        }
    }
}

private extension ItemPickerExamplesView {
    enum PresentedPicker: String, Identifiable {
        case multiSelect

        var id: Self { self }
    }
}

private enum CatalogPickableItem: String, CaseIterable, Identifiable, SFKPickableItem {
    case swift = "Swift"
    case swiftUI = "SwiftUI"
    case uiKit = "UIKit"
    case combine = "Combine"

    static var sections: [SFKItemPickerSection] {
        [
            SFKItemPickerSection(title: "Modern", items: [Self.swift, Self.swiftUI]),
            SFKItemPickerSection(title: "Foundation", items: [Self.uiKit, Self.combine])
        ]
    }

    var id: Self { self }
    var pickableItemId: String { rawValue }
    var pickableItemTitle: String { rawValue }
    var pickableItemSubtitle: String? {
        switch self {
        case .swift: "Language"
        case .swiftUI: "Declarative UI"
        case .uiKit: "Imperative UI"
        case .combine: "Reactive streams"
        }
    }
    var pickableItemIconKind: SFKPickableItemIconKind {
        .systemIcon(symbolName: iconName)
    }
    var pickableItemIconTintColor: UIColor? { .systemBlue }
    var pickableItemBadgeTitle: String? {
        switch self {
        case .swiftUI: "Recommended"
        default: nil
        }
    }

    private var iconName: String {
        switch self {
        case .swift: "swift"
        case .swiftUI: "rectangle.3.group"
        case .uiKit: "iphone"
        case .combine: "waveform.path.ecg"
        }
    }
}

#Preview {
    NavigationStack {
        ItemPickerExamplesView()
    }
}
