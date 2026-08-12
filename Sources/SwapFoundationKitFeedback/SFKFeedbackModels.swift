import Foundation

public enum SFKFeedbackAccountStatus: String, Encodable, Equatable, Sendable {
    case unknown
    case free
    case paid
}

public struct SFKFeedbackUserContext: Encodable, Equatable, Sendable {
    public let userID: String?
    public let accountStatus: SFKFeedbackAccountStatus
    public let plan: String?
    public let entitlements: [String]
    public let attributes: [String: String]

    public init(
        userID: String?,
        accountStatus: SFKFeedbackAccountStatus,
        plan: String?,
        entitlements: [String],
        attributes: [String: String]
    ) {
        self.userID = userID
        self.accountStatus = accountStatus
        self.plan = plan
        self.entitlements = entitlements
        self.attributes = attributes
    }

    public static let anonymous = SFKFeedbackUserContext(
        userID: nil,
        accountStatus: .unknown,
        plan: nil,
        entitlements: [],
        attributes: [:]
    )
}

public struct SFKFeedbackUserContextProvider: Sendable {
    private let resolver: @MainActor @Sendable () async -> SFKFeedbackUserContext

    public init(
        resolver: @escaping @MainActor @Sendable () async -> SFKFeedbackUserContext = {
            .anonymous
        }
    ) {
        self.resolver = resolver
    }

    @MainActor
    public func resolve() async -> SFKFeedbackUserContext {
        await resolver()
    }
}

public enum SFKFeedbackCategory: String, CaseIterable, Codable, Identifiable, Sendable {
    case feedback
    case bug
    case idea

    public var id: String { rawValue }
}

public struct SFKFeedbackContext: Encodable, Equatable, Sendable {
    public let appVersion: String
    public let buildNumber: String
    public let osVersion: String
    public let locale: String
    public let deviceFamily: String

    public init(
        appVersion: String,
        buildNumber: String,
        osVersion: String,
        locale: String,
        deviceFamily: String
    ) {
        self.appVersion = appVersion
        self.buildNumber = buildNumber
        self.osVersion = osVersion
        self.locale = locale
        self.deviceFamily = deviceFamily
    }
}

public struct SFKFeedbackAttachment: Equatable, Sendable {
    public let fileName: String
    public let contentType: String
    public let data: Data

    public init(fileName: String, contentType: String, data: Data) {
        self.fileName = fileName
        self.contentType = contentType
        self.data = data
    }
}

public struct SFKFeedbackDraft: Equatable, Sendable {
    public let category: SFKFeedbackCategory
    public let message: String
    public let name: String?
    public let replyEmail: String?
    public let attachment: SFKFeedbackAttachment?

    public init(
        category: SFKFeedbackCategory,
        message: String,
        name: String?,
        replyEmail: String?,
        attachment: SFKFeedbackAttachment?
    ) {
        self.category = category
        self.message = message
        self.name = name
        self.replyEmail = replyEmail
        self.attachment = attachment
    }
}

public struct SFKFeedbackReceipt: Decodable, Equatable, Sendable {
    public let feedbackID: UUID
    public let duplicate: Bool
    public let deliveryStatus: String

    private enum CodingKeys: String, CodingKey {
        case feedbackID = "feedbackId"
        case duplicate
        case deliveryStatus
    }
}

public enum SFKFeedbackFailureReason: String, Sendable {
    case configuration
    case invalidFeedback
    case rateLimited
    case unavailable
}

public enum SFKFeedbackEvent: Sendable {
    case opened(source: String)
    case submitted(category: SFKFeedbackCategory)
    case succeeded(category: SFKFeedbackCategory)
    case failed(category: SFKFeedbackCategory, reason: SFKFeedbackFailureReason)
}

struct SFKFeedbackSubmission: Encodable, Equatable {
    let contractVersion = 1
    let idempotencyKey: UUID
    let category: SFKFeedbackCategory
    let message: String
    let name: String?
    let replyEmail: String?
    let context: SFKFeedbackContext
    let userContext: SFKFeedbackUserContext
    let attachment: SFKFeedbackAttachment?

    private enum CodingKeys: String, CodingKey {
        case contractVersion
        case idempotencyKey
        case category
        case message
        case name
        case replyEmail
        case context
        case userContext
    }
}

enum SFKFeedbackAttachmentState: Equatable {
    case empty
    case processing(UUID)
    case ready(SFKFeedbackAttachment)
    case loadFailed
    case processingFailed

    var attachment: SFKFeedbackAttachment? {
        guard case let .ready(attachment) = self else { return nil }
        return attachment
    }

    var isProcessing: Bool {
        guard case .processing = self else { return false }
        return true
    }
}
