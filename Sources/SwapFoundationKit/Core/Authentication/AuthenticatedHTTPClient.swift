/****************************************************************************
 * AuthenticatedHTTPClient.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import Foundation

/// Authenticated request gateway with strict-by-default origin and retry policy.
public final class AuthenticatedHTTPClient: @unchecked Sendable {
    private let sessionService: AuthenticatedSessionService
    private let identityProvider: any AuthenticatedSessionIdentityProviding
    private let configuration: AuthenticatedSessionConfiguration
    private let transport: any AuthenticatedSessionHTTPTransport
    private let approvedOrigins: @Sendable () -> Set<AuthenticatedOrigin>

    public init(
        sessionService: AuthenticatedSessionService,
        identityProvider: any AuthenticatedSessionIdentityProviding,
        configuration: AuthenticatedSessionConfiguration,
        transport: any AuthenticatedSessionHTTPTransport = URLSessionAuthenticatedHTTPTransport(),
        approvedOrigins: (@Sendable () -> Set<AuthenticatedOrigin>)? = nil
    ) {
        self.sessionService = sessionService
        self.identityProvider = identityProvider
        self.configuration = configuration
        self.transport = transport
        self.approvedOrigins = approvedOrigins ?? {
            guard let origin = AuthenticatedOrigin(url: configuration.baseURL) else { return [] }
            return [origin]
        }
    }

    public func execute<Request: NetworkRequest>(
        _ request: Request,
        policy: AuthenticatedRequestPolicy = .strict,
        idempotencyKey: String? = nil,
        additionalHeaders: [String: String] = [:]
    ) async throws -> AuthenticatedSessionHTTPResponse {
        try Task.checkCancellation()
        guard let url = request.url, isApproved(url) else { throw AuthenticatedHTTPClientError.invalidOrigin }
        let frozenBody = request.body
        let frozenMethod = request.method
        let frozenTimeout = request.timeoutInterval
        let frozenCachePolicy = request.cachePolicy
        let frozenRequestHeaders = request.headers
        let capturedIdentity = identityProvider.identity.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !capturedIdentity.isEmpty else { throw AuthenticatedHTTPClientError.missingIdentity }

        let resolution = try await resolveHeaders(identity: capturedIdentity, policy: policy)
        try ensureIdentity(capturedIdentity)
        let first = RequestSnapshot(
            url: url,
            method: frozenMethod,
            body: frozenBody,
            timeout: frozenTimeout,
            cachePolicy: frozenCachePolicy,
            headers: merge(
                base: resolution.headers,
                request: frozenRequestHeaders,
                additional: additionalHeaders,
                idempotencyKey: idempotencyKey
            )
        )
        do {
            let response = try await send(first)
            try ensureIdentity(capturedIdentity)
            return response
        } catch let error as NetworkError {
            if let bindingError = resolution.bindingFailure, Self.isPaidDenial(error) { throw bindingError }
            let shouldRetry = Self.isConfirmedPreExecutionAuthRejection(error)
                || (policy.requireBinding && Self.isConfirmedPreExecutionBindingRejection(error))
            guard shouldRetry, Self.isReplaySafe(method: frozenMethod) else { throw error }
            if Self.isConfirmedPreExecutionBindingRejection(error) {
                try await sessionService.invalidateBinding()
            } else {
                await sessionService.invalidateSession()
            }
            try Task.checkCancellation()
            // A retry is always strict: a rejected request must never silently
            // downgrade to unauthenticated compatibility behavior.
            let strictPolicy = AuthenticatedRequestPolicy(requireBinding: policy.requireBinding, compatibility: false)
            let refreshed = try await resolveHeaders(identity: capturedIdentity, policy: strictPolicy).headers
            try ensureIdentity(capturedIdentity)
            let retry = RequestSnapshot(
                url: url,
                method: frozenMethod,
                body: frozenBody,
                timeout: frozenTimeout,
                cachePolicy: frozenCachePolicy,
                headers: merge(
                    base: refreshed,
                    request: frozenRequestHeaders,
                    additional: additionalHeaders,
                    idempotencyKey: idempotencyKey
                )
            )
            let response = try await send(retry)
            try ensureIdentity(capturedIdentity)
            return response
        }
    }

    public func data(
        for url: URL,
        method: HTTPMethod = .get,
        body: Data? = nil,
        timeoutInterval: TimeInterval = 30,
        policy: AuthenticatedRequestPolicy = .strict,
        idempotencyKey: String? = nil,
        additionalHeaders: [String: String] = [:]
    ) async throws -> Data {
        let request = URLRequestSnapshot(urlValue: url, method: method, body: body, timeout: timeoutInterval)
        return try await execute(request, policy: policy, idempotencyKey: idempotencyKey, additionalHeaders: additionalHeaders).data
    }

    private struct HeaderResolution {
        let headers: [String: String]
        /// Set when compatibility mode proceeded without a binding, so a later paid
        /// denial can surface the original binding failure instead of a bare 403.
        let bindingFailure: AuthenticatedSessionError?
    }

    private func resolveHeaders(identity: String, policy: AuthenticatedRequestPolicy) async throws -> HeaderResolution {
        do {
            let credential = try await sessionService.currentSession(requireBinding: policy.requireBinding)
            return HeaderResolution(headers: securedHeaders(identity: identity, credential: credential), bindingFailure: nil)
        } catch is CancellationError { throw CancellationError() }
        catch let error as AuthenticatedSessionError where policy.compatibility && policy.requireBinding && Self.isBindingFailure(error) {
            let credential = try await sessionService.currentSession()
            return HeaderResolution(headers: securedHeaders(identity: identity, credential: credential), bindingFailure: error)
        } catch let error as AuthenticatedSessionError where policy.compatibility && Self.isInitialCompatibilityFailure(error) {
            return HeaderResolution(headers: capabilityHeaders(identity: identity), bindingFailure: nil)
        }
    }

    private func securedHeaders(identity: String, credential: AuthenticatedSessionCredential) -> [String: String] {
        [
            configuration.identityHeaderName: identity,
            configuration.authVersionHeaderName: configuration.authVersion,
            "Authorization": "Bearer \(credential.token)"
        ]
    }

    /// Capability metadata is sent unconditionally so the server can tell an
    /// attestation-capable client apart from a legacy one.
    private func capabilityHeaders(identity: String) -> [String: String] {
        [
            configuration.identityHeaderName: identity,
            configuration.authVersionHeaderName: configuration.authVersion
        ]
    }

    private func send(_ snapshot: RequestSnapshot) async throws -> AuthenticatedSessionHTTPResponse {
        guard let request = snapshot.urlRequest else { throw NetworkError.invalidURL }
        let response = try await transport.send(request)
        guard (200...299).contains(response.statusCode) else {
            throw NetworkError.httpError(statusCode: response.statusCode, data: response.data)
        }
        return response
    }

    /// Merges caller headers while keeping the client's own security headers authoritative.
    private func merge(
        base: [String: String],
        request: [String: String]?,
        additional: [String: String],
        idempotencyKey: String?
    ) -> [String: String] {
        var values = base
        if let request { values.merge(request) { _, new in new } }
        values.merge(additional) { _, new in new }
        let protected: Set<String> = [
            "authorization",
            configuration.identityHeaderName.lowercased(),
            configuration.authVersionHeaderName.lowercased(),
            "idempotency-key"
        ]
        values = values.filter { !protected.contains($0.key.lowercased()) }
        for (key, value) in base where protected.contains(key.lowercased()) {
            values[key] = value
        }
        if let idempotencyKey, !idempotencyKey.isEmpty {
            values["Idempotency-Key"] = idempotencyKey
        }
        return values
    }

    private func ensureIdentity(_ expected: String) throws {
        let current = identityProvider.identity.trimmingCharacters(in: .whitespacesAndNewlines)
        guard current == expected else { throw AuthenticatedHTTPClientError.identityChanged }
    }

    private func isApproved(_ url: URL) -> Bool {
        guard url.scheme?.lowercased() == "https",
              url.user == nil,
              url.password == nil,
              let origin = AuthenticatedOrigin(url: url) else {
            return false
        }
        return approvedOrigins().contains(origin)
    }

    private static func code(from data: Data) -> String? {
        (try? JSONDecoder().decode(ErrorPayload.self, from: data))?.code?.uppercased()
    }

    private static func isPaidDenial(_ error: NetworkError) -> Bool {
        guard case let .httpError(status, data) = error, status == 403,
              let data, let code = code(from: data) else {
            return false
        }
        return code == "PRO_REQUIRED" || code == "PURCHASE_BINDING_REQUIRED"
    }

    /// Only a typed rejection proves the server refused before executing the request,
    /// which is what makes a single replay safe.
    private static func isConfirmedPreExecutionAuthRejection(_ error: NetworkError) -> Bool {
        guard case let .httpError(status, data) = error, status == 401,
              let data, let code = code(from: data) else {
            return false
        }
        return code == "AUTH_REQUIRED" || code == "AUTH_INVALID_SESSION"
    }

    private static func isConfirmedPreExecutionBindingRejection(_ error: NetworkError) -> Bool {
        guard case let .httpError(status, data) = error, status == 403, let data else { return false }
        return code(from: data) == "PURCHASE_BINDING_REQUIRED"
    }

    private static func isReplaySafe(method: HTTPMethod) -> Bool {
        switch method {
        case .get, .head, .post, .put, .patch, .delete: return true
        }
    }

    private static func isBindingFailure(_ error: AuthenticatedSessionError) -> Bool {
        error == .noBindingProof
            || error == .enrollmentIndeterminate
            || isHTTP(error, code: "PURCHASE_BINDING_REJECTED")
    }

    private static func isHTTP(_ error: AuthenticatedSessionError, code: String) -> Bool {
        guard case let .http(_, value) = error else { return false }
        return value?.uppercased() == code
    }

    private static func isInitialCompatibilityFailure(_ error: AuthenticatedSessionError) -> Bool {
        error == .appAttestUnsupported || error.isTransient
    }

    private struct ErrorPayload: Decodable {
        let code: String?
    }

    /// The request is frozen before authentication so a retry replays identical bytes.
    private struct RequestSnapshot {
        let url: URL
        let method: HTTPMethod
        let body: Data?
        let timeout: TimeInterval
        let cachePolicy: URLRequest.CachePolicy
        let headers: [String: String]

        var urlRequest: URLRequest? {
            var result = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: timeout)
            result.httpMethod = method.rawValue
            result.allHTTPHeaderFields = headers
            result.httpBody = body
            return result
        }
    }
}
