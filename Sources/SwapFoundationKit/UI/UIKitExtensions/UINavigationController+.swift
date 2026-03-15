import Foundation

#if canImport(UIKit) && canImport(SwiftUI) && os(iOS)
import SwiftUI
import UIKit

@MainActor
public extension UINavigationController {
    func presentView<Content: View>(view: Content) {
        let controller = UIHostingController(rootView: view)
        present(controller, animated: true)
    }

    func pushView<Content: View>(view: Content) {
        let controller = UIHostingController(rootView: view)
        pushViewController(controller, animated: true)
    }
}
#endif
