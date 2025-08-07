import Foundation

#if canImport(UIKit) && os(iOS)
import UIKit
#endif

/// A protocol for coordinating navigation and view controller management.
/// This is commonly used in MVVM or Coordinator pattern architectures.
public protocol Coordinator: AnyObject {
    #if canImport(UIKit) && os(iOS)
    /// The navigation controller used for navigation.
    @MainActor var navigationController: UINavigationController { get set }
    #endif
    
    /// Starts the coordinator's flow.
    func start()
}

#if canImport(UIKit) && os(iOS)
@MainActor
public extension Coordinator {
    /// Pushes a view controller onto the navigation stack.
    /// - Parameters:
    ///   - viewController: The view controller to push.
    ///   - animated: Whether the transition should be animated.
    func push(_ viewController: UIViewController, animated: Bool = true) {
        navigationController.pushViewController(viewController, animated: animated)
    }
    
    /// Pops the top view controller from the navigation stack.
    /// - Parameter animated: Whether the transition should be animated.
    /// - Returns: The popped view controller, if any.
    func pop(animated: Bool = true) -> UIViewController? {
        return navigationController.popViewController(animated: animated)
    }
    
    /// Presents a view controller modally.
    /// - Parameters:
    ///   - viewController: The view controller to present.
    ///   - animated: Whether the transition should be animated.
    ///   - completion: A closure to execute after the presentation completes.
    func present(_ viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        navigationController.present(viewController, animated: animated, completion: completion)
    }
    
    /// Sets the root view controller of the navigation controller.
    /// - Parameters:
    ///   - viewController: The view controller to set as root.
    ///   - animated: Whether the transition should be animated.
    func setRoot(_ viewController: UIViewController, animated: Bool = true) {
        navigationController.setViewControllers([viewController], animated: animated)
    }
    
    /// The top view controller in the navigation stack.
    var topViewController: UIViewController? {
        return navigationController.topViewController
    }
}
#endif

