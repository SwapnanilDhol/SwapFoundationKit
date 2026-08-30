/****************************************************************************
 * AppAttestSessionHTTPBackend.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import CoreFoundation
import Foundation

/// HTTP implementation of the shared challenge/enroll/session/bind Worker contract.
public struct AppAttestSessionHTTPBackend: AuthenticatedSessionBackend {
    public struct Paths: Sendable {
        public let challenge: String
        public let enroll: String
        public let session: String
        public let bind: String

        public init(challenge: String = "v1/auth/challenge", enroll: String = "v1/auth/enroll", session: String = "v1/auth/session", bind: String = "v1/auth/bind-purchase") {
            self.challenge = challenge
            self.enroll = enroll
            self.session = session
            self.bind = bind
        }
    }

    private let baseURL: URL
    private let paths: Paths
    private let transport: any AuthenticatedSessionHTTPTransport
    private let timeout: TimeInterval
    private let clock: any AuthenticatedSessionClock
    private let sleeper: any AuthenticatedSessionSleeper

    public init(baseURL: URL, paths: Paths = Paths(), transport: any AuthenticatedSessionHTTPTransport = URLSessionAuthenticatedSessionHTTPTransport(), timeout: TimeInterval = 15, clock: any AuthenticatedSessionClock = SystemAuthenticatedSessionClock(), sleeper: any AuthenticatedSessionSleeper = SystemAuthenticatedSessionSleeper()) {
        self.baseURL = baseURL
        self.paths = paths
        self.transport = transport
        self.timeout = max(0.1, timeout)
        self.clock = clock
        self.sleeper = sleeper
    }

    public func challenge(purpose: String, identity: String, deadline: Date) async throws -> AuthenticatedSessionChallenge {
        var components = URLComponents(url: try url(path: paths.challenge), resolvingAgainstBaseURL: false)
        components?.queryItems = [URLQueryItem(name: "purpose", value: purpose)]
        let response = try await send(url: components?.url, identity: identity, body: EmptyJSON(), bearer: nil, deadline: deadline)
        let decoded = try decode(ChallengeJSON.self, response.data)
        guard !decoded.challenge.isEmpty else { throw AuthenticatedSessionError.invalidResponse }
        let expiry = decoded.expiresAt.map { Date(timeIntervalSince1970: TimeInterval($0)) } ?? clock.now.addingTimeInterval(300)
        guard expiry > clock.now else { throw AuthenticatedSessionError.invalidResponse }
        return AuthenticatedSessionChallenge(value: decoded.challenge, expiresAt: expiry)
    }

    public func enroll(challenge: AuthenticatedSessionChallenge, keyID: String, attestationObject: Data, identity: String, deadline: Date) async throws {
        _ = try await send(path: paths.enroll, identity: identity, body: EnrollmentJSON(challenge: challenge.value, keyID: keyID, attestation: attestationObject.base64EncodedString()), bearer: nil, deadline: deadline)
    }

    public func issueSession(challenge: AuthenticatedSessionChallenge, keyID: String, assertion: Data, identity: String, deadline: Date) async throws -> AuthenticatedSessionCredential {
        let response = try await send(path: paths.session, identity: identity, body: SessionJSON(challenge: challenge.value, keyID: keyID, assertion: assertion.base64EncodedString()), bearer: nil, deadline: deadline)
        let decoded = try decode(SessionResponseJSON.self, response.data)
        let expiry = Date(timeIntervalSince1970: TimeInterval(decoded.expiresAt))
        guard !decoded.token.isEmpty, expiry > clock.now, decoded.appUserID == nil || decoded.appUserID == identity else { throw AuthenticatedSessionError.identityMismatch }
        return AuthenticatedSessionCredential(token: decoded.token, expiresAt: expiry, keyID: keyID, identity: identity)
    }

    public func bind(proof: SessionBindingProof, credential: AuthenticatedSessionCredential, identity: String, deadline: Date) async throws {
        guard proof.identity == identity, credential.identity == identity else { throw AuthenticatedSessionError.identityMismatch }
        _ = try await send(path: paths.bind, identity: identity, body: BindingJSON(payload: proof.encodedPayload), bearer: credential.token, deadline: deadline)
    }

    private func send<Body: Encodable>(path: String, identity: String, body: Body, bearer: String?, deadline: Date) async throws -> AuthenticatedSessionHTTPResponse {
        try await send(url: try url(path: path), identity: identity, body: body, bearer: bearer, deadline: deadline)
    }

    private func send<Body: Encodable>(url: URL?, identity: String, body: Body, bearer: String?, deadline: Date) async throws -> AuthenticatedSessionHTTPResponse {
        guard let url else { throw AuthenticatedSessionError.invalidURL }
        guard !identity.isEmpty else { throw AuthenticatedSessionError.identityMismatch }
        let remaining = deadline.timeIntervalSince(clock.now)
        guard remaining > 0 else { throw AuthenticatedSessionError.transientAppleFailure }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = min(timeout, max(0.1, remaining))
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(identity, forHTTPHeaderField: "X-App-User-ID")
        if let bearer { request.setValue("Bearer \(bearer)", forHTTPHeaderField: "Authorization") }
        request.httpBody = try JSONEncoder().encode(body)
        let response = try await transport.send(request)
        guard deadline > clock.now else { throw AuthenticatedSessionError.transientAppleFailure }
        guard (200..<300).contains(response.statusCode) else {
            let error = AuthenticatedSessionError.http(status: response.statusCode, code: Self.errorCode(from: response.data))
            if error.isTransient, let retryAfter = response.retryAfter {
                let delay = min(max(0, retryAfter), max(0, deadline.timeIntervalSince(clock.now) - 0.01))
                if delay > 0 { try await sleeper.sleep(seconds: delay) }
            }
            throw error
        }
        return response
    }

    private func url(path: String) throws -> URL {
        guard baseURL.scheme?.lowercased() == "https", baseURL.user == nil, baseURL.password == nil,
              let result = URL(string: path, relativeTo: baseURL)?.absoluteURL,
              result.scheme?.lowercased() == "https", result.user == nil, result.password == nil,
              result.host?.lowercased() == baseURL.host?.lowercased(), result.port == baseURL.port else {
            throw AuthenticatedSessionError.invalidURL
        }
        return result
    }

    private func decode<Value: Decodable>(_ type: Value.Type, _ data: Data) throws -> Value {
        do { return try JSONDecoder().decode(type, from: data) }
        catch { throw AuthenticatedSessionError.invalidResponse }
    }

    private static func errorCode(from data: Data) -> String? { (try? JSONDecoder().decode(ErrorJSON.self, from: data))?.code }

    private struct EmptyJSON: Encodable {}
    private struct ChallengeJSON: Decodable {
        let challenge: String
        let expiresAt: Int?
    }

    private struct EnrollmentJSON: Encodable {
        let challenge: String
        let keyID: String
        let attestation: String
    }

    private struct SessionJSON: Encodable {
        let challenge: String
        let keyID: String
        let assertion: String
    }

    private struct SessionResponseJSON: Decodable {
        let token: String
        let expiresAt: Int
        let appUserID: String?
    }
    private struct BindingJSON: Encodable {
        let payload: Data
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: Key.self)
            try container.encode(RawJSON(data: payload), forKey: .purchaseProof)
        }
        private enum Key: String, CodingKey { case purchaseProof }
    }
    private struct RawJSON: Encodable {
        let data: Data
        func encode(to encoder: Encoder) throws { try JSONValue(object: JSONSerialization.jsonObject(with: data)).encode(to: encoder) }
    }
    private enum JSONValue: Encodable {
        case object([String: JSONValue])
        case array([JSONValue])
        case string(String)
        case number(NSNumber)
        case bool(Bool)
        case null
        init(object: Any) throws {
            switch object {
            case let value as [String: Any]: self = .object(try value.mapValues(JSONValue.init(object:)))
            case let value as [Any]: self = .array(try value.map(JSONValue.init(object:)))
            case let value as String: self = .string(value)
            case let value as NSNumber where CFGetTypeID(value) == CFBooleanGetTypeID(): self = .bool(value.boolValue)
            case let value as NSNumber: self = .number(value)
            case _ as NSNull: self = .null
            default: throw AuthenticatedSessionError.invalidResponse
            }
        }
        func encode(to encoder: Encoder) throws {
            switch self {
            case let .object(value):
                var container = encoder.container(keyedBy: DynamicKey.self)
                for (key, item) in value {
                    try container.encode(item, forKey: DynamicKey(stringValue: key))
                }
            case let .array(value):
                var container = encoder.unkeyedContainer()
                for item in value { try container.encode(item) }
            case let .string(value):
                var container = encoder.singleValueContainer()
                try container.encode(value)
            case let .number(value):
                var container = encoder.singleValueContainer()
                try container.encode(value.doubleValue)
            case let .bool(value):
                var container = encoder.singleValueContainer()
                try container.encode(value)
            case .null:
                var container = encoder.singleValueContainer()
                try container.encodeNil()
            }
        }
    }
    private struct DynamicKey: CodingKey {
        let stringValue: String
        let intValue: Int? = nil
        init(stringValue: String) { self.stringValue = stringValue }
        init?(intValue: Int) { nil }
    }
    private struct ErrorJSON: Decodable { let code: String? }
}
