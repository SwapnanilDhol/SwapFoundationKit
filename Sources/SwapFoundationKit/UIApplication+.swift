import Foundation

#if canImport(UIKit) && os(iOS)
import UIKit
#endif

#if canImport(UIKit) && os(iOS)
public extension UIApplication {
    /// Returns the top-most view controller in the application.
    /// - Parameter rootViewController: The root view controller to start from. If nil, uses the first connected scene's root view controller.
    /// - Returns: The top-most view controller, or nil if not found.
    static func topViewController(from rootViewController: UIViewController? = UIApplication.shared.connectedScenes
        .compactMap { ($0 as? UIWindowScene)?.keyWindow }
        .first?.rootViewController) -> UIViewController? {
        
        guard let rootViewController = rootViewController else { return nil }
        
        if let presentedViewController = rootViewController.presentedViewController {
            return topViewController(from: presentedViewController)
        }
        
        if let navigationController = rootViewController as? UINavigationController {
            return topViewController(from: navigationController.visibleViewController)
        }
        
        if let tabBarController = rootViewController as? UITabBarController {
            return topViewController(from: tabBarController.selectedViewController)
        }
        
        return rootViewController
    }
}
#endif 
