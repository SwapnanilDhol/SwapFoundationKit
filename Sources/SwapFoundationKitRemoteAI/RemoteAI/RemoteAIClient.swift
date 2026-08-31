/****************************************************************************
- RemoteAIClient.swift
- SwapFoundationKit
 *****************************************************************************/

import Foundation
import SwapFoundationKitNetworking

/// Calls a backend AI generation endpoint and decodes its structured result.
///
/// The model, prompt, and output schema live on the backend, so this client is
/// only responsible for the parts every app repeats: encoding the request,
/// attaching identity headers, mapping HTTP status onto typed errors, and
/// letting cancellation propagate as `CancellationError`.
///
/// Request and response shapes stay in the host app — they are domain models.
public final class RemoteAIClient {
    private let configuration: RemoteAIConfiguration
    private let client: HTTPClient

    public init(
        configuration: RemoteAIConfiguration,
        client: HTTPClient = .shared
    ) {
        self.configuration = configuration
        self.client = client
    }

    /// Encoder matching the snake_case convention these backends use.
    public static var defaultEncoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }

    /// Decoder matching the snake_case convention these backends use. Apps with
    /// custom date formats supply their own.
    public static var defaultDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }

    /// Sends `body` to the configured endpoint and decodes the response.
    ///
    /// - Throws: `RemoteAIError` for anything the backend rejected or could not
    ///   serve, or `CancellationError` when the task was cancelled.
    public func generate<Body: Encodable, Response: Decodable>(
        _ body: Body,
        encoder: JSONEncoder = RemoteAIClient.defaultEncoder,
        decoder: JSONDecoder = RemoteAIClient.defaultDecoder
    ) async throws -> Response {
        let payload: Data
        do {
            payload = try encoder.encode(body)
        } catch {
            throw RemoteAIError.invalidRequest
        }

        do {
            return try await client.executeAndDecode(
                RemoteAIRequest(configuration: configuration, payload: payload),
                decoder: decoder
            )
        } catch let NetworkError.httpError(statusCode, _) {
            throw RemoteAIError.from(statusCode: statusCode)
        } catch NetworkError.cancelled {
            throw CancellationError()
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            throw RemoteAIError.unavailable
        }
    }
}
