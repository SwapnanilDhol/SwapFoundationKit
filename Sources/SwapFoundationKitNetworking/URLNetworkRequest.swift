/*****************************************************************************
 * URLNetworkRequest.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import Foundation

/// A `NetworkRequest` for a complete URL, shared by the package's own products.
///
/// `explicitURL` sends the URL byte-for-byte (presigned and token-signed URLs keep
/// their escapes and query order); the decomposed `scheme`/`baseURL`/`path`/
/// `parameters` stay populated for diagnostics only. `package` access keeps this
/// out of the public API.
package struct URLNetworkRequest: NetworkRequest {
    package let scheme: String
    package let baseURL: String
    package let path: String
    package let method: HTTPMethod
    package let parameters: [String: String]?
    package let headers: [String: String]?
    package let body: Data?
    package let timeoutInterval: TimeInterval
    package let cachePolicy: URLRequest.CachePolicy
    package let explicitURL: URL?
    package let usesClientDefaultHeaders: Bool

    /// - Parameters:
    ///   - parameters: Diagnostic query parameters; defaults to those parsed from `url`.
    ///   - usesClientDefaultHeaders: Pass `false` for non-JSON resources so
    ///     `HTTPClient.defaultHeaders` (JSON `Content-Type`/`Accept`) are not sent.
    package init(
        url: URL,
        method: HTTPMethod = .get,
        parameters: [String: String]? = nil,
        headers: [String: String]? = nil,
        body: Data? = nil,
        timeoutInterval: TimeInterval = 30,
        cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy,
        usesClientDefaultHeaders: Bool = true
    ) {
        self.scheme = url.scheme ?? "https"
        let host = url.host ?? ""
        if let port = url.port {
            self.baseURL = "\(host):\(port)"
        } else {
            self.baseURL = host
        }
        self.path = url.path.isEmpty ? "/" : url.path
        self.method = method
        self.parameters = parameters ?? Self.queryParameters(from: url)
        self.headers = headers
        self.body = body
        self.timeoutInterval = timeoutInterval
        self.cachePolicy = cachePolicy
        self.explicitURL = url
        self.usesClientDefaultHeaders = usesClientDefaultHeaders
    }

    private static func queryParameters(from url: URL) -> [String: String]? {
        guard let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: true)?.queryItems else {
            return nil
        }

        var parameters: [String: String] = [:]
        for item in queryItems {
            if let value = item.value {
                parameters[item.name] = value
            }
        }
        return parameters.isEmpty ? nil : parameters
    }
}
