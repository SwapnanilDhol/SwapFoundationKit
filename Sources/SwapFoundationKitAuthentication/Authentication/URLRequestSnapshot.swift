/****************************************************************************
 * URLRequestSnapshot.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/
import Foundation
import SwapFoundationKitNetworking

struct URLRequestSnapshot: NetworkRequest {
    let urlValue: URL
    let method: HTTPMethod
    let body: Data?
    let timeout: TimeInterval

    private let requestHeaders: [String: String]?
    private let requestCachePolicy: URLRequest.CachePolicy

    init(
        urlValue: URL,
        method: HTTPMethod,
        body: Data?,
        timeout: TimeInterval,
        cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy,
        headers: [String: String]? = nil
    ) {
        self.urlValue = urlValue
        self.method = method
        self.body = body
        self.timeout = timeout
        self.requestCachePolicy = cachePolicy
        self.requestHeaders = headers
    }

    var scheme: String { urlValue.scheme ?? "" }
    var baseURL: String {
        guard let host = urlValue.host else { return "" }
        return urlValue.port.map { "\(host):\($0)" } ?? host
    }
    var path: String { urlValue.path.isEmpty ? "/" : urlValue.path }
    var parameters: [String: String]? { nil }
    var headers: [String: String]? { requestHeaders }
    var timeoutInterval: TimeInterval { timeout }
    var cachePolicy: URLRequest.CachePolicy { requestCachePolicy }
}
