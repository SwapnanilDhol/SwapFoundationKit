/*****************************************************************************
 * AppearanceExamplesView.swift
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

struct AppearanceExamplesView: View {
    var body: some View {
        List {
            Section("Rounded Type Specimen") {
                typographyRow("Large Title", font: .largeTitle)
                typographyRow("Title", font: .title)
                typographyRow("Headline", font: .headline)
                typographyRow("Body", font: .body)
                typographyRow("Caption", font: .caption)
            }

            Section("Included APIs") {
                Label("Configures UIKit navigation and controls", systemImage: "textformat")
                Text("SFKAppearanceManager").font(.body.monospaced())
                Text("SFKRoundedHostingController").font(.body.monospaced())
                Text("UIFont.roundedSystemFont").font(.body.monospaced())
            }
        }
        .navigationTitle("Appearance")
    }

    private func typographyRow(_ title: String, font: Font) -> some View {
        Text(title)
            .font(font)
            .fontDesign(.rounded)
    }
}

#Preview {
    NavigationStack {
        AppearanceExamplesView()
    }
}
