/*****************************************************************************
 * SFKPulseServiceTests.swift
 * SwapFoundationKitPulseTests
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import XCTest
import Combine
#if canImport(Pulse)
import Pulse
#endif
#if canImport(PulseProxy)
import PulseProxy
#endif
@testable import SwapFoundationKit
@testable import SwapFoundationKitNetworking
@testable import SwapFoundationKitPulse

#if canImport(Pulse)
final class SFKPulseServiceTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    func testConfigureEnablesPulseAndForwardsLoggerMessages() {
        let storeURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)

        let expectation = expectation(description: "Pulse receives logger message")
        var receivedMessage: LoggerStore.Event.MessageCreated?

        SFKPulseService.configure(
            SFKPulseConfiguration(
                storeLocation: .custom(storeURL),
                networkCaptureMode: .disabled
            )
        )

        LoggerStore.shared.events
            .sink { event in
                guard case .messageStored(let message) = event else { return }
                receivedMessage = message
                expectation.fulfill()
            }
            .store(in: &cancellables)

        Logger.info("Testing Pulse bridge", context: "UnitTest")

        wait(for: [expectation], timeout: 2.0)

        XCTAssertTrue(SFKPulseService.isEnabled)
        XCTAssertEqual(receivedMessage?.label, "UnitTest")
        XCTAssertEqual(receivedMessage?.message, "Testing Pulse bridge")
        XCTAssertEqual(receivedMessage?.level, .info)
    }

    func testHTTPClientUsesMockingProtocolWhenPulseNetworkingIsEnabled() {
        SFKPulseService.configure(
            SFKPulseConfiguration(networkCaptureMode: .sfkHTTPClientOnly)
        )

        let client = HTTPClient(configuration: .ephemeral)
        let protocolClasses = client.session.configuration.protocolClasses ?? []

        XCTAssertTrue(protocolClasses.contains { NSStringFromClass($0).contains("MockingURLProtocol") })
    }

    func testURLSessionProxyHonorsDelegateExecutionWitness() async throws {
        SFKPulseService.configure(
            SFKPulseConfiguration(networkCaptureMode: .sfkHTTPClientOnly)
        )

        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [PulseTransportURLProtocol.self]
        let instrumented = SFKNetworkInstrumentation.makeSession(configuration: configuration)
        let request = URLRequest(url: URL(string: "https://pulse.example.com/ping")!)

        // A legacy performer would hit SFKURLSessionPerforming's fail-closed default here. A
        // successful response proves URLSessionProxy's concrete delegate overload is selected.
        let (data, _) = try await instrumented.performer.data(
            for: request,
            delegate: PulseTaskDelegate()
        )

        XCTAssertEqual(data, Data("ok".utf8))
    }
}

private final class PulseTaskDelegate: NSObject, URLSessionTaskDelegate {}

private final class PulseTransportURLProtocol: URLProtocol {
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: Data("ok".utf8))
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
#endif
