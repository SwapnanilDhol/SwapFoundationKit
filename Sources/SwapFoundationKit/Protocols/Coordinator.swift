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
        subtitle: String = "",
        selectionType: SFKItemPickerSelectionMode = .single,
        initialSelection: [any SFKPickableItem] = [],
        delegate: SFKItemPickerDelegate? = nil,
        selectsItems: Bool = true,
        autoDismissOnSingleSelection: Bool = true,
        showsCloseButton: Bool = true,
        toolbarActions: [SFKItemPickerToolbarAction] = [],
        onSelect: ((any SFKPickableItem) -> Void)? = nil,
        onDismiss: ((SFKItemPickerViewModel) -> Void)? = nil,
        actionsProvider: ((any SFKPickableItem) -> [SFKItemPickerItemAction])? = nil
    ) {
        presentItemPicker(
            title: title,
            sections: [SFKItemPickerSection(items: items)],
            subtitle: subtitle,
            selectionType: selectionType,
            initialSelection: initialSelection,
            delegate: delegate,
            selectsItems: selectsItems,
            autoDismissOnSingleSelection: autoDismissOnSingleSelection,
            showsCloseButton: showsCloseButton,
            toolbarActions: toolbarActions,
            onSelect: onSelect,
            onDismiss: onDismiss,
            actionsProvider: actionsProvider
        )
    }

    /// Presents a sectioned ``SFKItemPickerView`` as a modal sheet.
    /// - Parameters:
    ///   - title: The picker screen title.
    ///   - sections: The sections and items to choose from.
    ///   - subtitle: Optional subtitle shown beneath the navigation title.
    ///   - selectionType: `.single` or `.multi` selection mode.
    ///   - initialSelection: Pre-selected items.
    ///   - delegate: Optional delegate for selection callbacks.
    ///   - selectsItems: Whether taps update picker selection state.
    ///   - autoDismissOnSingleSelection: Whether single-select taps dismiss automatically.
    ///   - showsCloseButton: Whether the picker renders the standard close button.
    ///   - toolbarActions: Optional navigation bar actions rendered by the picker.
    ///   - onSelect: Closure called when an item is tapped.
    ///   - onDismiss: Closure called before the picker dismisses.
    ///   - actionsProvider: Optional per-row action provider.
    func presentItemPicker(
        title: String,
        sections: [SFKItemPickerSection],
        subtitle: String = "",
        selectionType: SFKItemPickerSelectionMode = .single,
        initialSelection: [any SFKPickableItem] = [],
        delegate: SFKItemPickerDelegate? = nil,
        selectsItems: Bool = true,
        autoDismissOnSingleSelection: Bool = true,
        showsCloseButton: Bool = true,
        toolbarActions: [SFKItemPickerToolbarAction] = [],
        onSelect: ((any SFKPickableItem) -> Void)? = nil,
        onDismiss: ((SFKItemPickerViewModel) -> Void)? = nil,
        actionsProvider: ((any SFKPickableItem) -> [SFKItemPickerItemAction])? = nil
    ) {
        let viewModel = SFKItemPickerViewModel(
            sections: sections,
            selectionType: selectionType,
            initialSelection: initialSelection
        )
        viewModel.delegate = delegate
        presentItemPicker(
            title: title,
            subtitle: subtitle,
            viewModel: viewModel,
            selectsItems: selectsItems,
            autoDismissOnSingleSelection: autoDismissOnSingleSelection,
            showsCloseButton: showsCloseButton,
            toolbarActions: toolbarActions,
            onSelect: onSelect,
            onDismiss: onDismiss,
            actionsProvider: actionsProvider
        )
    }

    /// Presents a ``SFKItemPickerView`` using an existing picker view model.
    /// Use this when the host screen owns live picker state, reloads sections, or needs to update rows after model changes.
    /// - Parameters:
    ///   - title: The picker screen title.
    ///   - subtitle: Optional subtitle shown beneath the navigation title.
    ///   - viewModel: Existing picker view model to render.
    ///   - selectsItems: Whether taps update picker selection state.
    ///   - autoDismissOnSingleSelection: Whether single-select taps dismiss automatically.
    ///   - showsCloseButton: Whether the picker renders the standard close button.
    ///   - toolbarActions: Optional navigation bar actions rendered by the picker.
    ///   - onSelect: Closure called when an item is tapped.
    ///   - onDismiss: Closure called before the picker dismisses.
    ///   - actionsProvider: Optional per-row action provider.
    func presentItemPicker(
        title: String,
        subtitle: String = "",
        viewModel: SFKItemPickerViewModel,
        selectsItems: Bool = true,
        autoDismissOnSingleSelection: Bool = true,
        showsCloseButton: Bool = true,
        toolbarActions: [SFKItemPickerToolbarAction] = [],
        onSelect: ((any SFKPickableItem) -> Void)? = nil,
        onDismiss: ((SFKItemPickerViewModel) -> Void)? = nil,
        actionsProvider: ((any SFKPickableItem) -> [SFKItemPickerItemAction])? = nil
    ) {
        let view = SFKItemPickerView(
            pageTitle: title,
            pageSubtitle: subtitle,
            viewModel: viewModel,
            selectsItems: selectsItems,
            autoDismissOnSingleSelection: autoDismissOnSingleSelection,
            showsCloseButton: showsCloseButton,
            toolbarActions: toolbarActions,
            onSelect: onSelect,
            onDismiss: {
                onDismiss?(viewModel)
                self.dismiss()
            },
            actionsProvider: actionsProvider
        )
        let controller = UIHostingController(rootView: view)
        if let sheet = controller.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.selectedDetentIdentifier = .medium
        }
        presentOnTop(controller)
    }
}
#endif
