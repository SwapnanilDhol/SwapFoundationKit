import Foundation
import Testing
@testable import SwapFoundationKitFeedback

@Suite("SFK feedback contract")
struct SFKFeedbackContractTests {
    @Test("Accepted feedback exposes optional contact details")
    func acceptedContact() {
        let contact = SFKFeedbackContact(name: "Swapnanil", email: "hello@example.com")

        #expect(contact.name == "Swapnanil")
        #expect(contact.email == "hello@example.com")
    }

    @Test("Submission uses the v1 snake-case wire contract")
    func submissionEncoding() throws {
        let submission = SFKFeedbackSubmission(
            idempotencyKey: UUID(uuidString: "22222222-2222-4222-8222-222222222222")!,
            category: .feedback,
            message: "Useful feedback",
            name: "Swapnanil",
            replyEmail: "hello@example.com",
            context: .init(
                appVersion: "1.0", buildNumber: "1", osVersion: "26.0",
                locale: "en-IN", deviceFamily: "iPhone"
            ),
            userContext: .init(
                userID: "rc-user", accountStatus: .paid, plan: "annual",
                entitlements: ["pro"], attributes: [:]
            ),
            attachment: nil
        )
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let object = try #require(
            JSONSerialization.jsonObject(with: encoder.encode(submission)) as? [String: Any]
        )
        #expect(object["contract_version"] as? Int == 1)
        #expect(object["reply_email"] as? String == "hello@example.com")
        #expect(object["attachment"] == nil)
    }
}
