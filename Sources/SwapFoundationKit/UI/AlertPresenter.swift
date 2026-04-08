/*****************************************************************************
 * AlertPresenter.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI

#if canImport(UIKit) && os(iOS)
import UIKit
#endif

// MARK: - Alert Action

/// Represents an action in an alert
public struct AlertAction: Identifiable, Equatable {
    public let id = UUID()
    public let title: String
    public let style: AlertActionStyle
    public let handler: (() -> Void)?

    public init(
        _ title: String,
        style: AlertActionStyle = .default,
        handler: (() -> Void)? = nil
    ) {
        self.title = title
        self.style = style
        self.handler = handler
    }

    public static func == (lhs: AlertAction, rhs: AlertAction) -> Bool {
        lhs.id == rhs.id
    }
}

/// Style for alert actions
public enum AlertActionStyle: Equatable {
    case `default`
    case cancel
    case destructive

    #if canImport(UIKit) && os(iOS)
    var uiStyle: UIAlertAction.Style {
        switch self {
        case .default: return .default
        case .cancel: return .cancel
        case .destructive: return .destructive
        }
    }
    #endif
}

// MARK: - Alert Text Field

/// Represents a text field in an alert
public struct AlertTextField: Identifiable, Equatable {
    public let id = UUID()
    public let placeholder: String?
    public var text: String
    public let keyboardType: KeyboardType?

    public init(
        placeholder: String? = nil,
        text: String = "",
        keyboardType: KeyboardType? = nil
    ) {
        self.placeholder = placeholder
        self.text = text
        self.keyboardType = keyboardType
    }

    public static func == (lhs: AlertTextField, rhs: AlertTextField) -> Bool {
        lhs.id == rhs.id
    }
}

/// Platform-agnostic keyboard type
public enum KeyboardType: Equatable {
    case `default`
    case email
    case number
    case phone
    case url

    #if canImport(UIKit) && os(iOS)
    var uiKeyboardType: UIKeyboardType {
        switch self {
        case .default: return .default
        case .email: return .emailAddress
        case .number: return .numberPad
        case .phone: return .phonePad
        case .url: return .URL
        }
    }
    #endif
}

#if canImport(UIKit) && os(iOS)
extension AlertTextField {
    var uiKeyboardType: UIKeyboardType {
        keyboardType?.uiKeyboardType ?? .default
    }
}
#endif

// MARK: - Alert Configuration

/// Configuration for an alert
public struct AlertConfiguration: Equatable {
    public let id = UUID()
    public var title: String
    public var message: String?
    public var actions: [AlertAction]
    public var textFields: [AlertTextField]
    public var preferredActionIndex: Int?

    public init(
        title: String,
        message: String? = nil,
        actions: [AlertAction] = [],
        textFields: [AlertTextField] = [],
        preferredActionIndex: Int? = nil
    ) {
        self.title = title
        self.message = message
        self.actions = actions
        self.textFields = textFields
        self.preferredActionIndex = preferredActionIndex
    }

    public static func == (lhs: AlertConfiguration, rhs: AlertConfiguration) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - SwiftUI Alert Controller

/// A SwiftUI-native alert controller that can be used with @StateObject/@ObservedObject
/// Provides a declarative way to manage alerts in SwiftUI views
@MainActor
public final class AlertController: ObservableObject {

    /// The current alert configuration (nil when no alert is shown)
    @Published public var configuration: AlertConfiguration?

    /// Whether an alert is currently being shown
    public var isShowing: Bool {
        configuration != nil
    }

    /// Callback invoked when any alert action is triggered
    public var onAction: ((String, [String]) -> Void)?

    public init() {}

    /// Shows an alert with the given configuration
    public func show(_ configuration: AlertConfiguration) {
        self.configuration = configuration
    }

    /// Shows a simple alert with a single action
    public func showAlert(
        title: String,
        message: String? = nil,
        actionTitle: String = "OK",
        actionStyle: AlertActionStyle = .default,
        onDismiss: (() -> Void)? = nil
    ) {
        let config = AlertConfiguration(
            title: title,
            message: message,
            actions: [AlertAction(actionTitle, style: actionStyle) { onDismiss?() }]
        )
        show(config)
    }

    /// Shows a confirmation alert with confirm and cancel actions
    public func showConfirmation(
        title: String,
        message: String? = nil,
        confirmTitle: String = "Confirm",
        confirmStyle: AlertActionStyle = .default,
        cancelTitle: String = "Cancel",
        onConfirm: (() -> Void)? = nil,
        onCancel: (() -> Void)? = nil
    ) {
        let config = AlertConfiguration(
            title: title,
            message: message,
            actions: [
                AlertAction(cancelTitle, style: .cancel) { onCancel?() },
                AlertAction(confirmTitle, style: confirmStyle) { onConfirm?() }
            ],
            preferredActionIndex: 1
        )
        show(config)
    }

    /// Shows an alert with text fields
    public func showTextInput(
        title: String,
        message: String? = nil,
        placeholder: String? = nil,
        prefilledText: String = "",
        confirmTitle: String = "OK",
        cancelTitle: String = "Cancel",
        keyboardType: KeyboardType? = nil,
        onSubmit: ((String) -> Void)? = nil,
        onCancel: (() -> Void)? = nil
    ) {
        let textField = AlertTextField(
            placeholder: placeholder,
            text: prefilledText,
            keyboardType: keyboardType
        )
        let config = AlertConfiguration(
            title: title,
            message: message,
            actions: [
                AlertAction(cancelTitle, style: .cancel) { onCancel?() },
                AlertAction(confirmTitle, style: .default) {
                    // Note: Text field values need to be captured separately
                    onSubmit?(textField.text)
                }
            ],
            textFields: [textField]
        )
        show(config)
    }

    /// Dismisses the current alert
    public func dismiss() {
        configuration = nil
    }

    /// Handles action callback from the alert presentation
    fileprivate func handleAction(title: String, textFieldValues: [String] = []) {
        onAction?(title, textFieldValues)
        dismiss()
    }
}

// MARK: - SwiftUI View Extension

public extension View {
    /// Attaches an AlertController to this view for presentation
    func alert(
        _ controller: AlertController,
        textFieldValues: Binding<[String]>
    ) -> some View {
        self.alert(
            controller.configuration?.title ?? "",
            isPresented: Binding(
                get: { controller.isShowing },
                set: { if !$0 { controller.dismiss() } }
            ),
            presenting: controller.configuration
        ) { config in
            ForEach(Array(config.actions.enumerated()), id: \.element.id) { index, action in
                Button(action.title) {
                    let values = textFieldValues.wrappedValue
                    action.handler?()
                    controller.handleAction(title: action.title, textFieldValues: values)
                }
            }
        } message: { config in
            if let message = config.message {
                Text(message)
            }
        }
    }
}

// MARK: - AlertPresenter (UIKit wrappers)

#if canImport(UIKit) && os(iOS)

/// A SwiftUI-friendly way to present alerts and confirmations using UIKit
public struct AlertPresenter {

    /// Presents an action sheet using UIKit (works from SwiftUI)
    @MainActor
    public static func showActionSheet(
        title: String,
        message: String? = nil,
        actions: [AlertAction],
        sourceView: UIView? = nil,
        sourceRect: CGRect? = nil
    ) {
        let uiActions = actions.map { item in
            UIAlertAction(title: item.title, style: item.style.uiStyle) { _ in item.handler?() }
        }
        UIApplication.shared.presentActionSheet(
            title: title,
            message: message,
            actions: uiActions,
            sourceView: sourceView,
            sourceRect: sourceRect
        )
    }

    /// Presents a confirmation dialog using UIKit (works from SwiftUI)
    public static func showConfirmation(
        title: String,
        message: String,
        confirmTitle: String = "Confirm",
        confirmStyle: UIAlertAction.Style = .default,
        onConfirm: @escaping () -> Void,
        cancelTitle: String = "Cancel",
        onCancel: (() -> Void)? = nil
    ) {
        DispatchQueue.main.async {
            UIApplication.shared.presentConfirmation(
                title: title,
                message: message,
                confirmTitle: confirmTitle,
                confirmStyle: confirmStyle,
                onConfirm: onConfirm,
                cancelTitle: cancelTitle,
                onCancel: onCancel
            )
        }
    }

    /// Presents an alert using UIKit (works from SwiftUI)
    public static func showAlert(
        title: String,
        message: String,
        actionTitle: String = "OK",
        onDismiss: (() -> Void)? = nil
    ) {
        DispatchQueue.main.async {
            let action = UIAlertAction(title: actionTitle, style: .cancel) { _ in onDismiss?() }
            UIApplication.shared.presentAlert(
                title: title,
                message: message,
                actions: [action]
            )
        }
    }

    /// Presents an alert with multiple actions using UIKit
    public static func showAlert(
        title: String,
        message: String,
        actions: [(title: String, style: UIAlertAction.Style, handler: () -> Void)]
    ) {
        DispatchQueue.main.async {
            let uiActions = actions.map { item in
                UIAlertAction(title: item.title, style: item.style) { _ in item.handler() }
            }
            UIApplication.shared.presentAlert(
                title: title,
                message: message,
                actions: uiActions
            )
        }
    }

    /// Presents an alert with a text field using UIKit
    public static func showTextInput(
        title: String,
        message: String,
        placeholder: String? = nil,
        prefilledText: String? = nil,
        keyboardType: UIKeyboardType = .default,
        submitTitle: String = "Submit",
        cancelTitle: String = "Cancel",
        onSubmit: @escaping (String) -> Void,
        onCancel: (() -> Void)? = nil
    ) {
        DispatchQueue.main.async {
            guard let topViewController = UIApplication.topViewController() else { return }

            let alertController = UIAlertController(
                title: title,
                message: message,
                preferredStyle: .alert
            )

            alertController.addTextField { textField in
                textField.placeholder = placeholder
                textField.text = prefilledText
                textField.keyboardType = keyboardType
            }

            let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel) { _ in
                onCancel?()
            }
            alertController.addAction(cancelAction)

            let submitAction = UIAlertAction(title: submitTitle, style: .default) { _ in
                let text = alertController.textFields?.first?.text ?? ""
                onSubmit(text)
            }
            alertController.addAction(submitAction)

            topViewController.present(alertController, animated: true)
        }
    }
}

#endif
