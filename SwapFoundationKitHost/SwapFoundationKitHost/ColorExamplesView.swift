/*****************************************************************************
 * ColorExamplesView.swift
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

/// Examples for `UIColor+` and SwiftUI interop.
struct ColorExamplesView: View {
    @State private var isShowingColorPicker = false

    private let color = UIColor(hex: "#FF5733") ?? .systemOrange

    var body: some View {
        List {
            Section("Hex") {
                LabeledContent("hex", value: color.hex)
                LabeledContent("hexString(includeAlpha:)", value: color.hexString(includeAlpha: true))
            }
            Section("Derived") {
                ColorRow(title: "Original", color: Color(color))
                ColorRow(title: "Contrasting", color: Color(color.contrastingColor))
                ColorRow(title: "Saturation +0.2", color: Color(color.adjusted(by: .saturation(0.2))))
                ColorRow(title: "Brightness -0.2", color: Color(color.adjusted(by: .brightness(-0.2))))
            }
            Section("Picker") {
                Button("Show Color Picker") {
                    isShowingColorPicker = true
                }
            }
        }
        .navigationTitle("Color / UIColor")
        .sheet(isPresented: $isShowingColorPicker) {
            SFKColorPickerSheet(
                selectedColor: .red,
                promptTitle: "Choose an example color",
                promptMessage: "Pick a preset or open the color wheel."
            )
            .presentationDetents([.fraction(0.7)])
        }
    }

    private func ColorRow(title: String, color: Color) -> some View {
        HStack { Text(title); Spacer(); Rectangle().fill(color).frame(width: 80, height: 24).cornerRadius(6) }
    }
}
