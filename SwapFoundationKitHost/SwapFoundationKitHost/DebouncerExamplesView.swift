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


