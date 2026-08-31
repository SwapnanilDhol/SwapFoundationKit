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

                if item.pickableItemTrailingAccessory == .disclosureIndicator {
                    Image(systemName: "chevron.right")
                        .font(theme.typography.caption.weight(.semibold))
                        .foregroundStyle(theme.colors.secondaryText)
                } else if isSelected {
                    Image(systemName: isMultiple ? "checkmark.square.fill" : "inset.filled.circle")
                        .foregroundStyle(theme.colors.accent)
                        .fontWeight(.bold)
                }
            }
            .padding(.vertical, 1)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func iconView(for kind: SFKPickableItemIconKind) -> some View {
        switch kind {
        case .iconImage(let uiImage):
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
        case .systemIcon(let symbolName):
            if let tintColor = item.pickableItemIconTintColor {
                let color = Color(tintColor)
                Image(systemName: symbolName)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(color)
                    .padding(7)
                    .background(
                        RoundedRectangle(cornerRadius: theme.radii.control)
                            .fill(color.opacity(0.15))
                    )
            } else {
                Image(systemName: symbolName)
                    .resizable()
                    .scaledToFit()
            }
        case .text(let text):
            Text(text)
                .font(theme.typography.title)
                .fontWeight(.heavy)
        case .none:
            EmptyView()
        }
    }
}
