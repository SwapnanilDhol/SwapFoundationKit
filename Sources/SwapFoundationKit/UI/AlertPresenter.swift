//
//  AlertPresenter.swift
//  SwapFoundationKit
//
//  SwiftUI-friendly alert presentation helpers
//

import SwiftUI

#if canImport(UIKit) && os(iOS)
import UIKit

/// A SwiftUI-friendly way to present alerts and confirmations
@available(iOS 15.0, *)
public struct AlertPresenter {

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
            let action = UIAlertAction(title: actionTitle) { _ in onDismiss?() }
            UIApplication.shared.presentAlert(
                title: title,
                message: message,
                actions: [action]
            )
        }
    }
}
#endif
