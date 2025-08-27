import SwiftUI
import SwapFoundationKit

/// Examples for `AnalyticsManager` usage.
struct AnalyticsExamplesView: View {
    @State private var sent: [String] = []

    var body: some View {
        List {
            Section("Setup") {
                Button("Add Test Logger") {
                    let testLogger = TestLogger { event, parameters in
                        DispatchQueue.main.async {
                            let paramsString = parameters?.description ?? "nil"
                            sent.append("\(event.rawValue): \(paramsString)")
                        }
                    }
                    AnalyticsManager.shared.addLogger(testLogger)
                }
                Button("Log appLaunched") {
                    AnalyticsManager.shared.logEvent(event: AppEvent.appLaunched)
                }
                Button("Log Custom Event") {
                    let customEvent = DefaultAnalyticsEvent(
                        name: "custom_event",
                        parameters: ["user_id": "123", "action": "button_tap"]
                    )
                    AnalyticsManager.shared.logEvent(event: customEvent)
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
    
    var rawValue: String {
        switch self {
        case .appLaunched:
            return "app_launched"
        }
    }
    
    var name: String { rawValue }
}

private final class TestLogger: AnalyticsLogger {
    private let callback: (AnalyticsEvent, [String: String]?) -> Void

    init(callback: @escaping (AnalyticsEvent, [String: String]?) -> Void) {
        self.callback = callback
    }

    func logEvent(event: AnalyticsEvent, parameters: [String: String]?) {
        callback(event, parameters)
    }
}


