/*****************************************************************************
 * ExchangeRateManagerTransportTests.swift
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

/// Covers that `ExchangeRateManager` routes its ECB feed fetch through its injected
/// `ExchangeRateTransport` (not `URLSession.shared`), and that the specific `URLError`s
/// `performFetchWithRetry`'s retry logic keys off are preserved after that change.
final class ExchangeRateManagerTransportTests: XCTestCase {
    private static let validECBXML = """
    <?xml version="1.0" encoding="UTF-8"?>
    <Cube>
        <Cube time="2024-01-01">
            <Cube currency="USD" rate="1.2345"/>
            <Cube currency="GBP" rate="0.85"/>
        </Cube>
    </Cube>
    """

    func testHTTPClientExchangeRateTransportPreservesURLHeadersAndTimeout() async throws {
        defer {
            MockURLProtocol.mockResponse = nil
            MockURLProtocol.lastRequest = nil
        }
        let url = URL(string: "https://exchange.example.com/feed/%2Fdaily/?first=1&dup=a&dup=b&raw&last=#fragment")!
        MockURLProtocol.mockResponse = (
            data: Data(Self.validECBXML.utf8),
            response: HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!,
            error: nil
        )
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let client = HTTPClient(configuration: config)
        let transport = HTTPClientExchangeRateTransport(client: client)

        _ = try await transport.data(from: url)

        let request = try XCTUnwrap(MockURLProtocol.lastRequest)
        XCTAssertEqual(request.url?.absoluteString, url.absoluteString)
        XCTAssertEqual(request.timeoutInterval, 60, accuracy: 0.001)
        XCTAssertNil(request.value(forHTTPHeaderField: "Accept"))
        XCTAssertNil(request.value(forHTTPHeaderField: "Content-Type"))
    }

    func testFetchAndParseUsesInjectedTransportOnSuccess() async throws {
        let url = URL(string: "https://exchange.example.com/rates.xml")!
        let transport = FakeExchangeRateTransport(
            outcome: .success(data: Data(Self.validECBXML.utf8), statusCode: 200)
        )
        let manager = ExchangeRateManager(exchangeRateURL: url, transport: transport)

        try await manager.fetchAndParseForTesting()

        let callCount = await transport.callCount
        XCTAssertEqual(callCount, 1)
    }

    func testFetchAndParseThrowsBadServerResponseForNon2xxStatus() async {
        let url = URL(string: "https://exchange.example.com/rates.xml")!
        let transport = FakeExchangeRateTransport(
            outcome: .success(data: Data("not used".utf8), statusCode: 503)
        )
        let manager = ExchangeRateManager(exchangeRateURL: url, transport: transport)

        do {
            try await manager.fetchAndParseForTesting()
            XCTFail("Expected URLError(.badServerResponse)")
        } catch let urlError as URLError {
            XCTAssertEqual(urlError.code, .badServerResponse)
        } catch {
            XCTFail("Expected URLError, got \(error)")
        }
    }

    func testFetchAndParseMapsNetworkErrorHTTPErrorBackToBadServerResponse() async {
        // Simulates what `HTTPClientExchangeRateTransport` throws in production when `HTTPClient`
        // rejects a non-2xx response before `fetchAndParse` ever sees a status code.
        let url = URL(string: "https://exchange.example.com/rates.xml")!
        let transport = FakeExchangeRateTransport(
            outcome: .failure(NetworkError.httpError(statusCode: 500, data: nil))
        )
        let manager = ExchangeRateManager(exchangeRateURL: url, transport: transport)

        do {
            try await manager.fetchAndParseForTesting()
            XCTFail("Expected URLError(.badServerResponse)")
        } catch let urlError as URLError {
            XCTAssertEqual(urlError.code, .badServerResponse)
        } catch {
            XCTFail("Expected URLError, got \(error)")
        }
    }

    func testFetchAndParseThrowsCannotParseResponseForUnparseableBody() async {
        let url = URL(string: "https://exchange.example.com/rates.xml")!
        let transport = FakeExchangeRateTransport(
            outcome: .success(data: Data("this is not xml at all {}<<".utf8), statusCode: 200)
        )
        let manager = ExchangeRateManager(exchangeRateURL: url, transport: transport)

        do {
            try await manager.fetchAndParseForTesting()
            XCTFail("Expected URLError(.cannotParseResponse)")
        } catch let urlError as URLError {
            XCTAssertEqual(urlError.code, .cannotParseResponse)
        } catch {
            XCTFail("Expected URLError, got \(error)")
        }
    }

    func testFetchAndParsePreservesUnderlyingURLErrorFromTransportFailure() async {
        let url = URL(string: "https://exchange.example.com/rates.xml")!
        let transport = FakeExchangeRateTransport(
            outcome: .failure(NetworkError.requestFailed(URLError(.dnsLookupFailed)))
        )
        let manager = ExchangeRateManager(exchangeRateURL: url, transport: transport)

        do {
            try await manager.fetchAndParseForTesting()
            XCTFail("Expected URLError(.dnsLookupFailed)")
        } catch let urlError as URLError {
            XCTAssertEqual(urlError.code, .dnsLookupFailed)
        } catch {
            XCTFail("Expected URLError, got \(error)")
        }
    }
}

/// Test-only `ExchangeRateTransport` that records call count and returns a scripted outcome.
private actor FakeExchangeRateTransport: ExchangeRateTransport {
    enum Outcome {
        case success(data: Data, statusCode: Int)
        case failure(Error)
    }

    private(set) var callCount = 0
    private let outcome: Outcome

    init(outcome: Outcome) {
        self.outcome = outcome
    }

    func data(from url: URL) async throws -> (Data, HTTPURLResponse) {
        callCount += 1
        switch outcome {
        case .success(let data, let statusCode):
            let response = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
            return (data, response)
        case .failure(let error):
            throw error
        }
    }
}
