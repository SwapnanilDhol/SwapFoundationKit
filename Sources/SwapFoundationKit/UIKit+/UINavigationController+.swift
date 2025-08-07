import Foundation

#if canImport(UIKit) && os(iOS)
import UIKit
#endif

#if canImport(UIKit) && os(iOS)
@MainActor
public extension UINavigationController {
    /// Pops to the root view controller with optional animation.
    /// - Parameter animated: Whether the transition should be animated.
    /// - Returns: An array of the popped view controllers.
    @discardableResult
    func popToRootViewController(animated: Bool = true) -> [UIViewController]? {
        return popToRootViewController(animated: animated)
    }
    
    /// Pops to a specific view controller with optional animation.
    /// - Parameters:
    ///   - viewController: The view controller to pop to.
    ///   - animated: Whether the transition should be animated.
    /// - Returns: An array of the popped view controllers.
    @discardableResult
    func popToViewController(_ viewController: UIViewController, animated: Bool = true) -> [UIViewController]? {
        return popToViewController(viewController, animated: animated)
    }
    
    /// Pops the top view controller with optional animation.
    /// - Parameter animated: Whether the transition should be animated.
    /// - Returns: The popped view controller.
    @discardableResult
    func popViewController(animated: Bool = true) -> UIViewController? {
        return popViewController(animated: animated)
    }
    
    /// Pushes a view controller with optional animation.
    /// - Parameters:
    ///   - viewController: The view controller to push.
    ///   - animated: Whether the transition should be animated.
    func pushViewController(_ viewController: UIViewController, animated: Bool = true) {
        pushViewController(viewController, animated: animated)
    }
    
    /// Sets the view controllers with optional animation.
    /// - Parameters:
    ///   - viewControllers: The array of view controllers to set.
    ///   - animated: Whether the transition should be animated.
    func setViewControllers(_ viewControllers: [UIViewController], animated: Bool = true) {
        setViewControllers(viewControllers, animated: animated)
    }
}
#endif
