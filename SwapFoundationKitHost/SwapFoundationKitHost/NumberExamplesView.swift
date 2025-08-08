import SwiftUI
import SwapFoundationKit

/// Examples for `Number+` utilities in SwapFoundationKit.
struct NumberExamplesView: View {
    var body: some View {
        List {
            Section("Double") {
                LabeledContent("1234.56.clean", value: 1234.56.clean)
                LabeledContent("123.wordRepresentation", value: 123.0.wordRepresentation ?? "-")
            }
            Section("Float") {
                LabeledContent("12.0.clean", value: Float(12.0).clean)
            }
        }
        .navigationTitle("Number")
    }
}


