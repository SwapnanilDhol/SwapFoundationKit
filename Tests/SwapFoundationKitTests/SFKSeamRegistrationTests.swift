/*****************************************************************************
 * SFKSeamRegistrationTests.swift
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

/// Covers the two injection seams the default target exposes so opt-in products (like
/// `SwapFoundationKitPulse`) can instrument networking and logging without the default
/// target depending on any third-party vendor. See `SFKNetworkInstrumentation.swift` and
/// `SFKLogSink.swift`.
final class SFKSeamRegistrationTests: XCTestCase {
    override func tearDown() {
        SFKNetworkInstrumentation.resetForTesting()
        SFKLogSinkRegistry.resetForTesting()
        super.tearDown()
    }

    // MARK: - SFKNetworkInstrumentation

    func testNetworkInstrumentation_noRegistration_returnsPlainURLSession() {
        SFKNetworkInstrumentation.resetForTesting()

        let instrumented = SFKNetworkInstrumentation.makeSession(configuration: .ephemeral)

        XCTAssertTrue(instrumented.performer is URLSession)
        XCTAssertTrue((instrumented.performer as? URLSession) === instrumented.session)
    }

    func testNetworkInstrumentation_registeredFactory_isInvoked() {
        let factoryInvoked = expectation(description: "registered factory invoked")

        SFKNetworkInstrumentation.register { configuration in
            factoryInvoked.fulfill()
            let session = URLSession(configuration: configuration)
            return SFKInstrumentedSession(session: session, performer: session)
        }

        _ = SFKNetworkInstrumentation.makeSession(configuration: .ephemeral)

        wait(for: [factoryInvoked], timeout: 1.0)
    }

    // MARK: - SFKLogSinkRegistry

    func testLogSinkRegistry_noRegistration_isNoOp() {
        SFKLogSinkRegistry.resetForTesting()

        // Broadcasting with nothing registered must not crash and must not invoke anything.
        SFKLogSinkRegistry.broadcast(
            level: .info,
            message: "no sinks registered",
            context: "SeamTest",
            function: #function,
            file: #file,
            line: #line
        )
    }

    func testLogSinkRegistry_registeredSink_receivesBroadcast() {
        let sinkInvoked = expectation(description: "registered sink invoked")
        let sink = RecordingLogSink(expectation: sinkInvoked)

        SFKLogSinkRegistry.register(sink)
        SFKLogSinkRegistry.broadcast(
            level: .warning,
            message: "hello from a seam test",
            context: "SeamTest",
            function: #function,
            file: #file,
            line: #line
        )

        wait(for: [sinkInvoked], timeout: 1.0)

        XCTAssertEqual(sink.receivedMessage, "hello from a seam test")
        XCTAssertEqual(sink.receivedLevel, .warning)
    }
}

/// Test-only `SFKLogSink` that records the last message it received.
private final class RecordingLogSink: SFKLogSink, @unchecked Sendable {
    private let expectation: XCTestExpectation
    private(set) var receivedMessage: String?
    private(set) var receivedLevel: LogLevel?

    init(expectation: XCTestExpectation) {
        self.expectation = expectation
    }

    func record(
        level: LogLevel,
        message: String,
        context: String?,
        function: String,
        file: String,
        line: Int
    ) {
        receivedMessage = message
        receivedLevel = level
        expectation.fulfill()
    }
}
