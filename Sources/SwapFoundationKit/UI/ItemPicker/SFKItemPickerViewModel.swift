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

/// Defines selection mode for the item picker.
public enum SFKItemPickerSelectionMode: Sendable {
    case single
    case multi
}

/// A protocol for items that can be displayed and selected in the item picker.
///
/// Conforming types can be displayed in `SFKItemPickerView`. The picker resolves
/// display text via closure callbacks on the view, so conforming types only need
/// to provide an ID for selection tracking.
public protocol SFKPickableItem: Hashable {
    var pickerID: String { get }
}

extension SFKPickableItem where Self: RawRepresentable, RawValue == String {
    public var pickerID: String { rawValue }
}

/// ViewModel for a generic item picker.
///
/// Use with `SFKItemPickerView` to present a selectable list of items.
public final class SFKItemPickerViewModel: ObservableObject {
    public let title: String
    public let items: [any SFKPickableItem]
    public let selectionMode: SFKItemPickerSelectionMode

    @Published public var selectedItemIDs: Set<String> = []

    public weak var delegate: SFKItemPickerDelegate?

    /// Creates an item picker view model.
    /// - Parameters:
    ///   - title: The navigation title for the picker.
    ///   - items: Array of conforming items to display.
    ///   - selectionMode: `.single` or `.multi`. Default is `.single`.
    public init(
        title: String,
        items: [any SFKPickableItem],
        selectionMode: SFKItemPickerSelectionMode = .single
    ) {
        self.title = title
        self.items = items
        self.selectionMode = selectionMode
    }

    /// Selects a single item. For multi-select, use `toggleSelection`.
    public func selectItem(_ item: any SFKPickableItem) {
        delegate?.itemPicker(self, didSelectItem: item)
    }

    /// Toggles selection for an item in multi-select mode.
    public func toggleSelection(for id: String) {
        if selectedItemIDs.contains(id) {
            selectedItemIDs.remove(id)
        } else {
            selectedItemIDs.insert(id)
        }
    }

    /// Returns whether the item with the given ID is currently selected.
    public func isSelected(_ id: String) -> Bool {
        selectedItemIDs.contains(id)
    }

    /// Resolves all currently selected items and notifies the delegate.
    public func confirmSelection() {
        let selected = items.filter { selectedItemIDs.contains($0.pickerID) }
        delegate?.itemPicker(self, didConfirmSelection: selected)
    }
}