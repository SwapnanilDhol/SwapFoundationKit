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
    let actionsProvider: ((any SFKPickableItem) -> [SFKItemPickerItemAction])?
    let selectsItems: Bool
    let autoDismissOnSingleSelection: Bool
    let showsCloseButton: Bool
    let toolbarActions: [SFKItemPickerToolbarAction]

    public init(
        pageTitle: String,
        pageSubtitle: String = "",
        viewModel: SFKItemPickerViewModel,
        selectsItems: Bool = true,
        autoDismissOnSingleSelection: Bool = true,
        showsCloseButton: Bool = true,
        toolbarActions: [SFKItemPickerToolbarAction] = [],
        onSelect: ((any SFKPickableItem) -> Void)? = nil,
        onDismiss: (() -> Void)? = nil,
        actionsProvider: ((any SFKPickableItem) -> [SFKItemPickerItemAction])? = nil
    ) {
        self.pageTitle = pageTitle
        self.viewModel = viewModel
        self.onSelect = onSelect
        self.onDismiss = onDismiss
        self.actionsProvider = actionsProvider
        self.selectsItems = selectsItems
        self.autoDismissOnSingleSelection = autoDismissOnSingleSelection
        self.showsCloseButton = showsCloseButton
        self.toolbarActions = toolbarActions

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
            List {
                ForEach(viewModel.filteredSections) { section in
                    if section.title == nil && section.footer == nil {
                        ForEach(section.items, id: \.pickableItemId) { item in
                            itemRow(for: item)
                        }
                    } else {
                        Section {
                            ForEach(section.items, id: \.pickableItemId) { item in
                                itemRow(for: item)
                            }
                        } header: {
                            if let title = section.title {
                                Text(title)
                            }
                        } footer: {
                            if let footer = section.footer {
                                Text(footer)
                            }
                        }
                    }
                }
            }
            .navigationTitle(pageTitle)
            .navigationBarTitleDisplayMode(.inline)
            .compatibleNavigationSubtitle(resolvedSubtitle)
            .searchable(text: $viewModel.searchText)
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    if showsCloseButton {
                        SFKCloseButton {
                            onDismiss?()
                        }
                    }

                    ForEach(leadingToolbarActions) { action in
                        toolbarButton(for: action)
                    }
                }

                ToolbarItemGroup(placement: .topBarTrailing) {
                    ForEach(trailingToolbarActions) { action in
                        toolbarButton(for: action)
                    }
                }
            }
        }
    }

    private func itemRow(for item: any SFKPickableItem) -> some View {
        let actions = actionsProvider?(item) ?? []

        return SFKItemPickerRow(
            item: item,
            selectionType: viewModel.selectionType,
            isSelected: selectsItems && viewModel.isSelected(item),
            didSelect: { selectedItem in
                if selectsItems {
                    viewModel.handleSelection(of: selectedItem)
                }
                onSelect?(selectedItem)

                if selectsItems && autoDismissOnSingleSelection && viewModel.selectionType == .single {
                    onDismiss?()
                }
            }
        )
        .contextMenu {
            ForEach(actions.filter { $0.presentation == .contextMenu }) { action in
                Button(role: action.role) {
                    action.action()
                } label: {
                    Label(action.title, systemImage: action.systemImage)
                }
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            ForEach(actions.filter { $0.presentation == .swipe }) { action in
                Button(role: action.role) {
                    action.action()
                } label: {
                    Label(action.title, systemImage: action.systemImage)
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

    private var leadingToolbarActions: [SFKItemPickerToolbarAction] {
        toolbarActions.filter { $0.placement == .topBarLeading }
    }

    private var trailingToolbarActions: [SFKItemPickerToolbarAction] {
        toolbarActions.filter { $0.placement == .topBarTrailing }
    }

    private func toolbarButton(for action: SFKItemPickerToolbarAction) -> some View {
        SFKButton(
            action.title,
            leadingIconName: action.systemImage,
            fullWidth: false,
            titleColor: .primary,
            style: .toolbar,
            action: action.action
        )
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
