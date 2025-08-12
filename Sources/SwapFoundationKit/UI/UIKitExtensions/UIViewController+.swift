import Foundation

#if canImport(UIKit) && os(iOS)
import UIKit
#endif

#if canImport(UIKit) && os(iOS)
@MainActor
public extension UIViewController {    
    /// Adds a child view controller and adds its view as a subview.
    /// - Parameters:
    ///   - child: The child view controller to add.
    ///   - to: The view to add the child's view to. If nil, adds to the current view controller's view.
    func addChild(_ child: UIViewController, to view: UIView? = nil) {
        addChild(child)
        let targetView = view ?? self.view
        targetView?.addSubview(child.view)
        child.didMove(toParent: self)
    }
    
    /// Removes a child view controller.
    /// - Parameter child: The child view controller to remove.
    func removeChild(_ child: UIViewController) {
        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()
    }
    
    /// Returns the top-most presented view controller.
    var topMostViewController: UIViewController {
        if let presented = presentedViewController {
            return presented.topMostViewController
        }
        
        if let navigationController = self as? UINavigationController {
            return navigationController.visibleViewController?.topMostViewController ?? navigationController
        }
        
        if let tabBarController = self as? UITabBarController {
            return tabBarController.selectedViewController?.topMostViewController ?? tabBarController
        }
        
        return self
    }
    
    /// Returns the root view controller of the current view controller hierarchy.
    var rootViewController: UIViewController {
        if let parent = parent {
            return parent.rootViewController
        }
        return self
    }
}
#endif
