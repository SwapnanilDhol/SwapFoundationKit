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
/// Supports single-select and multi-select modes. Provide display values
/// via the closure callbacks.
///
/// ## Usage
/// ```swift
/// let viewModel = SFKItemPickerViewModel(
///     title: "Select Currency",
///     items: Currency.allCases,
///     selectionMode: .single
/// )
///
/// SFKItemPickerView(viewModel: viewModel)
///     .itemTitle { currency in currency.description.stringKey ?? currency.rawValue }
///     .itemIcon { currency in currency.symbol }
/// ```
public struct SFKItemPickerView: View {
    @ObservedObject public var viewModel: SFKItemPickerViewModel
    @Environment(\.dismiss) private var dismiss

    /// Returns the display title for an item.
    public var itemTitle: ((any SFKPickableItem) -> String)?
    /// Returns the display icon/symbol for an item.
    public var itemIcon: ((any SFKPickableItem) -> String)?
    /// Returns the display subtitle for an item.
    public var itemSubtitle: ((any SFKPickableItem) -> String)?

    public init(viewModel: SFKItemPickerViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.items, id: \.pickerID) { item in
                        itemRow(for: item)
                    }
                }
            }
            .navigationTitle(viewModel.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        viewModel.delegate?.itemPickerDidDismiss(viewModel)
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.footnote.weight(.bold))
                            .foregroundStyle(.secondary)
                            .frame(width: 28, height: 28)
                            .background(Capsule().fill(Color.white.opacity(0.12)))
                    }
                }

                if viewModel.selectionMode == .multi {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") {
                            viewModel.confirmSelection()
                            dismiss()
                        }
                        .disabled(viewModel.selectedItemIDs.isEmpty)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func itemRow(for item: any SFKPickableItem) -> some View {
        let isSelected = viewModel.isSelected(item.pickerID)

        Button {
            handleSelection(item)
        } label: {
            HStack(spacing: 12) {
                if let icon = itemIcon?(item) {
                    Text(icon)
                        .font(.title3)
                        .frame(width: 40)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(itemTitle?(item) ?? item.pickerID)
                        .font(.body)
                        .foregroundStyle(.primary)

                    if let subtitle = itemSubtitle?(item) {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                if isSelected {
                    Image(systemName: viewModel.selectionMode == .multi ? "checkmark.circle.fill" : "checkmark")
                        .foregroundStyle(.blue)
                        .fontWeight(.bold)
                }
            }
            .padding(.vertical, 4)
        }
        .foregroundStyle(.primary)
    }

    private func handleSelection(_ item: any SFKPickableItem) {
        switch viewModel.selectionMode {
        case .single:
            viewModel.selectItem(item)
            dismiss()
        case .multi:
            viewModel.toggleSelection(for: item.pickerID)
        }
    }
}

// MARK: - Preview Helpers

/// Sample conforming type for previews and testing
public struct SamplePickableItem: SFKPickableItem, Identifiable {
    public let id: String
    public let title: String
    public let icon: String

    public var pickerID: String { id }
    public var pickerSymbol: String { icon }
    public var pickerDescription: String { title }

    public init(id: String, title: String, icon: String) {
        self.id = id
        self.title = title
        self.icon = icon
    }
}

#Preview("Single Select") {
    let items = [
        SamplePickableItem(id: "1", title: "Apple", icon: "🍎"),
        SamplePickableItem(id: "2", title: "Banana", icon: "🍌"),
        SamplePickableItem(id: "3", title: "Cherry", icon: "🍒"),
        SamplePickableItem(id: "4", title: "Date", icon: "🫐")
    ]
    let viewModel = SFKItemPickerViewModel(
        title: "Select Fruit",
        items: items,
        selectionMode: .single
    )
    SFKItemPickerView(viewModel: viewModel)
}

#Preview("Multi Select") {
    let items = [
        SamplePickableItem(id: "1", title: "Swift", icon: "swift"),
        SamplePickableItem(id: "2", title: "SwiftUI", icon: "swiftui"),
        SamplePickableItem(id: "3", title: "Xcode", icon: "xcode"),
        SamplePickableItem(id: "4", title: "Combine", icon: "combine")
    ]
    let viewModel = SFKItemPickerViewModel(
        title: "Select Skills",
        items: items,
        selectionMode: .multi
    )
    SFKItemPickerView(viewModel: viewModel)
}