import SwiftUI
import SwapFoundationKit

/// Examples for `AnalyticsManager` usage.
struct AnalyticsExamplesView: View {
    @State private var sent: [String] = []

    var body: some View {
        List {
            Section("Setup") {
                Button("Configure sender closure") {
                    Task { @MainActor in
                        await AnalyticsManager.shared.setSendTelemetry { event, payload in
                            DispatchQueue.main.async {
                                sent.append("\(event.name): \(payload.dictionary)")
                            }
                        }
                    }
                }
                Button("Log appLaunched") {
                    Task { await AnalyticsManager.shared.logEvent(AppEvent.appLaunched) }
                }
                Button("Flush") {
                    Task { await AnalyticsManager.shared.flush() }
                }
            }
            Section("Sent Events") {
                ForEach(sent, id: \.self) { Text($0).lineLimit(3) }
            }
        }
        .navigationTitle("Analytics")
    }
}

private enum AppEvent: AnalyticsEvent {
    case appLaunched
    var name: String { "app_launched" }
    var parameters: [String : any Sendable] { [:] }
}


