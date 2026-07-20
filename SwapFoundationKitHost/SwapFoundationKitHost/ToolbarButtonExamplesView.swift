/*****************************************************************************
 * ToolbarButtonExamplesView.swift
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

struct ToolbarButtonExamplesView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            Section("Rendered in This Toolbar") {
                Label("Close", systemImage: "xmark")
                Label("More actions", systemImage: "ellipsis")
            }

            Section("Included APIs") {
                Text("SFKButton(style: .toolbar)")
                    .font(.body.monospaced())
                Text("SFKCloseButton")
                    .font(.body.monospaced())
            }

            Section {
                Text("Toolbar controls intentionally provide only their icon label. The navigation bar owns sizing, hit testing, and Liquid Glass chrome.")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Toolbar Buttons")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                SFKCloseButton {
                    dismiss()
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                SFKButton(
                    leadingIconName: "ellipsis",
                    fullWidth: false,
                    style: .toolbar
                ) {}
                .accessibilityLabel("More actions")
            }
        }
    }
}

#Preview {
    NavigationStack {
        ToolbarButtonExamplesView()
    }
}
