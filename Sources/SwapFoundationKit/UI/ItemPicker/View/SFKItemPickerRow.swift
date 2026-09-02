/*****************************************************************************
 * SFKItemPickerRow.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI
import UIKit

struct SFKItemPickerRow<Item: SFKPickableItem>: View {

    @Environment(\.sfkTheme) private var theme
    private let hapticsHelper = HapticsHelper()
    let item: Item
    let isMultiple: Bool
    let isSelected: Bool
    let didSelect: (Item) -> Void
    private let titleOverride: String?

    init(
        item: Item,
        isMultiple: Bool,
        isSelected: Bool,
        title: String? = nil,
        didSelect: @escaping (Item) -> Void
    ) {
        self.item = item
        self.isMultiple = isMultiple
        self.isSelected = isSelected
        self.titleOverride = title
        self.didSelect = didSelect
    }

    var body: some View {
        Button {
            hapticsHelper.mediumImpact()
            didSelect(item)
        } label: {
            HStack(spacing: theme.spacing.inline + 4) {
                iconView(for: item.pickableItemIconKind)
                    .frame(width: 32, height: 32)
                VStack(alignment: .leading, spacing: theme.spacing.inline / 4) {
                    HStack(alignment: .center, spacing: theme.spacing.inline - 2) {
                        Text(titleOverride ?? item.pickableItemTitle)
                            .font(theme.typography.body.weight(.semibold))
                            .foregroundStyle(theme.colors.text)

                        if let badgeTitle = item.pickableItemBadgeTitle {
                            Text(badgeTitle)
                                .font(theme.typography.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(theme.colors.secondaryText)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(theme.colors.surface)
                                .clipShape(Capsule())
                        }
                    }

                    if let subtitle = item.pickableItemSubtitle {
                        Text(subtitle)
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.secondaryText)
                    }
                }
                Spacer()
                trailingAccessory
            }
            .padding(.vertical, 1)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var trailingAccessory: some View {
        switch item.pickableItemTrailingAccessory {
        case .none:
            if isSelected {
                selectionIndicator
            }
        case .disclosureIndicator:
            Image(systemName: "chevron.right")
                .font(theme.typography.caption.weight(.semibold))
                .foregroundStyle(theme.colors.secondaryText)
        case .checkmark:
            if isSelected {
                selectionIndicator
            }
        case .custom(let iconName):
            Image(systemName: iconName)
                .font(theme.typography.caption.weight(.semibold))
                .foregroundStyle(theme.colors.secondaryText)
        }
    }

    private var selectionIndicator: some View {
        Image(systemName: isMultiple ? "checkmark.square.fill" : "inset.filled.circle")
            .foregroundStyle(theme.colors.accent)
            .fontWeight(.bold)
    }

    @ViewBuilder
    private func iconView(for kind: SFKPickableItemIconKind) -> some View {
        if case .none = kind {
            EmptyView()
        } else {
            ZStack {
                RoundedRectangle(cornerRadius: theme.radii.control, style: .continuous)
                    .fill(iconTint.opacity(0.15))

                switch kind {
                case .iconImage(let uiImage):
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .padding(7)
                case .systemIcon(let symbolName):
                    Image(systemName: symbolName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(iconTint)
                case .text(let text):
                    Text(text)
                        .font(theme.typography.title)
                        .fontWeight(.heavy)
                case .none:
                    EmptyView()
                }
            }
        }
    }

    private var iconTint: Color {
        item.pickableItemIconTintColor.map(Color.init) ?? theme.colors.accent
    }
}
