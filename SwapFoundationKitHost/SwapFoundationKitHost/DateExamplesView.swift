import SwiftUI
import SwapFoundationKit

/// Examples for `Date+` utilities in SwapFoundationKit.
struct DateExamplesView: View {
    private let now = Date()

    var body: some View {
        List {
            Section("Formats") {
                LabeledContent("ISO8601", value: now.iso8601String)
                LabeledContent("Short", value: now.shortDate)
                LabeledContent("Medium", value: now.mediumDate)
                LabeledContent("Long", value: now.longDate)
                LabeledContent("Time", value: now.timeOnly)
                LabeledContent("yyyy-MM-dd", value: now.yyyyMMdd)
                LabeledContent("MMM dd, yyyy", value: now.MMMddyyyy)
            }
            Section("Custom format") {
                LabeledContent("EEE, MMM d @ h:mm a", value: now.string(format: "EEE, MMM d @ h:mm a"))
            }
        }
        .navigationTitle("Date")
    }
}


