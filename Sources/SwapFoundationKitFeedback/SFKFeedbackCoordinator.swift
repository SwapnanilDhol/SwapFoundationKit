import SwapFoundationKit
import SwiftUI
import UIKit

@MainActor
public final class SFKFeedbackCoordinator: NSObject {
    public var onFinish: (() -> Void)?
    public var onAccepted: (@MainActor (SFKFeedbackReceipt, SFKFeedbackContact) -> Void)?

    private let configuration: SFKFeedbackConfiguration
    private weak var controller: UIViewController?

    public init(configuration: SFKFeedbackConfiguration) {
        self.configuration = configuration
    }

    public func makeViewController(
        analyticsSource: String = "settings"
    ) -> UIViewController {
        let viewModel = SFKFeedbackViewModel(
            analyticsSource: analyticsSource,
            configuration: configuration,
            onAccepted: { [weak self] receipt, contact in
                self?.didAccept(receipt, contact: contact)
            },
            onFailure: { [weak self] reason in self?.didFail(reason) }
        )
        let controller = UIHostingController(
            rootView: SFKFeedbackView(
                viewModel: viewModel,
                configuration: configuration
            )
        )
        self.controller = controller
        return controller
    }

    public func present(
        from presenter: UIViewController,
        analyticsSource: String = "settings"
    ) {
        let controller = makeViewController(analyticsSource: analyticsSource)
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(
            systemItem: .close,
            primaryAction: UIAction { [weak self] _ in self?.finish() }
        )
        let navigation = UINavigationController(rootViewController: controller)
        navigation.modalPresentationStyle = .pageSheet
        navigation.sheetPresentationController?.detents = [.large()]
        navigation.presentationController?.delegate = self
        presenter.present(navigation, animated: true)
    }

    private func didAccept(_ receipt: SFKFeedbackReceipt, contact: SFKFeedbackContact) {
        onAccepted?(receipt, contact)
        AlertPresenter.showAlert(
            title: "Feedback sent",
            message: "Thank you. Your feedback reference is \(receipt.feedbackID.uuidString.prefix(8).uppercased()).",
            actions: [("Done", .default, { [weak self] in self?.finish() })]
        )
    }

    private func didFail(_ reason: SFKFeedbackFailureReason) {
        let message: String
        switch reason {
        case .configuration, .unavailable:
            message = "Feedback is temporarily unavailable. Please try again in a moment."
        case .invalidFeedback:
            message = "Check your name, message, and reply email, then try again."
        case .rateLimited:
            message = "A few messages were sent recently. Please wait a minute and try again."
        }
        AlertPresenter.showAlert(title: "Couldn’t send feedback", message: message)
    }

    private func finish() {
        guard let controller, let navigation = controller.navigationController else {
            onFinish?()
            return
        }
        if navigation.viewControllers.first === controller,
           navigation.presentingViewController != nil {
            navigation.dismiss(animated: true) { [weak self] in self?.onFinish?() }
        } else {
            navigation.popViewController(animated: true)
            onFinish?()
        }
    }
}

extension SFKFeedbackCoordinator: UIAdaptivePresentationControllerDelegate {
    public func presentationControllerDidDismiss(
        _ presentationController: UIPresentationController
    ) {
        controller = nil
        onFinish?()
    }
}
