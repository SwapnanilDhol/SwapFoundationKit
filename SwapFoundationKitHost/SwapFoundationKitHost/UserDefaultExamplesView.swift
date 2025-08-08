import SwiftUI
import SwapFoundationKit

/// Examples for `UserDefault` property wrapper in SwapFoundationKit.
struct UserDefaultExamplesView: View {
    enum Keys: String, UserDefaultKeyProtocol { case username; var keyString: String { rawValue } }

    @UserDefault(Keys.username, default: "Guest") private var username

    var body: some View {
        List {
            Section("Username") {
                TextField("Username", text: $username)
                    .textFieldStyle(.roundedBorder)
                Text("Stored value: \(username)")
            }
        }
        .navigationTitle("UserDefault")
    }
}


