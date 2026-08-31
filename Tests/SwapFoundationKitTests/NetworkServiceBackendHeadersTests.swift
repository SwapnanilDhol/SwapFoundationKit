/*****************************************************************************
 * NetworkServiceBackendHeadersTests.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import XCTest
@testable import SwapFoundationKit

/// Covers `NetworkService.performRequest`'s origin-scoped merge of `backendDefaultHeaders`
/// (see `SFKBackendOriginRegistry`): headers must only reach requests whose origin was explicitly
/// registered, and per-request headers must keep winning over backend defaults.
@MainActor
final class NetworkServiceBackendHeadersTests: XCTestCase {
    var client: HTTPClient!

    override func setUp() async throws {
        try await super.setUp()
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        client = HTTPClient(configuration: config)
    }

    override func tearDown() async throws {
        client = nil
        MockURLProtocol.mockResponse = nil
        MockURLProtocol.lastRequest = nil
        NetworkService.backendHeadersProvider = nil
        SFKBackendOriginRegistry.resetForTesting()
        try await super.tearDown()
    }

    private func stubOK(for url: URL) {
        MockURLProtocol.mockResponse = (
            data: Data("ok".utf8),
            response: HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!,
            error: nil
        )
    }

    func testBackendHeadersAppliedForRegisteredOrigin() async throws {
        NetworkService.backendHeadersProvider = { ["X-App-User-ID": "user-123"] }
        NetworkService.registerBackendOrigin(host: "api.example.com")

        let url = URL(string: "https://api.example.com/ping")!
        stubOK(for: url)

        let service = NetworkService(client: client)
        _ = try await service.get(from: url)

        XCTAssertEqual(MockURLProtocol.lastRequest?.value(forHTTPHeaderField: "X-App-User-ID"), "user-123")
    }

    func testBackendHeadersNotAppliedForUnregisteredThirdPartyOrigin() async throws {
        NetworkService.backendHeadersProvider = { ["X-App-User-ID": "user-123"] }
        NetworkService.registerBackendOrigin(host: "api.example.com")

        let url = URL(string: "https://third-party-analytics.example.com/track")!
        stubOK(for: url)

        let service = NetworkService(client: client)
        _ = try await service.get(from: url)

        XCTAssertNil(MockURLProtocol.lastRequest?.value(forHTTPHeaderField: "X-App-User-ID"))
    }

    func testBackendHeadersNotAppliedWhenNoOriginIsRegisteredAtAll() async throws {
        NetworkService.backendHeadersProvider = { ["X-App-User-ID": "user-123"] }
        // No call to registerBackendOrigin at all — must not silently apply headers everywhere.

        let url = URL(string: "https://api.example.com/ping")!
        stubOK(for: url)

        let service = NetworkService(client: client)
        _ = try await service.get(from: url)

        XCTAssertNil(MockURLProtocol.lastRequest?.value(forHTTPHeaderField: "X-App-User-ID"))
    }

    func testCallerSuppliedHeaderWinsOverBackendDefault() async throws {
        NetworkService.backendHeadersProvider = { ["X-App-User-ID": "from-provider"] }
        NetworkService.registerBackendOrigin(host: "api.example.com")

        let url = URL(string: "https://api.example.com/ping")!
        stubOK(for: url)

        let service = NetworkService(client: client)
        _ = try await service.get(from: url, headers: ["X-App-User-ID": "caller-override"])

        XCTAssertEqual(MockURLProtocol.lastRequest?.value(forHTTPHeaderField: "X-App-User-ID"), "caller-override")
    }

    func testBackendHeadersRespectRegisteredPort() async throws {
        NetworkService.backendHeadersProvider = { ["X-App-User-ID": "user-123"] }
        NetworkService.registerBackendOrigin(host: "api.example.com", scheme: "https", port: 8443)

        // Same host/scheme, but no port match.
        let url = URL(string: "https://api.example.com/ping")!
        stubOK(for: url)

        let service = NetworkService(client: client)
        _ = try await service.get(from: url)

        XCTAssertNil(MockURLProtocol.lastRequest?.value(forHTTPHeaderField: "X-App-User-ID"))
    }

    func testNoBackendHeadersWhenProviderIsNilEvenWithRegisteredOrigin() async throws {
        // Provider not set at all.
        NetworkService.registerBackendOrigin(host: "api.example.com")

        let url = URL(string: "https://api.example.com/ping")!
        stubOK(for: url)

        let service = NetworkService(client: client)
        _ = try await service.get(from: url)

        XCTAssertNil(MockURLProtocol.lastRequest?.value(forHTTPHeaderField: "X-App-User-ID"))
    }
}
