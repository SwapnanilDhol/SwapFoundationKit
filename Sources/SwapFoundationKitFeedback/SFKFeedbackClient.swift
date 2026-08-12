import Foundation

final class SFKFeedbackClient {
    private let session: URLSession
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(session: URLSession = .shared) {
        self.session = session
        encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    func submit(
        _ submission: SFKFeedbackSubmission,
        baseURL: URL,
        installationID: UUID
    ) async throws -> SFKFeedbackReceipt {
        var request = URLRequest(url: baseURL.appending(path: "v1/feedback"))
        request.httpMethod = "POST"
        request.timeoutInterval = submission.attachment == nil ? 15 : 30
        request.setValue(
            installationID.uuidString.lowercased(),
            forHTTPHeaderField: "X-Installation-ID"
        )
        let payload = try encoder.encode(submission)
        if let attachment = submission.attachment {
            let boundary = "Feedback-\(UUID().uuidString)"
            request.setValue(
                "multipart/form-data; boundary=\(boundary)",
                forHTTPHeaderField: "Content-Type"
            )
            request.httpBody = multipartBody(
                payload: payload,
                attachment: attachment,
                boundary: boundary
            )
        } else {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = payload
        }
        let (data, response) = try await session.data(for: request)
        guard let response = response as? HTTPURLResponse else {
            throw ClientError.invalidResponse
        }
        switch response.statusCode {
        case 202:
            return try decoder.decode(SFKFeedbackReceipt.self, from: data)
        case 429:
            throw ClientError.rateLimited
        case 400, 413, 415, 422:
            throw ClientError.invalidFeedback
        case 500...599:
            throw ClientError.unavailable
        default:
            throw ClientError.rejected(response.statusCode)
        }
    }

    private func multipartBody(
        payload: Data,
        attachment: SFKFeedbackAttachment,
        boundary: String
    ) -> Data {
        var body = Data()
        body.appendUTF8("--\(boundary)\r\n")
        body.appendUTF8("Content-Disposition: form-data; name=\"payload\"\r\n")
        body.appendUTF8("Content-Type: application/json\r\n\r\n")
        body.append(payload)
        body.appendUTF8("\r\n--\(boundary)\r\n")
        body.appendUTF8("Content-Disposition: form-data; name=\"attachment\"; filename=\"\(attachment.fileName)\"\r\n")
        body.appendUTF8("Content-Type: \(attachment.contentType)\r\n\r\n")
        body.append(attachment.data)
        body.appendUTF8("\r\n--\(boundary)--\r\n")
        return body
    }

    enum ClientError: Error, Equatable {
        case configuration
        case invalidResponse
        case rateLimited
        case invalidFeedback
        case unavailable
        case rejected(Int)
    }
}

private extension Data {
    mutating func appendUTF8(_ value: String) {
        append(Data(value.utf8))
    }
}
