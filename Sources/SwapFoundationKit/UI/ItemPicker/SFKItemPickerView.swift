import SwiftUI
import UIKit

/// A typed item picker for single- and multi-selection.
///
/// `Item` remains concrete throughout selection and action callbacks.
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
    private let items: [Item]
    private let sections: [SFKItemPickerSection<Item>]?
    private let label: (Item) -> String
    private let onSelectTyped: ((Item) -> Void)?
    private let actionsProviderTyped: ((Item) -> [SFKItemPickerItemAction])?
    private let selectsItems: Bool
    private let autoDismissOnSingleSelection: Bool
    private let showsCloseButton: Bool
    private let embedsInNavigationStack: Bool
    private let toolbarActions: [SFKItemPickerToolbarAction]
    private let emptyState: SFKItemPickerEmptyState?
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
        self.sections = nil
        self.label = label
        self.onSelectTyped = onSelect
        self.actionsProviderTyped = nil
        self.selectsItems = true
        self.autoDismissOnSingleSelection = true
        self.showsCloseButton = true
        self.embedsInNavigationStack = true
        self.toolbarActions = []
        self.emptyState = nil
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
        self.sections = nil
        self.label = configuration.label
        self.onSelectTyped = onSelect
        self.actionsProviderTyped = configuration.actionsProvider
        self.selectsItems = configuration.selectsItems
        self.autoDismissOnSingleSelection = configuration.autoDismissOnSingleSelection
        self.showsCloseButton = configuration.showsCloseButton
        self.embedsInNavigationStack = configuration.embedsInNavigationStack
        self.toolbarActions = configuration.toolbarActions
        self.emptyState = configuration.emptyState
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
        self.sections = nil
        self.label = label
        self.onSelectTyped = onSelect
        self.actionsProviderTyped = nil
        self.selectsItems = true
        self.autoDismissOnSingleSelection = false
        self.showsCloseButton = true
        self.embedsInNavigationStack = true
        self.toolbarActions = []
        self.emptyState = nil
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
        self.sections = nil
        self.label = configuration.label
        self.onSelectTyped = onSelect
        self.actionsProviderTyped = configuration.actionsProvider
        self.selectsItems = configuration.selectsItems
        self.autoDismissOnSingleSelection = false
        self.showsCloseButton = configuration.showsCloseButton
        self.embedsInNavigationStack = configuration.embedsInNavigationStack
        self.toolbarActions = configuration.toolbarActions
        self.emptyState = configuration.emptyState

        self.typedSingleSelection = nil
        self.typedNonOptionalSelection = nil
        self.typedMultiSelection = selections
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
        self.sections = nil
        self.label = label
        self.onSelectTyped = onSelect
        self.actionsProviderTyped = nil
        self.selectsItems = true
        self.autoDismissOnSingleSelection = true
        self.showsCloseButton = true
        self.embedsInNavigationStack = true
        self.toolbarActions = []
        self.emptyState = nil
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
        self.sections = nil
        self.label = configuration.label
        self.onSelectTyped = onSelect
        self.actionsProviderTyped = configuration.actionsProvider
        self.selectsItems = configuration.selectsItems
        self.autoDismissOnSingleSelection = configuration.autoDismissOnSingleSelection
        self.showsCloseButton = configuration.showsCloseButton
        self.embedsInNavigationStack = configuration.embedsInNavigationStack
        self.toolbarActions = configuration.toolbarActions
        self.emptyState = configuration.emptyState
        self.typedSingleSelection = nil
        self.typedNonOptionalSelection = selection
        self.typedMultiSelection = nil
    }

    /// Creates a single-select, sectioned picker with focused advanced configuration.
    public init(
        pageTitle: String,
        sections: [SFKItemPickerSection<Item>],
        selection: Binding<Item?>,
        configuration: SFKItemPickerConfiguration<Item>,
        onSelect: ((Item) -> Void)? = nil
    ) {
        self.pageTitle = pageTitle
        self.pageSubtitle = configuration.pageSubtitle.isEmpty ? "Tap to Select".localized : configuration.pageSubtitle
        self.items = []
        self.sections = sections
        self.label = configuration.label
        self.onSelectTyped = onSelect
        self.actionsProviderTyped = configuration.actionsProvider
        self.selectsItems = configuration.selectsItems
        self.autoDismissOnSingleSelection = configuration.autoDismissOnSingleSelection
        self.showsCloseButton = configuration.showsCloseButton
        self.embedsInNavigationStack = configuration.embedsInNavigationStack
        self.toolbarActions = configuration.toolbarActions
        self.emptyState = configuration.emptyState
        self.typedSingleSelection = selection
        self.typedNonOptionalSelection = nil
        self.typedMultiSelection = nil
    }

    /// Creates a multi-select, sectioned picker with focused advanced configuration.
    public init(
        pageTitle: String,
        sections: [SFKItemPickerSection<Item>],
        selections: Binding<Set<Item>>,
        configuration: SFKItemPickerConfiguration<Item>,
        onSelect: ((Item) -> Void)? = nil
    ) {
        self.pageTitle = pageTitle
        self.pageSubtitle = configuration.pageSubtitle.isEmpty ? "Select Multiple".localized : configuration.pageSubtitle
        self.items = []
        self.sections = sections
        self.label = configuration.label
        self.onSelectTyped = onSelect
        self.actionsProviderTyped = configuration.actionsProvider
        self.selectsItems = configuration.selectsItems
        self.autoDismissOnSingleSelection = false
        self.showsCloseButton = configuration.showsCloseButton
        self.embedsInNavigationStack = configuration.embedsInNavigationStack
        self.toolbarActions = configuration.toolbarActions
        self.emptyState = configuration.emptyState
        self.typedSingleSelection = nil
        self.typedNonOptionalSelection = nil
        self.typedMultiSelection = selections
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
        typedContent(items)
    }

    private func matches(_ item: Item, query: String) -> Bool {
        query.isEmpty
            || label(item).localizedCaseInsensitiveContains(query)
            || (item.pickableItemSubtitle?.localizedCaseInsensitiveContains(query) ?? false)
    }

    private func typedContent(_ items: [Item]) -> some View {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let visibleItems = items.filter { matches($0, query: query) }
        let visibleSections = sections?.compactMap { section -> SFKItemPickerSection<Item>? in
            let filtered = section.items.filter { matches($0, query: query) }
            return filtered.isEmpty ? nil : SFKItemPickerSection(id: section.id, title: section.title, items: filtered)
        }
        let sourceIsEmpty = sections?.allSatisfy { $0.items.isEmpty } ?? items.isEmpty
        let visibleIsEmpty = visibleSections?.isEmpty ?? visibleItems.isEmpty
        let list = ZStack {
            // List's scroll host may not paint the replacement background
            // consistently when its native content background is hidden.
            theme.colors.groupedBackground
                .ignoresSafeArea()

            List {
                if let visibleSections {
                    ForEach(visibleSections) { section in
                        Section(section.title) {
                            ForEach(section.items, id: \.pickableItemId) { item in
                                typedRow(item)
                                    .listRowBackground(theme.colors.groupedRowSurface)
                            }
                        }
                    }
                } else {
                    ForEach(visibleItems, id: \.pickableItemId) { item in
                        typedRow(item)
                            .listRowBackground(theme.colors.groupedRowSurface)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .overlay {
                if sourceIsEmpty, let emptyState { emptyStateView(emptyState) }
                else if visibleIsEmpty { ContentUnavailableView.search(text: searchText) }
            }
        }
        .navigationTitle(pageTitle)
        .navigationBarTitleDisplayMode(.inline)
        .modifier(NavigationSubtitleModifier(subtitle: resolvedTypedSubtitle))
        .searchable(text: $searchText)
        .toolbar { toolbarContent(onDismiss: { dismiss() }) }

        return list
    }

    private func typedRow(_ item: Item) -> some View {
        let selected = typedIsSelected(item)
        return SFKItemPickerRow(
            item: item,
            isMultiple: typedMultiSelection != nil,
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
            Self.toggleSelection(item, in: &value)
            selections.wrappedValue = value
        }
    }

    /// Applies the same stable-ID selection behavior used by the rendered rows.
    /// Kept internal so the package can verify binding behavior without a
    /// simulator while preserving concrete item types.
    static func toggleSelection(_ item: Item, in selections: inout Set<Item>) {
        if let existing = selections.first(where: { $0.pickableItemId == item.pickableItemId }) {
            selections.remove(existing)
        } else {
            selections.insert(item)
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
            if showsCloseButton {
                SFKCompactButton(type: .close, chrome: .toolbar, action: onDismiss)
            }
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
        SFKButton(action.title ?? "", role: .toolbar, action: action.action)
            .sfkIcon(action.systemImage)
            .sfkFullWidth(false)
            .sfkTint(.primary)
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

/// Applies `.navigationSubtitle` on iOS 26+ without wrapping the content in an
/// extra container. A wrapping `Group` here would put `.searchable`/`.toolbar`
/// one view level above `.navigationTitle`, which makes the navigation bar
/// resolve in two passes and the title visibly pop in after first appearance.
private struct NavigationSubtitleModifier: ViewModifier {
    let subtitle: String

    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content.navigationSubtitle(subtitle)
        } else {
            content
        }
    }
}
