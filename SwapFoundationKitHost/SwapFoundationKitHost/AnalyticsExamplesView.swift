import SwiftUI
import SwapFoundationKit

/// Examples for `AnalyticsManager` usage.
struct AnalyticsExamplesView: View {
    @State private var sent: [String] = []

    var body: some View {
        List {
            Section("Setup") {
                Button("Add Test Logger") {
                    let loggerForAppEvent = TestLogger<AppEvent> { event, parameters in
                        DispatchQueue.main.async {
                            let paramsString = parameters?.description ?? "nil"
                            sent.append("\(event.rawValue): \(paramsString)")
                        }
                    }
                    let loggerForDefault = TestLogger<DefaultAnalyticsEvent> { event, parameters in
                        DispatchQueue.main.async {
                            let paramsString = parameters?.description ?? "nil"
                            sent.append("\(event.rawValue): \(paramsString)")
                        }
                    }
                    AnalyticsManager.shared.addLogger(loggerForAppEvent)
                    AnalyticsManager.shared.addLogger(loggerForDefault)
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

private final class TestLogger<E: AnalyticsEvent>: AnalyticsLogger {
    typealias T = E
    private let callback: (E, [String: String]?) -> Void

    init(callback: @escaping (E, [String: String]?) -> Void) {
        self.callback = callback
    }

    func logEvent(event: E, parameters: [String: String]?) {
        callback(event, parameters)
    }
}


