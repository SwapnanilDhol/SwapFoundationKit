import SwiftUI
import SwapFoundationKit

/// Examples for `UIColor+` and SwiftUI interop.
struct ColorExamplesView: View {
    private let color = UIColor(hex: "#FF5733")

    var body: some View {
        List {
            Section("Hex") {
                LabeledContent("hex()", value: color.hex())
                LabeledContent("hex(includeAlpha:)", value: color.hex(includeAlpha: true))
            }
            Section("Derived") {
                ColorRow(title: "Original", color: Color(color))
                ColorRow(title: "Contrasting", color: Color(color.contrastingColor))
                ColorRow(title: "Saturation +0.2", color: Color(color.adjusted(saturation: 0.2)))
                ColorRow(title: "Brightness -0.2", color: Color(color.adjusted(brightness: -0.2)))
            }
        }
        .navigationTitle("Color / UIColor")
    }

    private func ColorRow(title: String, color: Color) -> some View {
        HStack { Text(title); Spacer(); Rectangle().fill(color).frame(width: 80, height: 24).cornerRadius(6) }
    }
}


