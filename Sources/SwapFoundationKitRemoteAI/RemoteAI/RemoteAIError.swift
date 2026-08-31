/****************************************************************************
- RemoteAIError.swift
- SwapFoundationKit
 *****************************************************************************/

import Foundation

/// Transport-level outcomes of a remote AI generation call.
///
/// These are deliberately neutral. Host apps map them onto their own error type
/// so user-facing copy — which is product wording, and localized per app — stays
/// in the app rather than in the framework.
public enum RemoteAIError: Error, Equatable {
    /// The endpoint could not be resolved, so no request was attempted.
    case notConfigured
    /// The backend rejected the request shape (400, 415, 422).
    case invalidRequest
    /// The caller lacks entitlement for this feature (403).
    case notEntitled
    /// The caller exceeded the backend's rate limit (429).
    case rateLimited
    /// The backend failed or could not be reached (5xx, transport failure).
    case unavailable
    /// Any other non-success status.
    case rejected(statusCode: Int)

    /// Maps an HTTP status onto the closest case.
    static func from(statusCode: Int) -> RemoteAIError {
        switch statusCode {
        case 400, 415, 422: return .invalidRequest
        case 403: return .notEntitled
        case 429: return .rateLimited
        case 500...599: return .unavailable
        default: return .rejected(statusCode: statusCode)
        }
    }
}
