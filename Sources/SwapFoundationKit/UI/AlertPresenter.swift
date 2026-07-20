/****************************************************************************
 * AlertPresenter.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import UIKit

/// An action displayed by ``AlertPresenter``.
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

/// Semantic role for an alert action.
public enum AlertActionStyle: Equatable {
    case `default`
    case cancel
    case destructive

    var uiStyle: UIAlertAction.Style {
        switch self {
        case .default: .default
        case .cancel: .cancel
        case .destructive: .destructive
        }
    }
}

/// The single SFK entry point for UIKit-backed alerts, confirmations, action sheets, and text input.
@MainActor
public enum AlertPresenter {
    public static func showActionSheet(
        title: String,
        message: String? = nil,
        actions: [AlertAction],
        sourceView: UIView? = nil,
        sourceRect: CGRect? = nil
    ) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        actions.forEach { action in
            controller.addAction(
                UIAlertAction(title: action.title, style: action.style.uiStyle) { _ in
                    action.handler?()
                }
            )
        }

        guard let presenter = UIApplication.topViewController() else { return }
        configurePopover(
            for: controller,
            presenter: presenter,
            sourceView: sourceView,
            sourceRect: sourceRect
        )
        presenter.present(controller, animated: true)
    }

    public static func showConfirmation(
        title: String,
        message: String,
        confirmTitle: String = "Confirm",
        confirmStyle: UIAlertAction.Style = .default,
        onConfirm: @escaping () -> Void,
        cancelTitle: String = "Cancel",
        onCancel: (() -> Void)? = nil
    ) {
        showAlert(
            title: title,
            message: message,
            actions: [
                (confirmTitle, confirmStyle, onConfirm),
                (cancelTitle, .cancel, { onCancel?() })
            ]
        )
    }

    public static func showAlert(
        title: String,
        message: String,
        actionTitle: String = "OK",
        onDismiss: (() -> Void)? = nil
    ) {
        showAlert(
            title: title,
            message: message,
            actions: [(actionTitle, .cancel, { onDismiss?() })]
        )
    }

    public static func showAlert(
        title: String,
        message: String,
        actions: [(title: String, style: UIAlertAction.Style, handler: () -> Void)]
    ) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions.forEach { action in
            controller.addAction(
                UIAlertAction(title: action.title, style: action.style) { _ in
                    action.handler()
                }
            )
        }
        present(controller)
    }

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
        present(
            makeTextInputAlert(
                title: title,
                message: message,
                placeholder: placeholder,
                prefilledText: prefilledText,
                keyboardType: keyboardType,
                submitTitle: submitTitle,
                cancelTitle: cancelTitle,
                onSubmit: onSubmit,
                onCancel: onCancel
            )
        )
    }

    static func makeTextInputAlert(
        title: String,
        message: String,
        placeholder: String?,
        prefilledText: String?,
        keyboardType: UIKeyboardType,
        submitTitle: String,
        cancelTitle: String,
        onSubmit: @escaping (String) -> Void,
        onCancel: (() -> Void)?
    ) -> UIAlertController {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        controller.addTextField { textField in
            textField.placeholder = placeholder
            textField.text = prefilledText
            textField.keyboardType = keyboardType
        }
        controller.addAction(
            UIAlertAction(title: cancelTitle, style: .cancel) { _ in
                onCancel?()
            }
        )
        controller.addAction(
            UIAlertAction(title: submitTitle, style: .default) { [weak controller] _ in
                onSubmit(textInputValue(from: controller))
            }
        )
        return controller
    }

    static func textInputValue(from controller: UIAlertController?) -> String {
        controller?.textFields?.first?.text ?? ""
    }

    private static func present(_ controller: UIViewController) {
        UIApplication.topViewController()?.present(controller, animated: true)
    }

    private static func configurePopover(
        for controller: UIAlertController,
        presenter: UIViewController,
        sourceView: UIView?,
        sourceRect: CGRect?
    ) {
        guard let popover = controller.popoverPresentationController,
              let resolvedSourceView = sourceView ?? presenter.view else {
            return
        }

        popover.sourceView = resolvedSourceView
        popover.sourceRect = sourceRect ?? CGRect(
            x: resolvedSourceView.bounds.midX,
            y: resolvedSourceView.bounds.maxY - 1,
            width: 1,
            height: 1
        )
    }
}
