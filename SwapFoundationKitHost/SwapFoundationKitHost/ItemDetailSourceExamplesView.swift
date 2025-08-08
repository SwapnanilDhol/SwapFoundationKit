import SwiftUI
import SwapFoundationKit

/// Examples for `ItemDetailSource` usage with share sheets.
struct ItemDetailSourceExamplesView: View {
    @State private var isSharing: Bool = false

    var body: some View {
        List {
            Section("Share Text") {
                Button("Present Share Sheet") { isSharing = true }
                    .sheet(isPresented: $isSharing) {
                        ShareSheet(items: [ShareItem(title: "Hello", subtitle: "World", url: URL(string: "https://example.com"), imageData: nil, text: "Hello from SwapFoundationKit!")])
                    }
            }
        }
        .navigationTitle("Item Sharing")
    }
}

private struct ShareItem: ItemDetailSource {
    let title: String
    let subtitle: String?
    let url: URL?
    let imageData: Data?
    let text: String
}

private struct ShareSheet: UIViewControllerRepresentable {
    let items: [ItemDetailSource]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}


