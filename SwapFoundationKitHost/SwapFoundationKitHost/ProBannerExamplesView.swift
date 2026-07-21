/****************************************************************************
 * ProBannerExamplesView.swift
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

struct ProBannerExamplesView: View {
    @State private var isInspectorPresented = false
    @State private var isProEnabled = false
    @State private var proEnabledTitle = "Thanks for supporting the app"
    @State private var proEnabledSubtitle = "Every premium feature is available."
    @State private var proDisabledTitle = "Unlock the complete experience"
    @State private var proDisabledSubtitle = "Upgrade once to access every premium feature."
    @State private var upgradeButtonTitle = "Upgrade Now"
    @State private var upgradeButtonFillColor = Color.purple

    var body: some View {
        CatalogControlPlayground(
            title: "Pro Banner",
            isInspectorPresented: $isInspectorPresented
        ) {
            CatalogExampleGroup(
                title: "Live Preview",
                apiNames: ["SFKProBannerView"]
            ) {
                SFKProBannerView(
                    isProEnabled: isProEnabled,
                    proEnabledTitle: proEnabledTitle,
                    proEnabledSubtitle: proEnabledSubtitle,
                    proDisabledTitle: proDisabledTitle,
                    proDisabledSubtitle: proDisabledSubtitle,
                    upgradeButtonTitle: upgradeButtonTitle,
                    upgradeButtonFillColor: upgradeButtonFillColor
                ) {
                    isProEnabled = true
                }
                .padding(.vertical, 8)
                .background(.background, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
        } configuration: {
            Form {
                Section("State") {
                    Toggle("Pro enabled", isOn: $isProEnabled)
                }

                Section("Pro Enabled") {
                    TextField("Title", text: $proEnabledTitle)
                    TextField("Subtitle", text: $proEnabledSubtitle, axis: .vertical)
                }

                Section("Pro Disabled") {
                    TextField("Title", text: $proDisabledTitle)
                    TextField("Subtitle", text: $proDisabledSubtitle, axis: .vertical)
                    TextField("Button title", text: $upgradeButtonTitle)
                    ColorPicker("Button color", selection: $upgradeButtonFillColor, supportsOpacity: true)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProBannerExamplesView()
    }
}
