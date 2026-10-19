/*****************************************************************************
 * SFKAppPromotionCard.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI

/// A quiet, dismissible card that introduces another app from the same developer.
///
/// It is sized to sit above a list like any other inline notice. The host owns
/// when it appears and remembers dismissal; the card only reports taps.
public struct SFKAppPromotionCard: View {
    @Environment(\.sfkTheme) private var theme

    private let promotion: SFKAppPromotion
    private let onOpen: () -> Void
    private let onDismiss: () -> Void

    public init(
        promotion: SFKAppPromotion,
        onOpen: @escaping () -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.promotion = promotion
        self.onOpen = onOpen
        self.onDismiss = onDismiss
    }

    public var body: some View {
        HStack(alignment: .center, spacing: 12) {
            icon

            VStack(alignment: .leading, spacing: 2) {
                Text(promotion.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(theme.colors.text)

                Text(promotion.pitch)
                    .font(.caption)
                    .foregroundStyle(theme.colors.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 4)

            SFKCompactButton(promotion.actionTitle, chrome: .glass, action: onOpen)
                .accessibilityIdentifier("appPromotion.open")

            SFKCompactButton(type: .close, chrome: .inline, foreground: .secondary, action: onDismiss)
                .accessibilityIdentifier("appPromotion.dismiss")
        }
        .padding(14)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
        }
        .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .onTapGesture(perform: onOpen)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("appPromotion.card")
    }

    @ViewBuilder
    private var icon: some View {
        if let iconImageName = promotion.iconImageName {
            Image(iconImageName)
                .resizable()
                .scaledToFill()
                .frame(width: 44, height: 44)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(Color.primary.opacity(0.08), lineWidth: 0.5)
                }
                .accessibilityHidden(true)
        } else {
            Image(systemName: "app.badge")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.tint)
                .frame(width: 44, height: 44)
                .background(Color.accentColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                .accessibilityHidden(true)
        }
    }
}

#if DEBUG
#Preview {
    SFKAppPromotionCard(
        promotion: SFKAppPromotion(
            appStoreID: "6479275107",
            name: "Windfall",
            pitch: "See where every dollar goes, by the same developer.",
            actionTitle: "Get"
        ),
        onOpen: {},
        onDismiss: {}
    )
    .padding()
}
#endif
