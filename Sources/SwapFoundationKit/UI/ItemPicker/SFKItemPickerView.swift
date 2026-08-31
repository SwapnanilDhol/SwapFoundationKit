import SwiftUI
import UIKit

/// A typed item picker for single- and multi-selection.
///
/// The binding initializers are the v4 API. `Item` remains concrete throughout
/// selection and action callbacks; the old view-model initializer below is a
/// deprecated compatibility bridge for v3 callers.
public struct SFKItemPickerConfiguration<Item: SFKPickableItem> {
    public var pageSubtitle: String
    public var label: (Item) -> String
    public var actionsProvider: ((Item) -> [SFKItemPickerItemAction])?
    public var selectsItems: Bool = true
    public var autoDismissOnSingleSelection: Bool = true
    public var showsCloseButton: Bool = true
    public var embedsInNavigationStack: Bool = true
    public var toolbarActions: [SFKItemPickerToolbarAction] = []
    public var emptyState: SFKItemPickerEmptyState?

    public init(
        pageSubtitle: String = "",
        label: @escaping (Item) -> String = { $0.pickableItemTitle },
        actionsProvider: ((Item) -> [SFKItemPickerItemAction])? = nil
    ) {
        self.pageSubtitle = pageSubtitle
        self.label = label
        self.actionsProvider = actionsProvider
        self.emptyState = nil
    }
}

public struct SFKItemPickerView<Item: SFKPickableItem>: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.sfkTheme) private var theme
    private let pageTitle: String
    private let pageSubtitle: String
    private let items: [Item]?
    private let label: (Item) -> String
    private let onSelectTyped: ((Item) -> Void)?
    private let actionsProviderTyped: ((Item) -> [SFKItemPickerItemAction])?
    private let selectsItems: Bool
    private let autoDismissOnSingleSelection: Bool
    private let showsCloseButton: Bool
    private let embedsInNavigationStack: Bool
    private let toolbarActions: [SFKItemPickerToolbarAction]
    private let emptyState: SFKItemPickerEmptyState?
    private let legacyContent: _SFKLegacyItemPickerContent?
    private let typedSingleSelection: Binding<Item?>?
    private let typedNonOptionalSelection: Binding<Item>?
    private let typedMultiSelection: Binding<Set<Item>>?
    @State private var searchText = ""

    /// Creates a single-select picker whose selection is owned by the caller.
    public init(
        _ pageTitle: String,
        items: [Item],
        selection: Binding<Item?>,
        label: @escaping (Item) -> String = { $0.pickableItemTitle },
        onSelect: ((Item) -> Void)? = nil
    ) {
        self.pageTitle = pageTitle
        self.pageSubtitle = "Tap to Select".localized
        self.items = items
        self.label = label
        self.onSelectTyped = onSelect
        self.actionsProviderTyped = nil
        self.selectsItems = true
        self.autoDismissOnSingleSelection = true
        self.showsCloseButton = true
        self.embedsInNavigationStack = true
        self.toolbarActions = []
        self.emptyState = nil
        self.legacyContent = nil
        self.typedSingleSelection = selection
        self.typedNonOptionalSelection = nil
        self.typedMultiSelection = nil
    }

    /// Creates a single-select picker with focused advanced configuration.
    public init(
        pageTitle: String,
        items: [Item],
        selection: Binding<Item?>,
        configuration: SFKItemPickerConfiguration<Item>,
        onSelect: ((Item) -> Void)? = nil
    ) {
        self.pageTitle = pageTitle
        self.pageSubtitle = configuration.pageSubtitle.isEmpty ? "Tap to Select".localized : configuration.pageSubtitle
        self.items = items
        self.label = configuration.label
        self.onSelectTyped = onSelect
        self.actionsProviderTyped = configuration.actionsProvider
        self.selectsItems = configuration.selectsItems
        self.autoDismissOnSingleSelection = configuration.autoDismissOnSingleSelection
        self.showsCloseButton = configuration.showsCloseButton
        self.embedsInNavigationStack = configuration.embedsInNavigationStack
        self.toolbarActions = configuration.toolbarActions
        self.emptyState = configuration.emptyState
        self.legacyContent = nil
        self.typedSingleSelection = selection
        self.typedNonOptionalSelection = nil
        self.typedMultiSelection = nil
    }

    /// Creates a multi-select picker whose selection is owned by the caller.
    public init(
        _ pageTitle: String,
        items: [Item],
        selections: Binding<Set<Item>>,
        label: @escaping (Item) -> String = { $0.pickableItemTitle },
        onSelect: ((Item) -> Void)? = nil
    ) {
        self.pageTitle = pageTitle
        self.pageSubtitle = "Select Multiple".localized
        self.items = items
        self.label = label
        self.onSelectTyped = onSelect
        self.actionsProviderTyped = nil
        self.selectsItems = true
        self.autoDismissOnSingleSelection = false
        self.showsCloseButton = true
        self.embedsInNavigationStack = true
        self.toolbarActions = []
        self.emptyState = nil
        self.legacyContent = nil
        self.typedSingleSelection = nil
        self.typedNonOptionalSelection = nil
        self.typedMultiSelection = selections
    }

    /// Creates a multi-select picker with focused advanced configuration.
    public init(
        pageTitle: String,
        items: [Item],
        selections: Binding<Set<Item>>,
        configuration: SFKItemPickerConfiguration<Item>,
        onSelect: ((Item) -> Void)? = nil
    ) {
        self.pageTitle = pageTitle
        self.pageSubtitle = configuration.pageSubtitle.isEmpty ? "Select Multiple".localized : configuration.pageSubtitle
        self.items = items
        self.label = configuration.label
        self.onSelectTyped = onSelect
        self.actionsProviderTyped = configuration.actionsProvider
        self.selectsItems = configuration.selectsItems
        self.autoDismissOnSingleSelection = false
        self.showsCloseButton = configuration.showsCloseButton
        self.embedsInNavigationStack = configuration.embedsInNavigationStack
        self.toolbarActions = configuration.toolbarActions
        self.emptyState = configuration.emptyState
        self.legacyContent = nil
        self.typedSingleSelection = nil
        self.typedNonOptionalSelection = nil
        self.typedMultiSelection = selections
    }

    /// Legacy view-model initializer. Prefer a typed selection binding.
    @available(*, deprecated, message: "Use SFKItemPickerView(items:selection:) or SFKItemPickerView(items:selections:).")
    public init(
        pageTitle: String,
        pageSubtitle: String = "",
        viewModel: SFKItemPickerViewModel,
        selectsItems: Bool = true,
        autoDismissOnSingleSelection: Bool = true,
        showsCloseButton: Bool = true,
        embedsInNavigationStack: Bool = true,
        toolbarActions: [SFKItemPickerToolbarAction] = [],
        emptyState: SFKItemPickerEmptyState? = nil,
        onSelect: ((any SFKPickableItem) -> Void)? = nil,
        onDismiss: (() -> Void)? = nil,
        actionsProvider: ((any SFKPickableItem) -> [SFKItemPickerItemAction])? = nil
    ) where Item == SFKItemPickerLegacyItem {
        self.pageTitle = pageTitle
        self.pageSubtitle = pageSubtitle.isEmpty
            ? (viewModel.selectionType == .single ? "Tap to Select" : "Select Multiple")
            : pageSubtitle
        self.items = nil
        self.label = { $0.pickableItemTitle }
        self.onSelectTyped = nil
        self.actionsProviderTyped = nil
        self.selectsItems = selectsItems
        self.autoDismissOnSingleSelection = autoDismissOnSingleSelection
        self.showsCloseButton = showsCloseButton
        self.embedsInNavigationStack = embedsInNavigationStack
        self.toolbarActions = toolbarActions
        self.emptyState = emptyState
        self.legacyContent = _SFKLegacyItemPickerContent(
            pageTitle: pageTitle,
            pageSubtitle: pageSubtitle,
            viewModel: viewModel,
            selectsItems: selectsItems,
            autoDismissOnSingleSelection: autoDismissOnSingleSelection,
            showsCloseButton: showsCloseButton,
            toolbarActions: toolbarActions,
            emptyState: emptyState,
            onSelect: onSelect,
            onDismiss: onDismiss,
            actionsProvider: actionsProvider
        )
        self.typedSingleSelection = nil
        self.typedNonOptionalSelection = nil
        self.typedMultiSelection = nil
    }

    /// Creates a single-select picker for a non-optional binding. Tapping an
    /// item always writes a value and therefore never clears the selection.
    public init(
        _ pageTitle: String,
        items: [Item],
        selection: Binding<Item>,
        label: @escaping (Item) -> String = { $0.pickableItemTitle },
        onSelect: ((Item) -> Void)? = nil
    ) {
        self.pageTitle = pageTitle
        self.pageSubtitle = "Tap to Select".localized
        self.items = items
        self.label = label
        self.onSelectTyped = onSelect
        self.actionsProviderTyped = nil
        self.selectsItems = true
        self.autoDismissOnSingleSelection = true
        self.showsCloseButton = true
        self.embedsInNavigationStack = true
        self.toolbarActions = []
        self.emptyState = nil
        self.legacyContent = nil
        self.typedSingleSelection = nil
        self.typedNonOptionalSelection = selection
        self.typedMultiSelection = nil
    }

    /// Creates a non-optional single-select picker with focused configuration.
    public init(
        pageTitle: String,
        items: [Item],
        selection: Binding<Item>,
        configuration: SFKItemPickerConfiguration<Item>,
        onSelect: ((Item) -> Void)? = nil
    ) {
        self.pageTitle = pageTitle
        self.pageSubtitle = configuration.pageSubtitle.isEmpty ? "Tap to Select".localized : configuration.pageSubtitle
        self.items = items
        self.label = configuration.label
        self.onSelectTyped = onSelect
        self.actionsProviderTyped = configuration.actionsProvider
        self.selectsItems = configuration.selectsItems
        self.autoDismissOnSingleSelection = configuration.autoDismissOnSingleSelection
        self.showsCloseButton = configuration.showsCloseButton
        self.embedsInNavigationStack = configuration.embedsInNavigationStack
        self.toolbarActions = configuration.toolbarActions
        self.emptyState = configuration.emptyState
        self.legacyContent = nil
        self.typedSingleSelection = nil
        self.typedNonOptionalSelection = selection
        self.typedMultiSelection = nil
    }

    public var body: some View {
        Group {
            if embedsInNavigationStack {
                NavigationStack { content }
            } else { content }
        }
    }

    @ViewBuilder
    private var content: some View {
        if let legacyContent {
            legacyContent
        } else if let items {
            typedContent(items)
        }
    }

    private func typedContent(_ items: [Item]) -> some View {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let visibleItems = query.isEmpty ? items : items.filter {
            label($0).localizedCaseInsensitiveContains(query)
                || ($0.pickableItemSubtitle?.localizedCaseInsensitiveContains(query) ?? false)
        }
        return List {
            ForEach(visibleItems, id: \.pickableItemId) { item in
                typedRow(item)
            }
        }
        .scrollContentBackground(.hidden)
        .background(theme.colors.background)
        .overlay {
            if items.isEmpty, let emptyState { emptyStateView(emptyState) }
            else if visibleItems.isEmpty { ContentUnavailableView.search(text: searchText) }
        }
        .navigationTitle(pageTitle)
        .navigationBarTitleDisplayMode(.inline)
        .compatibleNavigationSubtitle(resolvedTypedSubtitle)
        .searchable(text: $searchText)
        .toolbar { toolbarContent(onDismiss: { dismiss() }) }
    }

    private func typedRow(_ item: Item) -> some View {
        let selected = typedIsSelected(item)
        return SFKItemPickerRow(
            item: item,
            selectionType: typedMultiSelection == nil ? .single : .multi,
            isSelected: selectsItems && selected,
            title: label(item),
            didSelect: { _ in
                if selectsItems { toggleTyped(item) }
                onSelectTyped?(item)
                if selectsItems && autoDismissOnSingleSelection && typedMultiSelection == nil {
                    dismiss()
                }
            }
        )
        .contextMenu {
            ForEach((actionsProviderTyped?(item) ?? []).filter { $0.presentation == .contextMenu }) { action in
                Button(role: action.role, action: action.action) { Label(action.title, systemImage: action.systemImage) }
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            ForEach((actionsProviderTyped?(item) ?? []).filter { $0.presentation == .swipe }) { action in
                Button(role: action.role, action: action.action) { Label(action.title, systemImage: action.systemImage) }
            }
        }
    }

    private func typedIsSelected(_ item: Item) -> Bool {
        if let selection = typedSingleSelection {
            return selection.wrappedValue?.pickableItemId == item.pickableItemId
        }
        if let selection = typedNonOptionalSelection {
            return selection.wrappedValue.pickableItemId == item.pickableItemId
        }
        return typedMultiSelection?.wrappedValue.contains { $0.pickableItemId == item.pickableItemId } ?? false
    }

    private func toggleTyped(_ item: Item) {
        if let selection = typedSingleSelection {
            selection.wrappedValue = typedIsSelected(item) ? nil : item
        } else if let selection = typedNonOptionalSelection {
            selection.wrappedValue = item
        } else if let selections = typedMultiSelection {
            var value = selections.wrappedValue
            if let existing = value.first(where: { $0.pickableItemId == item.pickableItemId }) {
                value.remove(existing)
            } else {
                value.insert(item)
            }
            selections.wrappedValue = value
        }
    }

    private var resolvedTypedSubtitle: String {
        if let selections = typedMultiSelection, !selections.wrappedValue.isEmpty {
            return "\(selections.wrappedValue.count) Selected"
        }
        return pageSubtitle
    }

    @ToolbarContentBuilder
    private func toolbarContent(onDismiss: @escaping () -> Void) -> some ToolbarContent {
        ToolbarItemGroup(placement: .topBarLeading) {
            if showsCloseButton { SFKCloseButton(action: onDismiss) }
            ForEach(toolbarActions.filter { $0.placement == .topBarLeading }) { action in
                toolbarButton(action)
            }
        }
        ToolbarItemGroup(placement: .topBarTrailing) {
            ForEach(toolbarActions.filter { $0.placement == .topBarTrailing }) { action in
                toolbarButton(action)
            }
        }
    }

    private func toolbarButton(_ action: SFKItemPickerToolbarAction) -> some View {
        SFKButton(action.title ?? "", leadingIconName: action.systemImage, fullWidth: false,
                  titleColor: .primary, style: .toolbar, action: action.action)
    }

    @ViewBuilder
    private func emptyStateView(_ state: SFKItemPickerEmptyState) -> some View {
        if let actionTitle = state.actionTitle, let action = state.action {
            ContentUnavailableView {
                Label(state.title, systemImage: state.systemImage)
            } description: {
                if let description = state.description { Text(description) }
            } actions: {
                Button(actionTitle, action: action)
            }
        } else {
            ContentUnavailableView(state.title, systemImage: state.systemImage,
                                   description: state.description.map { Text($0) })
        }
    }

}

private struct _SFKLegacyItemPickerContent: View {
    @Environment(\.sfkTheme) private var theme
    let pageTitle: String
    let pageSubtitle: String
    @ObservedObject var viewModel: SFKItemPickerViewModel
    let selectsItems: Bool
    let autoDismissOnSingleSelection: Bool
    let showsCloseButton: Bool
    let toolbarActions: [SFKItemPickerToolbarAction]
    let emptyState: SFKItemPickerEmptyState?
    let onSelect: ((any SFKPickableItem) -> Void)?
    let onDismiss: (() -> Void)?
    let actionsProvider: ((any SFKPickableItem) -> [SFKItemPickerItemAction])?

    var body: some View {
        List {
            ForEach(viewModel.filteredSections) { section in
                if section.title == nil && section.footer == nil {
                    ForEach(section.items, id: \.pickableItemId) { item in row(item) }
                } else {
                    Section {
                        ForEach(section.items, id: \.pickableItemId) { item in row(item) }
                    } header: {
                        if let title = section.title { Text(title) }
                    } footer: {
                        if let footer = section.footer { Text(footer) }
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(theme.colors.background)
        .overlay {
            if viewModel.items.isEmpty, let emptyState { emptyStateView(emptyState) }
            else if viewModel.filteredSections.isEmpty { ContentUnavailableView.search(text: viewModel.searchText) }
        }
        .navigationTitle(pageTitle)
        .navigationBarTitleDisplayMode(.inline)
        .compatibleNavigationSubtitle(resolvedSubtitle)
        .searchable(text: $viewModel.searchText)
        .toolbar {
            ToolbarItemGroup(placement: .topBarLeading) {
                if showsCloseButton { SFKCloseButton { onDismiss?() } }
                ForEach(toolbarActions.filter { $0.placement == .topBarLeading }) { action in toolbarButton(action) }
            }
            ToolbarItemGroup(placement: .topBarTrailing) {
                ForEach(toolbarActions.filter { $0.placement == .topBarTrailing }) { action in toolbarButton(action) }
            }
        }
    }

    private func row(_ item: any SFKPickableItem) -> some View {
        SFKItemPickerRow(item: item, selectionType: viewModel.selectionType,
                         isSelected: selectsItems && viewModel.isSelected(item)) { selectedItem in
            if selectsItems { viewModel.handleSelection(of: selectedItem) }
            onSelect?(selectedItem)
            if selectsItems && autoDismissOnSingleSelection && viewModel.selectionType == .single { onDismiss?() }
        }
        .contextMenu {
            ForEach((actionsProvider?(item) ?? []).filter { $0.presentation == .contextMenu }) { action in
                Button(role: action.role, action: action.action) { Label(action.title, systemImage: action.systemImage) }
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            ForEach((actionsProvider?(item) ?? []).filter { $0.presentation == .swipe }) { action in
                Button(role: action.role, action: action.action) { Label(action.title, systemImage: action.systemImage) }
            }
        }
    }

    private var resolvedSubtitle: String {
        if viewModel.selectionType == .multi && !viewModel.selectedItems.isEmpty { return "\(viewModel.selectedItems.count) Selected" }
        return pageSubtitle
    }

    private func toolbarButton(_ action: SFKItemPickerToolbarAction) -> some View {
        SFKButton(action.title ?? "", leadingIconName: action.systemImage, fullWidth: false,
                  titleColor: .primary, style: .toolbar, action: action.action)
    }

    @ViewBuilder
    private func emptyStateView(_ state: SFKItemPickerEmptyState) -> some View {
        if let actionTitle = state.actionTitle, let action = state.action {
            ContentUnavailableView {
                Label(state.title, systemImage: state.systemImage)
            } description: {
                if let description = state.description { Text(description) }
            } actions: { Button(actionTitle, action: action) }
        } else {
            ContentUnavailableView(state.title, systemImage: state.systemImage, description: state.description.map { Text($0) })
        }
    }
}

/// A stable concrete adapter used only by deprecated view-model call sites.
/// Concrete adapter used by the deprecated view-model initializer.
@available(*, deprecated, message: "Use a concrete SFKPickableItem with a selection binding.")
public struct SFKItemPickerLegacyItem: SFKPickableItem {
    private let base: any SFKPickableItem

    public init(_ base: any SFKPickableItem) { self.base = base }

    public var id: String { pickableItemId }
    public var pickableItemId: String { base.pickableItemId }
    public var pickableItemIconKind: SFKPickableItemIconKind { base.pickableItemIconKind }
    public var pickableItemTitle: String { base.pickableItemTitle }
    public var pickableItemSubtitle: String? { base.pickableItemSubtitle }
    public var pickableItemBadgeTitle: String? { base.pickableItemBadgeTitle }
    public var pickableItemIconTintColor: UIColor? { base.pickableItemIconTintColor }
    public var pickableItemTrailingAccessory: SFKPickableItemTrailingAccessory { base.pickableItemTrailingAccessory }

    public static func == (lhs: Self, rhs: Self) -> Bool { lhs.pickableItemId == rhs.pickableItemId }
    public func hash(into hasher: inout Hasher) { hasher.combine(pickableItemId) }
}
