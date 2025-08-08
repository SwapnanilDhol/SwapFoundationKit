import SwiftUI
import SwapFoundationKit

/// Examples for `Logger` usage.
struct LoggerExamplesView: View {
    var body: some View {
        List {
            Button("Log Info") { Logger.info("Hello from Logger") }
            Button("Log Debug") { Logger.debug("Debug line") }
            Button("Log Warning") { Logger.warning("Watch out!") }
            Button("Log Error") { Logger.error("Something failed") }
        }
        .navigationTitle("Logger")
    }
}


