/*****************************************************************************
 * DebouncerExamplesView.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI
import SwapFoundationKit

/// Examples for `Debouncer` in SwapFoundationKit.
struct DebouncerExamplesView: View {
    @State private var text: String = ""
    @State private var debouncedText: String = ""
    private let debouncer = Debouncer(delay: 0.5)

    var body: some View {
        List {
            Section("Type to see debounced output (0.5s)") {
                TextField("Type...", text: $text)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: text) { newValue in
                        debouncer.call {
                            debouncedText = newValue
                        }
                    }
                LabeledContent("Debounced", value: debouncedText)
            }
        }
        .navigationTitle("Debouncer")
    }
}


