/*****************************************************************************
 * SFKNetworkInstrumentation.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import Foundation

/// Abstraction over `URLSession.data(for:)` so opt-in instrumentation layers (such as
/// `SwapFoundationKitPulse`) can proxy the requests `HTTPClient` executes without the
/// default target depending on any third-party vendor.
public protocol SFKURLSessionPerforming: Sendable {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)

    /// Executes a request with an optional task delegate. Performers that cannot honor a
    /// delegate must fail closed when one is supplied instead of silently following redirects
    /// without the delegate's policy. The default keeps existing custom performers source
    /// compatible for ordinary requests.
    func data(for request: URLRequest, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse)
}

public extension SFKURLSessionPerforming {
    func data(for request: URLRequest, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse) {
        guard delegate == nil else {
            throw URLError(.unsupportedURL)
        }
        return try await data(for: request)
    }
}

extension URLSession: SFKURLSessionPerforming {}

/// A concrete `URLSession` paired with the performer `HTTPClient` should use to execute requests.
/// `session` and `performer` are usually the same underlying object; they are split out so an
/// instrumentation layer can substitute a proxy for `performer` while still exposing a real
/// `URLSession` for callers (such as file downloads) that need one directly.
public struct SFKInstrumentedSession: Sendable {
    public let session: URLSession
    public let performer: any SFKURLSessionPerforming

    public init(session: URLSession, performer: any SFKURLSessionPerforming) {
        self.session = session
        self.performer = performer
    }
}

/// Registry that lets an opt-in product supply the session `HTTPClient` uses, without the
/// default `SwapFoundationKit` target depending on that product.
///
/// With nothing registered, `HTTPClient` behaves exactly as it always has: a plain
/// `URLSession(configuration:)` is used as both the session and the performer.
public enum SFKNetworkInstrumentation {
    private static let lock = NSLock()
    private static var factory: (@Sendable (URLSessionConfiguration) -> SFKInstrumentedSession)?

    /// Registers the factory used to build the `URLSession` (and its performer) for every
    /// new `HTTPClient` instance. Intended for opt-in integrations, such as
    /// `SwapFoundationKitPulse`, to call during their own configuration step.
    ///
    /// This is intentionally a function rather than a public mutable static property: it keeps
    /// the registration boundary explicit and prevents arbitrary call sites from silently
    /// mutating shared instrumentation state.
    public static func register(_ factory: @escaping @Sendable (URLSessionConfiguration) -> SFKInstrumentedSession) {
        lock.lock()
        defer { lock.unlock() }
        Self.factory = factory
    }

    public static func makeSession(configuration: URLSessionConfiguration) -> SFKInstrumentedSession {
        lock.lock()
        let registered = factory
        lock.unlock()

        if let registered {
            return registered(configuration)
        }

        let session = URLSession(configuration: configuration)
        return SFKInstrumentedSession(session: session, performer: session)
    }

    /// Test-only support to restore the default, un-instrumented behavior between test cases.
    /// Not part of the public API.
    static func resetForTesting() {
        lock.lock()
        factory = nil
        lock.unlock()
    }
}
