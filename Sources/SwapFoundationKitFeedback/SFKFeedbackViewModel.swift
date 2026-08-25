import Combine
import Foundation

@MainActor
final class SFKFeedbackViewModel: ObservableObject {
    static let maximumMessageLength = 2_000
    static let maximumNameLength = 120

    @Published var category: SFKFeedbackCategory = .feedback
    @Published var message = ""
    @Published var name = ""
    @Published var replyEmail = ""
    @Published private(set) var isSubmitting = false
    @Published private(set) var attachmentState: SFKFeedbackAttachmentState = .empty

    private let analyticsSource: String
    private let service: SFKFeedbackService
    private let eventHandler: @MainActor @Sendable (SFKFeedbackEvent) -> Void
    private let attachmentProcessor = SFKFeedbackAttachmentProcessor()
    private let onAccepted: @MainActor (SFKFeedbackReceipt, SFKFeedbackContact) -> Void
    private let onFailure: @MainActor (SFKFeedbackFailureReason) -> Void
    private var hasLoggedOpen = false
    private var pendingAttempt: (id: UUID, draft: SFKFeedbackDraft)?

    init(
        analyticsSource: String,
        configuration: SFKFeedbackConfiguration,
        onAccepted: @escaping @MainActor (SFKFeedbackReceipt, SFKFeedbackContact) -> Void,
        onFailure: @escaping @MainActor (SFKFeedbackFailureReason) -> Void
    ) {
        self.analyticsSource = analyticsSource
        service = SFKFeedbackService(configuration: configuration)
        eventHandler = configuration.eventHandler
        self.onAccepted = onAccepted
        self.onFailure = onFailure
    }

    var normalizedMessage: String {
        message.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var normalizedReplyEmail: String? {
        let value = replyEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? nil : value
    }

    var normalizedName: String? {
        let value = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? nil : value
    }

    var canSubmit: Bool {
        !isSubmitting && !attachmentState.isProcessing && isMessageValid &&
            isNameValid && isReplyEmailValid
    }

    var attachment: SFKFeedbackAttachment? { attachmentState.attachment }
    var isProcessingAttachment: Bool { attachmentState.isProcessing }

    var attachmentErrorMessage: String? {
        switch attachmentState {
        case .loadFailed:
            return "That image couldn’t be loaded. Choose another image and try again."
        case .processingFailed:
            return "That image couldn’t be prepared. Choose another image and try again."
        case .empty, .processing, .ready:
            return nil
        }
    }

    var isMessageValid: Bool {
        normalizedMessage.count >= 4 &&
            normalizedMessage.count <= Self.maximumMessageLength
    }

    var remainingCharacters: Int { Self.maximumMessageLength - message.count }

    var isReplyEmailValid: Bool {
        guard let email = normalizedReplyEmail else { return true }
        return email.count <= 254 && email.range(
            of: #"^[^\s@]+@[^\s@]+\.[^\s@]+$"#,
            options: .regularExpression
        ) != nil
    }

    var isNameValid: Bool {
        guard let name = normalizedName else { return true }
        return name.count <= Self.maximumNameLength
    }

    func onAppear() {
        guard !hasLoggedOpen else { return }
        hasLoggedOpen = true
        eventHandler(.opened(source: analyticsSource))
    }

    @discardableResult
    func beginAttachmentProcessing() -> UUID {
        let requestID = UUID()
        attachmentState = .processing(requestID)
        return requestID
    }

    func attachImage(_ sourceData: Data, requestID: UUID) {
        guard attachmentState == .processing(requestID) else { return }
        do {
            attachmentState = .ready(try attachmentProcessor.process(sourceData))
        } catch {
            attachmentState = .processingFailed
        }
    }

    func failToLoadAttachment(requestID: UUID) {
        guard attachmentState == .processing(requestID) else { return }
        attachmentState = .loadFailed
    }

    func removeAttachment() {
        attachmentState = .empty
    }

    func submit() {
        guard canSubmit else { return }
        isSubmitting = true
        let draft = SFKFeedbackDraft(
            category: category,
            message: normalizedMessage,
            name: normalizedName,
            replyEmail: normalizedReplyEmail,
            attachment: attachment
        )
        let attempt: (id: UUID, draft: SFKFeedbackDraft)
        if let pendingAttempt, pendingAttempt.draft == draft {
            attempt = pendingAttempt
        } else {
            attempt = (UUID(), draft)
            pendingAttempt = attempt
        }
        eventHandler(.submitted(category: draft.category))
        Task {
            do {
                let receipt = try await service.submit(
                    attempt.draft,
                    idempotencyKey: attempt.id
                )
                isSubmitting = false
                pendingAttempt = nil
                eventHandler(.succeeded(category: draft.category))
                onAccepted(
                    receipt,
                    SFKFeedbackContact(name: draft.name, email: draft.replyEmail)
                )
            } catch {
                isSubmitting = false
                let reason = Self.failureReason(for: error)
                eventHandler(.failed(category: draft.category, reason: reason))
                onFailure(reason)
            }
        }
    }

    private static func failureReason(for error: Error) -> SFKFeedbackFailureReason {
        switch error as? SFKFeedbackClient.ClientError {
        case .rateLimited:
            return .rateLimited
        case .invalidFeedback:
            return .invalidFeedback
        case .configuration:
            return .configuration
        case .invalidResponse, .unavailable, .rejected, .none:
            return .unavailable
        }
    }
}
