import SwiftUI
import SwapFoundationKit

/// Examples for `UIApplication+` helpers.
struct UIApplicationHelpersExamplesView: View {
    @State private var topVCDescription: String = ""

    var body: some View {
        List {
            Section("Top View Controller") {
                Button("Get Top VC") {
                    if let vc = UIApplication.topViewController() {
                        topVCDescription = String(describing: type(of: vc))
                    } else {
                        topVCDescription = "nil"
                    }
                }
                LabeledContent("Result", value: topVCDescription)
            }
            Section("Safe Area Insets") {
                LabeledContent("Top", value: String(describing: UIApplication.shared.topSafeAreaInset))
                LabeledContent("Bottom", value: String(describing: UIApplication.shared.bottomSafeAreaInset))
            }
        }
        .navigationTitle("UIApplication Helpers")
    }
}


