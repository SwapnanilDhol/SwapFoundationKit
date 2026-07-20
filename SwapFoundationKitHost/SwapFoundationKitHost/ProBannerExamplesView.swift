/*****************************************************************************
 * ProBannerExamplesView.swift
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

struct ProBannerExamplesView: View {
    @State private var isProEnabled = false

    var body: some View {
        List {
            Section {
                Toggle("Pro enabled", isOn: $isProEnabled)
            } footer: {
                Text("Toggle the entitlement to inspect both component states.")
            }

            Section("Live Component") {
                SFKProBannerView(
                    isProEnabled: isProEnabled,
                    proEnabledTitle: "Thanks for supporting the app",
                    proEnabledSubtitle: "Every premium feature is available.",
                    proDisabledTitle: "Unlock the complete experience",
                    proDisabledSubtitle: "Upgrade once to access every premium feature.",
                    upgradeButtonFillColor: .purple
                ) {
                    isProEnabled = true
                }
                .listRowInsets(EdgeInsets())
            }
        }
        .navigationTitle("Pro Banner")
    }
}

#Preview {
    NavigationStack {
        ProBannerExamplesView()
    }
}
