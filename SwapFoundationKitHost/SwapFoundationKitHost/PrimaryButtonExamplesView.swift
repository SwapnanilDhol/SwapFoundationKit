/*****************************************************************************
 * PrimaryButtonExamplesView.swift
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

struct PrimaryButtonExamplesView: View {
    @State private var isEnabled = true
    @State private var isLoading = false

    var body: some View {
        List {
            Section("Live Preview") {
                SFKButton(
                    "Continue",
                    leadingIconName: "arrow.right",
                    isLoading: isLoading,
                    color: .blue
                ) {}
                .disabled(!isEnabled)
                .padding(.vertical, 6)
            }

            Section("State") {
                Toggle("Enabled", isOn: $isEnabled)
                Toggle("Loading", isOn: $isLoading)
            }

            Section {
                Text("SFKButton")
                    .font(.body.monospaced())
            } footer: {
                Text("Prominent glass is the default. Override the tint when product meaning requires success, warning, or destructive color.")
            }
        }
        .navigationTitle("Primary Button")
    }
}

#Preview {
    NavigationStack {
        PrimaryButtonExamplesView()
    }
}
