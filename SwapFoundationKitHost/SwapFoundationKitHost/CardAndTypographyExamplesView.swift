/****************************************************************************
 * CardAndTypographyExamplesView.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwapFoundationKit
import SwiftUI

struct CardAndTypographyExamplesView: View {
    var body: some View {
        ScrollView {
            CatalogExampleGroup(
                title: "Card & Semantic Typography",
                apiNames: ["SFKCard", "SFKTypography"]
            ) {
                SFKCard(icon: "sparkles", iconTint: .purple) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("A focused starting point")
                            .sfkFlowCardTitleStyle()
                        Text("Cards and semantic typography keep reusable surfaces visually consistent.")
                            .sfkFlowCardBodyStyle()
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Cards & Typography")
    }
}

#Preview {
    NavigationStack {
        CardAndTypographyExamplesView()
    }
}
