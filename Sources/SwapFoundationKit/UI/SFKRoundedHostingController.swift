#if canImport(SwiftUI)
import SwiftUI

/// A `UIHostingController` subclass that applies `.fontDesign(.rounded)` to its root view.
///
/// Use this when embedding SwiftUI views in a UIKit app with a rounded typography design.
///
/// ## Usage
/// ```swift
/// let vc = SFKRoundedHostingController(rootView: MySettingsView())
/// navigationController.pushViewController(vc, animated: true)
/// ```
open class SFKRoundedHostingController<Content: View>: UIHostingController<AnyView> {

    public init(rootView: Content) {
        super.init(
            rootView: AnyView(
                rootView
                    .font(.system(.body, design: .rounded))
                    .fontDesign(.rounded)
            )
        )
    }

    @MainActor @objc required dynamic public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
#endif
