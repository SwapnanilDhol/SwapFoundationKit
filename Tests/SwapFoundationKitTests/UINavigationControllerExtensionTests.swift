#if canImport(UIKit) && canImport(SwiftUI) && os(iOS)
import SwiftUI
import Testing
import UIKit
@testable import SwapFoundationKit

@MainActor
struct UINavigationControllerExtensionTests {
    @Test
    func pushViewPushesAHostingController() {
        let navigationController = UINavigationController()

        navigationController.pushView(view: Text("Detail"))

        #expect(navigationController.viewControllers.count == 1)
        #expect(navigationController.topViewController is UIHostingController<Text>)
    }

    @Test
    func presentViewPresentsAHostingController() {
        let navigationController = UINavigationController()
        let window = UIWindow(frame: UIScreen.main.bounds)

        window.rootViewController = navigationController
        window.makeKeyAndVisible()

        navigationController.presentView(view: Text("Modal"))

        #expect(navigationController.presentedViewController is UIHostingController<Text>)
    }
}
#endif
