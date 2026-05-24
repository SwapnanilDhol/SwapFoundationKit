/*****************************************************************************
 * SFKItemPickerViewModel.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import Foundation
import Combine

/// ViewModel for `SFKItemPickerView`. Manages selection state internally,
/// publishes `selectedItems`, and notifies `delegate` on every change.
///
/// ## Usage
/// ```swift
/// @StateObject private var pickerVM = SFKItemPickerViewModel(
///     items: Currency.allCases,
///     selectionType: .multi,
///     initialSelection: [Currency.USD]
/// )
///
/// .sheet {
///     SFKItemPickerView(
///         pageTitle: "Select Currencies",
///         viewModel: pickerVM,
///         onSelect: { _ in hapticsHelper.mediumImpact() },
///         onDismiss: { }
///     )
/// }
///
/// // Read selection anywhere:
/// let selected = pickerVM.selectedItems
/// ```
@MainActor
public final class SFKItemPickerViewModel: ObservableObject {
    @Published public private(set) var sections: [SFKItemPickerSection]
    public let selectionType: SFKItemPickerSelectionMode

    @Published public private(set) var selectedItems: [any SFKPickableItem] = []
    @Published public var searchText: String = ""

    public weak var delegate: SFKItemPickerDelegate?

    public init(
        items: [any SFKPickableItem],
        selectionType: SFKItemPickerSelectionMode = .single,
        initialSelection: [any SFKPickableItem] = []
    ) {
        self.sections = [SFKItemPickerSection(items: items)]
        self.selectionType = selectionType
        self.selectedItems = initialSelection.filter { item in
            items.contains { $0.pickableItemId == item.pickableItemId }
        }
    }

    public init(
        sections: [SFKItemPickerSection],
        selectionType: SFKItemPickerSelectionMode = .single,
        initialSelection: [any SFKPickableItem] = []
    ) {
        let items = sections.flatMap(\.items)
        self.sections = sections
        self.selectionType = selectionType
        self.selectedItems = initialSelection.filter { item in
            items.contains { $0.pickableItemId == item.pickableItemId }
        }
    }

    public func handleSelection(of item: any SFKPickableItem) {
        let id = item.pickableItemId
        if selectedItems.map(\.pickableItemId).contains(id) {
            selectedItems.removeAll { $0.pickableItemId == id }
        } else {
            if selectionType == .single {
                selectedItems = [item]
            } else {
                selectedItems.append(item)
            }
        }
        delegate?.itemPicker(self, didSelectItem: item)
        delegate?.itemPicker(self, didUpdateSelection: selectedItems)
    }

    public func isSelected(_ item: any SFKPickableItem) -> Bool {
        selectedItems.map(\.pickableItemId).contains(item.pickableItemId)
    }

    public var items: [any SFKPickableItem] {
        sections.flatMap(\.items)
    }

    public var filteredItems: [any SFKPickableItem] {
        filteredSections.flatMap(\.items)
    }

    public var filteredSections: [SFKItemPickerSection] {
        let trimmedSearchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedSearchText.isEmpty else { return sections }

        return sections.compactMap { section in
            let filteredItems = section.items.filter { item in
                item.pickableItemTitle.localizedCaseInsensitiveContains(trimmedSearchText)
                    || (item.pickableItemSubtitle?.localizedCaseInsensitiveContains(trimmedSearchText) ?? false)
            }
            guard !filteredItems.isEmpty else { return nil }
            return SFKItemPickerSection(
                id: section.id,
                title: section.title,
                footer: section.footer,
                items: filteredItems
            )
        }
    }

    public func updateItems(_ items: [any SFKPickableItem]) {
        updateSections([SFKItemPickerSection(items: items)])
    }

    public func updateSections(_ sections: [SFKItemPickerSection]) {
        self.sections = sections
        let items = sections.flatMap(\.items)
        selectedItems = selectedItems.filter { selectedItem in
            items.contains { $0.pickableItemId == selectedItem.pickableItemId }
        }
    }
}
