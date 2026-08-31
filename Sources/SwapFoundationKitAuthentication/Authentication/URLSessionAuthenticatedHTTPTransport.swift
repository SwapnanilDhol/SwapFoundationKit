/****************************************************************************
 * URLSessionAuthenticatedHTTPTransport.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/
import Foundation
import SwapFoundationKitNetworking

public struct URLSessionAuthenticatedHTTPTransport: AuthenticatedSessionHTTPTransport {
    public init() {}
    public func send(_ request: URLRequest) async throws -> AuthenticatedSessionHTTPResponse {
        let session = URLSession(configuration: .default, delegate: RedirectDelegate(), delegateQueue: nil)
        defer { session.finishTasksAndInvalidate() }
        do {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse else { throw NetworkError.invalidResponse }
            return AuthenticatedSessionHTTPResponse(data: data, statusCode: http.statusCode, retryAfter: http.value(forHTTPHeaderField: "Retry-After").flatMap(TimeInterval.init))
        } catch is CancellationError { throw CancellationError() }
        catch let error as URLError where error.code == .cancelled { throw CancellationError() }
        catch let error as NetworkError { throw error }
        catch { throw NetworkError.from(error) }
    }
}

private final class RedirectDelegate: NSObject, URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        guard let source = task.currentRequest?.url, let destination = request.url,
              source.scheme?.lowercased() == destination.scheme?.lowercased(),
              source.host?.lowercased() == destination.host?.lowercased(), source.port == destination.port,
              source.user == nil, source.password == nil, destination.user == nil, destination.password == nil else { completionHandler(nil); return }
        completionHandler(request)
    }
}
