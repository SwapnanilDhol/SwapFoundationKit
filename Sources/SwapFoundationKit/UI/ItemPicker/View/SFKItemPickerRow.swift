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

public struct SFKItemPickerRow: View {

    private let hapticsHelper = HapticsHelper()
    let item: any SFKPickableItem
    let selectionType: SFKItemPickerSelectionMode
    let isSelected: Bool
    let didSelect: (any SFKPickableItem) -> Void

    public var body: some View {
        Button {
            hapticsHelper.mediumImpact()
            didSelect(item)
        } label: {
            HStack(spacing: 12) {
                iconView(for: item.pickableItemIconKind)
                    .frame(width: 32, height: 32)
                VStack(alignment: .leading, spacing: 2) {
                    HStack(alignment: .center, spacing: 6) {
                        Text(item.pickableItemTitle)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)

                        if let badgeTitle = item.pickableItemBadgeTitle {
                            Text(badgeTitle)
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color(.systemFill))
                                .clipShape(Capsule())
                        }
                    }

                    if let subtitle = item.pickableItemSubtitle {
                        Text(subtitle)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()

                if item.pickableItemTrailingAccessory == .disclosureIndicator {
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color(.tertiaryLabel))
                } else if isSelected {
                    Image(systemName: selectionType == .multi ? "checkmark.square.fill" : "inset.filled.circle")
                        .foregroundStyle(Color(.label))
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
                        RoundedRectangle(cornerRadius: 6)
                            .fill(color.opacity(0.15))
                    )
            } else {
                Image(systemName: symbolName)
                    .resizable()
                    .scaledToFit()
            }
        case .text(let text):
            Text(text)
                .font(.title3)
                .fontWeight(.heavy)
        case .none:
            EmptyView()
        }
    }
}
