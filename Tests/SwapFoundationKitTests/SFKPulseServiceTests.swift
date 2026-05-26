/*****************************************************************************
 * SFKPulseServiceTests.swift
 * SwapFoundationKit
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
@testable import SwapFoundationKit

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
}
#endif
