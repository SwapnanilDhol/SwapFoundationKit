/*****************************************************************************
 * SFKItemPickerView.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI

/// A generic picker view for selecting items from a list.
///
/// Supports single-select and multi-select modes.
///
/// ## Usage
/// ```swift
/// SFKItemPickerView(
///     pageTitle: "Select Currency",
///     items: Currency.allCases,
///     selectedItems: [selectedCurrency],
///     selectionType: .single,
///     onSelect: { currency in
///         // handle selection
///     },
///     onDismiss: {
///         // dismiss picker
///     }
/// )
/// ```
public struct SFKItemPickerView: View {

    let pageTitle: String
    let items: [any SFKPickableItem]
    let selectedItems: [any SFKPickableItem]
    let selectionType: SFKItemPickerSelectionMode
    let onSelect: ((any SFKPickableItem) -> Void)?
    let onDismiss: (() -> Void)?

    public init(
        pageTitle: String,
        items: [any SFKPickableItem],
        selectedItems: [any SFKPickableItem] = [],
        selectionType: SFKItemPickerSelectionMode = .single,
        onSelect: ((any SFKPickableItem) -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        self.pageTitle = pageTitle
        self.items = items
        self.selectedItems = selectedItems
        self.selectionType = selectionType
        self.onSelect = onSelect
        self.onDismiss = onDismiss
    }

    public var body: some View {
        NavigationStack {
            List(items, id: \.pickableItemId) { item in
                SFKItemPickerRow(
                    item: item,
                    selectionType: selectionType,
                    isSelected: selectedItems.contains(where: { $0.pickableItemId == item.pickableItemId }),
                    didSelect: { selectedItem in
                        onSelect?(selectedItem)
                        if selectionType == .single {
                            onDismiss?()
                        }
                    }
                )
            }
            .navigationTitle(pageTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    SFKButton(
                        kind: .close,
                        title: "Close".localized,
                        systemImage: "xmark",
                        action: {
                            onDismiss?()
                        }
                    )
                }
            }
        }
    }
}

// MARK: - Previews

#Preview("Single Select - Currency") {
    SFKItemPickerView(
        pageTitle: "Select Currency",
        items: Array(Currency.allCases.prefix(10)),
        selectedItems: [Currency.USD],
        selectionType: .single,
        onSelect: { item in
            print("Selected: \(item.id)")
        },
        onDismiss: {
            print("Dismissed")
        }
    )
}

#Preview("Multi Select - Currency") {
    SFKItemPickerView(
        pageTitle: "Select Currencies",
        items: Array(Currency.allCases.prefix(10)),
        selectedItems: [Currency.USD, Currency.EUR],
        selectionType: .multi,
        onSelect: { item in
            print("Toggled: \(item.id)")
        },
        onDismiss: {
            print("Dismissed")
        }
    )
}
