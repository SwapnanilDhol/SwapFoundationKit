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
/// Supports single-select and multi-select modes. State is managed by
/// `SFKItemPickerViewModel` — pass a `@StateObject` vm to this view.
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
///         pageTitle: "Select Currency",
///         viewModel: pickerVM,
///         onDismiss: { }
///     )
/// }
///
/// // Read selection:
/// let selected = pickerVM.selectedItems
/// ```
public struct SFKItemPickerView: View {

    let pageTitle: String
    let pageSubtitle: String
    @ObservedObject var viewModel: SFKItemPickerViewModel
    let onSelect: ((any SFKPickableItem) -> Void)?
    let onDismiss: (() -> Void)?

    public init(
        pageTitle: String,
        pageSubtitle: String = "",
        viewModel: SFKItemPickerViewModel,
        onSelect: ((any SFKPickableItem) -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        self.pageTitle = pageTitle
        self.viewModel = viewModel
        self.onSelect = onSelect
        self.onDismiss = onDismiss

        if pageSubtitle.isEmpty {
            switch viewModel.selectionType {
            case .single:
                self.pageSubtitle = "Tap to Select".localized
            case .multi:
                self.pageSubtitle = "Select Multiple".localized
            }
        } else {
            self.pageSubtitle = pageSubtitle
        }
    }

    public var body: some View {
        NavigationStack {
            List(viewModel.items, id: \.pickableItemId) { item in
                SFKItemPickerRow(
                    item: item,
                    selectionType: viewModel.selectionType,
                    isSelected: viewModel.isSelected(item),
                    didSelect: { selectedItem in
                        viewModel.handleSelection(of: selectedItem)
                        onSelect?(selectedItem)
                    }
                )
            }
            .navigationTitle(pageTitle)
            .navigationBarTitleDisplayMode(.inline)
            .compatibleNavigationSubtitle(resolvedSubtitle)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    SFKButton(configuration: .close, action: {
                        onDismiss?()
                    })
                }
            }
        }
    }

    private var resolvedSubtitle: String {
        if viewModel.selectionType == .multi && !viewModel.selectedItems.isEmpty {
            return "\(viewModel.selectedItems.count) Selected"
        }
        return pageSubtitle
    }
}

// MARK: - Previews

#Preview("Single Select - Currency") {
    @Previewable @StateObject var vm = SFKItemPickerViewModel(
        items: Array(Currency.allCases.prefix(10)),
        selectionType: .single,
        initialSelection: [Currency.USD]
    )
    SFKItemPickerView(
        pageTitle: "Select Currency",
        viewModel: vm,
        onSelect: { _ in },
        onDismiss: { }
    )
}

#Preview("Multi Select - Currency") {
    @Previewable @StateObject var vm = SFKItemPickerViewModel(
        items: Array(Currency.allCases.prefix(10)),
        selectionType: .multi,
        initialSelection: [Currency.USD, Currency.EUR]
    )
    SFKItemPickerView(
        pageTitle: "Select Currencies",
        viewModel: vm,
        onSelect: nil,
        onDismiss: { }
    )
}
