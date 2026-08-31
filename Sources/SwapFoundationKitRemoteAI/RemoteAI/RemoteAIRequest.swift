/****************************************************************************
- RemoteAIRequest.swift
- SwapFoundationKit
 *****************************************************************************/

import Foundation
import SwapFoundationKitNetworking

/// The POST issued by `RemoteAIClient`. Internal: callers describe the endpoint
/// with `RemoteAIConfiguration` rather than building requests themselves.
struct RemoteAIRequest: NetworkRequest {
    let configuration: RemoteAIConfiguration
    let payload: Data

    var scheme: String { configuration.scheme }

    var baseURL: String { configuration.host }

    var path: String { configuration.path }

    var method: HTTPMethod { .post }

    var parameters: [String: String]? { nil }

    var timeoutInterval: TimeInterval { configuration.timeoutInterval }

    var headers: [String: String]? {
        var values = configuration.headersProvider()
        values["Accept"] = "application/json"
        values["Content-Type"] = "application/json"
        return values
    }

    var body: Data? { payload }
}
