//
//  SFKItemPickerRow.swift
//  SwapFoundationKit
//
//  Created by Swapnanil Dhol  on 4/19/26.
//

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
                    .frame(width: 45, height: 45)
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.pickableItemTitle)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    if let subtitle = item.pickableItemSubtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()

                if isSelected {
                    Image(systemName: selectionType == .multi ? "checkmark.square.fill" : "inset.filled.circle")
                        .foregroundStyle(Color(.label))
                        .fontWeight(.bold)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func iconView(for kind: SFKPickableItemIconKind) -> some View {
        switch kind {
        case .iconImage(let uiImage):
            Image(uiImage: uiImage)
                .resizable()
        case .systemIcon(let symbolName):
            Image(systemName: symbolName)
                .resizable()
        case .text(let text):
            Text(text)
                .font(.title3)
                .fontWeight(.heavy)
        case .none:
            EmptyView()
        }
    }
}
