import SwiftUI
import SwapFoundationKit

/// Examples for `String+` utilities in SwapFoundationKit.
struct StringExamplesView: View {
    private let sample = "  Hello World  \n"

    var body: some View {
        List {
            Section("Basics") {
                LabeledContent("Original", value: sample)
                LabeledContent("isBlank", value: sample.isBlank.description)
                LabeledContent("isNumeric", value: "123.4".isNumeric.description)
                LabeledContent("isAlphanumeric", value: "A1B2".isAlphanumeric.description)
                LabeledContent("trimmed", value: sample.trimmed)
                LabeledContent("removingWhitespaces", value: sample.removingWhitespaces)
                LabeledContent("reversedString", value: sample.reversedString)
                LabeledContent("wordCount", value: String(sample.wordCount))
            }
            Section("Conversion") {
                LabeledContent("toInt", value: String("42".toInt ?? -1))
                LabeledContent("toDouble", value: String("3.14".toDouble ?? -1))
            }
        }
        .navigationTitle("String")
    }
}


