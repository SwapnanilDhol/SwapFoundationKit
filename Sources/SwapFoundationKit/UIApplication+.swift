#if canImport(UIKit)
import UIKit

@available(iOS 15, *)
public extension UIApplication {
    /// Returns the top-most view controller from the given root view controller, or from the key window's root if none is provided.
    static func topViewController(from rootViewController: UIViewController? = UIApplication.shared.connectedScenes
        .compactMap { ($0 as? UIWindowScene)?.keyWindow }
        .first?.rootViewController) -> UIViewController? {
        guard let root = rootViewController else { return nil }
        if let nav = root as? UINavigationController {
            return topViewController(from: nav.visibleViewController)
        }
        if let tab = root as? UITabBarController, let selected = tab.selectedViewController {
            return topViewController(from: selected)
        }
        if let presented = root.presentedViewController {
            return topViewController(from: presented)
        }
        return root
    }
}
#endif 
