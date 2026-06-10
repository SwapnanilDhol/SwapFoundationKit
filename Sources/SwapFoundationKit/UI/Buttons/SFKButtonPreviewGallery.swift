/*****************************************************************************
 * SFKButtonPreviewGallery.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI

/// An interactive, centralized showcase view for all variants of SFKButton.
/// Used to preview the design system's buttons and their active vs. disabled states.
public struct SFKButtonPreviewGallery: View {
    @State private var areButtonsEnabled: Bool = true

    public init() {}

    public var body: some View {
        VStack(spacing: 20) {
            // Master Toggle
            Toggle(isOn: $areButtonsEnabled) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Enable Buttons")
                        .font(.subheadline.weight(.semibold))
                    Text("Toggle to test the centralized disabled state layout.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(12)
            .padding(.bottom, 8)

            // Primary / CTA Buttons
            VStack(alignment: .leading, spacing: 12) {
                Text("Standard Prominent CTAs")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.leading, 4)

                SFKButton(
                    "Primary Accent",
                    leadingIconName: "sparkles",
                    color: .blue,
                    chrome: .glassProminent,
                    action: {}
                )
                .disabled(!areButtonsEnabled)

                SFKButton(
                    "Warning Action",
                    leadingIconName: "exclamationmark.triangle.fill",
                    color: .orange,
                    chrome: .glassProminent,
                    action: {}
                )
                .disabled(!areButtonsEnabled)

                SFKButton(
                    "Danger Action",
                    leadingIconName: "trash",
                    color: .red,
                    chrome: .glassProminent,
                    action: {}
                )
                .disabled(!areButtonsEnabled)

                SFKButton(
                    "Success Action",
                    leadingIconName: "checkmark.circle.fill",
                    color: .green,
                    chrome: .glassProminent,
                    action: {}
                )
                .disabled(!areButtonsEnabled)
            }

            // Compact, Close & Plain Buttons
            VStack(alignment: .leading, spacing: 12) {
                Text("Compact, Close & Plain Styles")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.leading, 4)

                HStack(spacing: 12) {
                    SFKButton(
                        "Filters",
                        leadingIconName: "slider.horizontal.3",
                        fullWidth: false,
                        color: .white.opacity(0.14),
                        chrome: .glass,
                        action: {}
                    )
                    .disabled(!areButtonsEnabled)

                    SFKButton(
                        "Details",
                        leadingIconName: "doc.text",
                        fullWidth: false,
                        color: .clear,
                        chrome: .plain,
                        action: {}
                    )
                    .disabled(!areButtonsEnabled)

                    SFKButton(
                        "Close".localized,
                        leadingIconName: "xmark",
                        fullWidth: false,
                        titleColor: .primary,
                        subtitleColor: .secondary,
                        color: .white.opacity(0.12),
                        spacing: 8,
                        horizontalPadding: 12,
                        verticalPadding: 5,
                        titleFont: .footnote.weight(.semibold),
                        subtitleFont: .caption2,
                        iconFont: .footnote.weight(.bold),
                        action: {}
                    )
                        .disabled(!areButtonsEnabled)
                }
            }

            // Special Visual Effects
            VStack(alignment: .leading, spacing: 12) {
                Text("Visual Effects & Progress")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.leading, 4)

                SFKButton(
                    "Saving Changes",
                    isLoading: true,
                    color: .blue,
                    action: {}
                )
                .disabled(!areButtonsEnabled)
            }
        }
    }
}

#Preview {
    ScrollView {
        SFKButtonPreviewGallery()
            .padding()
    }
    .background(Color(.systemGroupedBackground))
}
