import UIKit

@MainActor
public protocol Coordinator: AnyObject {
    @MainActor var navigationController: UINavigationController { get set }
    @MainActor func start()
}

@MainActor public extension Coordinator {
    /// Pushes a view controller onto the navigation stack.
    func push(_ viewController: UIViewController, animated: Bool = true) {
        navigationController.pushViewController(viewController, animated: animated)
    }

    /// Pops the top view controller from the navigation stack.
    @discardableResult
    func pop(animated: Bool = true) -> UIViewController? {
        return navigationController.popViewController(animated: animated)
    }

    /// Presents a view controller modally from the top-most view controller.
    func present(_ viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        topViewController?.present(viewController, animated: animated, completion: completion)
    }

    /// Dismisses the top-most presented view controller.
    func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
        topViewController?.dismiss(animated: animated, completion: completion)
    }

    /// Sets the root view controller of the navigation stack.
    func setRoot(_ viewController: UIViewController, animated: Bool = true) {
        navigationController.setViewControllers([viewController], animated: animated)
    }

    /// Returns the top-most view controller in the navigation stack.
    var topViewController: UIViewController? {
        navigationController.topViewController
    }
}

