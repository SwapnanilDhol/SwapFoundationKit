/*****************************************************************************
 * EffectsExamplesView.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI
import SwapFoundationKit

struct EffectsExamplesView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                CatalogExampleGroup(
                    title: "Top Aura",
                    apiNames: ["TopAuraBackground", "SFKAuraLayer"]
                ) {
                    previewCard {
                        TopAuraBackground(glowColor: .blue, opacity: 0.34, blurRadius: 24, bandHeight: 160)
                    }
                }

                CatalogExampleGroup(
                    title: "Aura Glow",
                    apiNames: ["SFKAuraGlowBackground"]
                ) {
                    previewCard {
                        SFKAuraGlowBackground(color: .purple) {
                            Text("Atmospheric surface")
                                .font(.headline)
                                .padding(.top, 54)
                        }
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Aura Effects")
    }

    private func previewCard<Background: View>(
        @ViewBuilder background: () -> Background
    ) -> some View {
        background()
            .frame(height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .strokeBorder(.primary.opacity(0.08))
            }
    }
}

#Preview {
    NavigationStack {
        EffectsExamplesView()
    }
}
