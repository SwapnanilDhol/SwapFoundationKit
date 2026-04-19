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
    public let items: [any SFKPickableItem]
    public let selectionType: SFKItemPickerSelectionMode

    @Published public private(set) var selectedItems: [any SFKPickableItem] = []

    public weak var delegate: SFKItemPickerDelegate?

    public init(
        items: [any SFKPickableItem],
        selectionType: SFKItemPickerSelectionMode = .single,
        initialSelection: [any SFKPickableItem] = []
    ) {
        self.items = items
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
}
