/****************************************************************************
 * URLSessionAuthenticatedSessionHTTPTransport.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/
import Foundation
public struct URLSessionAuthenticatedSessionHTTPTransport: AuthenticatedSessionHTTPTransport {
    public init() {}
    public func send(_ request: URLRequest) async throws -> AuthenticatedSessionHTTPResponse {
        let session = URLSession(
            configuration: .ephemeral,
            delegate: AuthenticatedSessionRedirectDelegate(),
            delegateQueue: nil
        )
        defer { session.finishTasksAndInvalidate() }
        do {
            let (data, response) = try await session.data(for: request)
            guard let response = response as? HTTPURLResponse else {
                throw AuthenticatedSessionError.invalidResponse
            }
            return AuthenticatedSessionHTTPResponse(
                data: data,
                statusCode: response.statusCode,
                retryAfter: response.value(forHTTPHeaderField: "Retry-After").flatMap(TimeInterval.init)
            )
        } catch is CancellationError {
            throw CancellationError()
        } catch let error as URLError where error.code == .cancelled {
            throw CancellationError()
        } catch let error as AuthenticatedSessionError {
            throw error
        } catch {
            throw AuthenticatedSessionError.transientAppleFailure
        }
    }
}
/// Authentication endpoints never follow redirects, so a credential can never be
/// replayed against another origin.
private final class AuthenticatedSessionRedirectDelegate: NSObject, URLSessionTaskDelegate {
    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        willPerformHTTPRedirection response: HTTPURLResponse,
        newRequest request: URLRequest,
        completionHandler: @escaping (URLRequest?) -> Void
    ) {
        completionHandler(nil)
    }
}
