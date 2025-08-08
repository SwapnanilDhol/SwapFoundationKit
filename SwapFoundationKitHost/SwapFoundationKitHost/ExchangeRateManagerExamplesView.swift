import SwiftUI
import SwapFoundationKit

/// Examples for `ExchangeRateManager`.
struct ExchangeRateManagerExamplesView: View {
    @State private var eurToUsd: Double = 0
    @State private var status: String = "Loading cached/fallback..."

    var body: some View {
        List {
            Section("Rates") {
                LabeledContent("EUR -> USD", value: String(format: "%.3f", eurToUsd))
                Text(status).font(.footnote).foregroundStyle(.secondary)
            }
            Section("Actions") {
                Button("Start (load cache & fetch)") {
                    Task {
                        await ExchangeRateManager.shared.start()
                        let converted = await ExchangeRateManager.shared.convert(value: 1.0, fromCurrency: .EUR, toCurrency: .USD)
                        await MainActor.run {
                            eurToUsd = converted
                            status = "Loaded"
                        }
                    }
                }
            }
        }
        .navigationTitle("Exchange Rates")
    }
}


