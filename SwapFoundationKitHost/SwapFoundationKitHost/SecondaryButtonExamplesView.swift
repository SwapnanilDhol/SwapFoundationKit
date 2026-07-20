/*****************************************************************************
 * SecondaryButtonExamplesView.swift
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

struct SecondaryButtonExamplesView: View {
    @State private var isEnabled = true

    var body: some View {
        List {
            Section("Live Preview") {
                SFKButton(
                    "Review Details",
                    leadingIconName: "doc.text",
                    fullWidth: false,
                    color: .primary.opacity(0.08),
                    style: .secondary
                ) {}
                .disabled(!isEnabled)
                .padding(.vertical, 6)
            }

            Section("State") {
                Toggle("Enabled", isOn: $isEnabled)
            }

            Section {
                Text("SFKButton(style: .secondary)")
                    .font(.body.monospaced())
            } footer: {
                Text("Secondary actions use regular glass and semantic foreground colors, so they remain legible in light and dark appearances.")
            }
        }
        .navigationTitle("Secondary Button")
    }
}

#Preview {
    NavigationStack {
        SecondaryButtonExamplesView()
    }
}
