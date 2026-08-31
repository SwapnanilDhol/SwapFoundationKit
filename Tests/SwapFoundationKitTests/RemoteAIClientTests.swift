/****************************************************************************
- RemoteAIClientTests.swift
- SwapFoundationKitTests
 *****************************************************************************/

import Foundation
import Testing

@testable import SwapFoundationKit
@testable import SwapFoundationKitRemoteAI

struct RemoteAIErrorTests {
    @Test
    func testRemoteAIError_mapsRequestShapeFailuresToInvalidRequest() {
        #expect(RemoteAIError.from(statusCode: 400) == .invalidRequest)
        #expect(RemoteAIError.from(statusCode: 415) == .invalidRequest)
        #expect(RemoteAIError.from(statusCode: 422) == .invalidRequest)
    }

    @Test
    func testRemoteAIError_mapsEntitlementAndRateLimitStatuses() {
        #expect(RemoteAIError.from(statusCode: 403) == .notEntitled)
        #expect(RemoteAIError.from(statusCode: 429) == .rateLimited)
    }

    @Test
    func testRemoteAIError_mapsServerErrorRangeToUnavailable() {
        #expect(RemoteAIError.from(statusCode: 500) == .unavailable)
        #expect(RemoteAIError.from(statusCode: 503) == .unavailable)
        #expect(RemoteAIError.from(statusCode: 599) == .unavailable)
    }

    @Test
    func testRemoteAIError_preservesUnrecognizedStatuses() {
        #expect(RemoteAIError.from(statusCode: 402) == .rejected(statusCode: 402))
        #expect(RemoteAIError.from(statusCode: 418) == .rejected(statusCode: 418))
    }
}

struct RemoteAIConfigurationTests {
    @Test
    func testConfiguration_derivesSchemeAndHostFromBaseURL() throws {
        let url = try #require(URL(string: "https://api.example.com"))
        let configuration = RemoteAIConfiguration(baseURL: url, path: "/v1/generate")

        #expect(configuration.scheme == "https")
        #expect(configuration.host == "api.example.com")
    }

    @Test
    func testConfiguration_keepsPortWhenPresent() throws {
        let url = try #require(URL(string: "http://localhost:8787"))
        let configuration = RemoteAIConfiguration(baseURL: url, path: "/v1/generate")

        #expect(configuration.scheme == "http")
        #expect(configuration.host == "localhost:8787")
    }

    @Test
    func testRequest_sendsJSONHeadersAlongsideCallerIdentity() throws {
        let url = try #require(URL(string: "https://api.example.com"))
        let configuration = RemoteAIConfiguration(
            baseURL: url,
            path: "/v1/generate",
            headersProvider: { ["X-App-User-ID": "user-1"] }
        )
        let request = RemoteAIRequest(configuration: configuration, payload: Data())
        let headers = try #require(request.headers)

        #expect(headers["X-App-User-ID"] == "user-1")
        #expect(headers["Accept"] == "application/json")
        #expect(headers["Content-Type"] == "application/json")
        #expect(request.method == .post)
    }

    @Test
    func testRequest_resolvesURLFromConfiguration() throws {
        let url = try #require(URL(string: "https://api.example.com"))
        let configuration = RemoteAIConfiguration(baseURL: url, path: "/v1/generate")
        let request = RemoteAIRequest(configuration: configuration, payload: Data())

        #expect(request.url?.absoluteString == "https://api.example.com/v1/generate")
    }

    @Test
    func testConfiguration_evaluatesHeadersPerRequest() throws {
        let url = try #require(URL(string: "https://api.example.com"))
        var token = "first"
        let configuration = RemoteAIConfiguration(
            baseURL: url,
            path: "/v1/generate",
            headersProvider: { ["X-Token": token] }
        )

        #expect(configuration.headersProvider()["X-Token"] == "first")
        token = "second"
        #expect(configuration.headersProvider()["X-Token"] == "second")
    }
}
