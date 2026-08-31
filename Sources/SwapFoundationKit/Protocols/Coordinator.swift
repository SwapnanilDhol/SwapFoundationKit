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
    @MainActor func start()
}

#if canImport(UIKit) && os(iOS)
@MainActor
public extension Coordinator {
    /// Presents a typed, single-select item picker.
    ///
    /// The binding and closure retain the concrete item type, avoiding casts at
    /// the coordinator boundary. Prefer presenting the picker directly from a
    /// SwiftUI view when that is practical.
    func presentItemPicker<Item: SFKPickableItem>(
        title: String,
        items: [Item],
        selection: Binding<Item?>,
        subtitle: String = "",
        onSelect: ((Item) -> Void)? = nil,
        actionsProvider: ((Item) -> [SFKItemPickerItemAction])? = nil,
        toolbarActions: [SFKItemPickerToolbarAction] = [],
        emptyState: SFKItemPickerEmptyState? = nil
    ) {
        var configuration = SFKItemPickerConfiguration(
            pageSubtitle: subtitle,
            actionsProvider: actionsProvider
        )
        configuration.toolbarActions = toolbarActions
        configuration.emptyState = emptyState
        let view = SFKItemPickerView(
            pageTitle: title,
            items: items,
            selection: selection,
            configuration: configuration,
            onSelect: onSelect
        )
        presentOnTop(UIHostingController(rootView: view))
    }

    /// Presents a typed picker for a non-optional single selection.
    func presentItemPicker<Item: SFKPickableItem>(
        title: String,
        items: [Item],
        selection: Binding<Item>,
        subtitle: String = "",
        onSelect: ((Item) -> Void)? = nil,
        actionsProvider: ((Item) -> [SFKItemPickerItemAction])? = nil,
        toolbarActions: [SFKItemPickerToolbarAction] = [],
        emptyState: SFKItemPickerEmptyState? = nil
    ) {
        var configuration = SFKItemPickerConfiguration(
            pageSubtitle: subtitle,
            actionsProvider: actionsProvider
        )
        configuration.toolbarActions = toolbarActions
        configuration.emptyState = emptyState
        let view = SFKItemPickerView(
            pageTitle: title,
            items: items,
            selection: selection,
            configuration: configuration,
            onSelect: onSelect
        )
        presentOnTop(UIHostingController(rootView: view))
    }

    /// Presents a typed, multi-select item picker.
    func presentItemPicker<Item: SFKPickableItem>(
        title: String,
        items: [Item],
        selections: Binding<Set<Item>>,
        subtitle: String = "",
        onSelect: ((Item) -> Void)? = nil,
        actionsProvider: ((Item) -> [SFKItemPickerItemAction])? = nil,
        toolbarActions: [SFKItemPickerToolbarAction] = [],
        emptyState: SFKItemPickerEmptyState? = nil
    ) {
        var configuration = SFKItemPickerConfiguration(
            pageSubtitle: subtitle,
            actionsProvider: actionsProvider
        )
        configuration.toolbarActions = toolbarActions
        configuration.emptyState = emptyState
        let view = SFKItemPickerView(
            pageTitle: title,
            items: items,
            selections: selections,
            configuration: configuration,
            onSelect: onSelect
        )
        presentOnTop(UIHostingController(rootView: view))
    }

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

    /// Presents a view controller from the currently visible top controller, falling back to the coordinator's navigation controller.
    /// - Parameters:
    ///   - viewController: The view controller to present.
    ///   - animated: Whether the transition should be animated.
    ///   - completion: A closure to execute after the presentation completes.
    func presentOnTop(_ viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        if let topController = UIApplication.topViewController() {
            topController.present(viewController, animated: animated, completion: completion)
        } else {
            navigationController.present(viewController, animated: animated, completion: completion)
        }
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
        if let topController = UIApplication.topViewController() {
            topController.dismiss(animated: animated)
        } else {
            navigationController.dismiss(animated: animated)
        }
    }

}
#endif
