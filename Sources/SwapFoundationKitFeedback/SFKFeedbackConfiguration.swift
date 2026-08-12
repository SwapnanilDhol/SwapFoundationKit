import Foundation
import SwiftUI
import UIKit

public struct SFKFeedbackCopy: Sendable {
    public var introductionTitle: String
    public var introductionMessage: String
    public var privacyMessage: String
    public var attachmentRetentionDays: Int?

    public init(
        introductionTitle: String = "Tell me what you think",
        introductionMessage: String = "Share what worked, what didn’t, or what you’d like me to build next. I read every message.",
        privacyMessage: String = "Your name, email, and image are sent only if you add them. A pseudonymous subscription ID and limited app context may also be shared to help prioritize feedback.",
        attachmentRetentionDays: Int? = nil
    ) {
        self.introductionTitle = introductionTitle
        self.introductionMessage = introductionMessage
        self.privacyMessage = privacyMessage
        self.attachmentRetentionDays = attachmentRetentionDays
    }
}

public struct SFKFeedbackConfiguration: Sendable {
    public let baseURL: URL?
    public let accentColor: Color
    public let copy: SFKFeedbackCopy
    public let userContextProvider: SFKFeedbackUserContextProvider
    public let installationIDProvider: @Sendable () throws -> UUID
    public let contextProvider: @MainActor @Sendable () -> SFKFeedbackContext
    public let eventHandler: @MainActor @Sendable (SFKFeedbackEvent) -> Void

    public init(
        baseURL: URL?,
        accentColor: Color,
        copy: SFKFeedbackCopy = .init(),
        userContextProvider: SFKFeedbackUserContextProvider = .init(),
        installationIDProvider: @escaping @Sendable () throws -> UUID,
        contextProvider: @escaping @MainActor @Sendable () -> SFKFeedbackContext = {
            SFKFeedbackContext(
                appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown",
                buildNumber: Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown",
                osVersion: UIDevice.current.systemVersion,
                locale: Locale.current.identifier,
                deviceFamily: UIDevice.current.userInterfaceIdiom == .pad ? "iPad" : "iPhone"
            )
        },
        eventHandler: @escaping @MainActor @Sendable (SFKFeedbackEvent) -> Void = { _ in }
    ) {
        self.baseURL = baseURL
        self.accentColor = accentColor
        self.copy = copy
        self.userContextProvider = userContextProvider
        self.installationIDProvider = installationIDProvider
        self.contextProvider = contextProvider
        self.eventHandler = eventHandler
    }
}
