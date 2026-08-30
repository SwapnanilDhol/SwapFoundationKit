/****************************************************************************
 * AuthenticatedSessionError.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/
import Foundation

public enum AuthenticatedSessionError: Error, LocalizedError, Sendable, Equatable {
    case appAttestUnsupported
    case appAttestKeyInvalid
    case appAttestFailure
    case transientAppleFailure
    case keychainFailure
    case enrollmentIndeterminate
    case invalidResponse
    case invalidURL
    case noBindingProof
    case sessionUnavailable
    case staleOperation
    case identityMismatch
    case http(status: Int, code: String?)

    /// Failures that may resolve on their own and never justify rotating the App Attest key.
    public var isTransient: Bool {
        if case .transientAppleFailure = self { return true }
        if case let .http(status, _) = self { return status >= 500 || status == 408 || status == 429 }
        return false
    }

    /// Failures where the cached bearer must be discarded before the next attempt.
    public var clearsSession: Bool {
        if case let .http(status, _) = self { return status == 401 || status == 403 }
        return self == .sessionUnavailable || self == .identityMismatch
    }

    public var errorDescription: String? {
        switch self {
        case .appAttestUnsupported: return "App Attest is not supported on this device."
        case .appAttestKeyInvalid: return "The App Attest key could not be used."
        case .appAttestFailure: return "The authenticated connection could not be established."
        case .transientAppleFailure: return "The authentication service is temporarily unavailable."
        case .keychainFailure: return "Secure authentication storage is unavailable."
        case .enrollmentIndeterminate: return "Authentication enrollment needs to be reconciled."
        case .invalidResponse: return "The authentication service returned an invalid response."
        case .invalidURL: return "The authentication service URL is invalid."
        case .noBindingProof: return "No verified binding proof is available."
        case .sessionUnavailable: return "The authenticated session is unavailable."
        case .staleOperation: return "The authentication operation was superseded."
        case .identityMismatch: return "The authenticated identity changed."
        case let .http(status, _):
            if status == 429 { return "The authentication service is rate limited." }
            if status >= 500 { return "The authentication service is temporarily unavailable." }
            return "The authentication service rejected the request."
        }
    }
}
