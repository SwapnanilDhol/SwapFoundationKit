/*****************************************************************************
 * Coordinator.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import Foundation

#if canImport(UIKit) && os(iOS)
import UIKit
import SwiftUI
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

    /// Dismisses the currently presented view controller.
    /// - Parameter animated: Whether the dismissal should be animated.
    func dismiss(animated: Bool = true) {
        navigationController.dismiss(animated: animated)
    }

    /// Presents a ``SFKItemPickerView`` as a modal sheet.
    /// - Parameters:
    ///   - title: The picker screen title.
    ///   - items: The items to choose from.
    ///   - selectionType: `.single` or `.multi` selection mode.
    ///   - initialSelection: Pre-selected items.
    ///   - delegate: Optional delegate for selection callbacks.
    ///   - onSelect: Closure called when a single item is tapped.
    func presentItemPicker(
        title: String,
        items: [any SFKPickableItem],
        selectionType: SFKItemPickerSelectionMode = .single,
        initialSelection: [any SFKPickableItem] = [],
        delegate: SFKItemPickerDelegate? = nil,
        onSelect: ((any SFKPickableItem) -> Void)? = nil
    ) {
        let viewModel = SFKItemPickerViewModel(
            items: items,
            selectionType: selectionType,
            initialSelection: initialSelection
        )
        viewModel.delegate = delegate
        let view = SFKItemPickerView(
            pageTitle: title,
            viewModel: viewModel,
            onSelect: onSelect,
            onDismiss: {
                UIApplication.topViewController()?.dismiss(animated: true)
            }
        )
        let controller = UIHostingController(rootView: view)
        if let sheet = controller.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.selectedDetentIdentifier = .medium
        }
        navigationController.present(controller, animated: true)
    }
}
#endif

