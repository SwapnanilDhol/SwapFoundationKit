/****************************************************************************
- RemoteAIConfiguration.swift
- SwapFoundationKit
 *****************************************************************************/

import Foundation

/// Describes where a remote AI generation endpoint lives and how to authenticate
/// against it.
///
/// The model, prompt, and schema all live on the backend, so the client side only
/// needs to know the endpoint and the per-request identity headers.
public struct RemoteAIConfiguration {
    /// Base URL of the backend, for example `https://api.example.com`.
    public let baseURL: URL

    /// Path of the generation endpoint, for example `/v1/briefings`.
    public let path: String

    /// Request timeout. Generation is slower than a typical API call, so this
    /// defaults well above `NetworkRequest`'s 30 seconds.
    public let timeoutInterval: TimeInterval

    /// Evaluated per request so rotating identity values are never captured stale.
    public let headersProvider: () -> [String: String]

    public init(
        baseURL: URL,
        path: String,
        timeoutInterval: TimeInterval = 60,
        headersProvider: @escaping () -> [String: String] = { [:] }
    ) {
        self.baseURL = baseURL
        self.path = path
        self.timeoutInterval = timeoutInterval
        self.headersProvider = headersProvider
    }

    /// Host with port when one is present, in the form `NetworkRequest` expects.
    var host: String {
        guard let host = baseURL.host else { return "" }
        guard let port = baseURL.port else { return host }
        return "\(host):\(port)"
    }

    var scheme: String {
        baseURL.scheme ?? "https"
    }
}
