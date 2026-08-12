import Foundation
import SwapFoundationKit
import UIKit

@MainActor
struct SFKFeedbackService {
    private let client: SFKFeedbackClient
    private let configuration: SFKFeedbackConfiguration

    init(
        client: SFKFeedbackClient = .init(),
        configuration: SFKFeedbackConfiguration
    ) {
        self.client = client
        self.configuration = configuration
    }

    func submit(
        _ draft: SFKFeedbackDraft,
        idempotencyKey: UUID
    ) async throws -> SFKFeedbackReceipt {
        guard let baseURL = configuration.baseURL else {
            throw SFKFeedbackClient.ClientError.configuration
        }
        let submission = SFKFeedbackSubmission(
            idempotencyKey: idempotencyKey,
            category: draft.category,
            message: draft.message,
            name: draft.name,
            replyEmail: draft.replyEmail,
            context: configuration.contextProvider(),
            userContext: await configuration.userContextProvider.resolve(),
            attachment: draft.attachment
        )
        return try await client.submit(
            submission,
            baseURL: baseURL,
            installationID: try configuration.installationIDProvider()
        )
    }
}

@MainActor
struct SFKFeedbackAttachmentProcessor {
    static let maximumBytes = 1_500_000
    static let maximumDimension: CGFloat = 1_600

    func process(_ sourceData: Data) throws -> SFKFeedbackAttachment {
        guard let image = UIImage(data: sourceData) else {
            throw ProcessingError.invalidImage
        }
        guard let data = SFKImageCompressor.compressToSize(
            image,
            maxBytes: Self.maximumBytes,
            maxDimension: Self.maximumDimension,
            quality: 0.78,
            qualityFloor: 0.1
        ), data.count <= Self.maximumBytes else {
            throw ProcessingError.couldNotCompress
        }
        return SFKFeedbackAttachment(
            fileName: "feedback.jpg",
            contentType: "image/jpeg",
            data: data
        )
    }

    enum ProcessingError: Error {
        case invalidImage
        case couldNotCompress
    }
}
