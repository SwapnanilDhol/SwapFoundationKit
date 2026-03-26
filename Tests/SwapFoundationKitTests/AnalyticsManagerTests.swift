/*****************************************************************************
 * AnalyticsManagerTests.swift
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

@MainActor
final class AnalyticsManagerTests: XCTestCase {
    private let manager = AnalyticsManager.shared

    override func setUp() {
        super.setUp()
        manager.clearGlobalParameters()
    }

    override func tearDown() {
        manager.clearGlobalParameters()
        super.tearDown()
    }

    func testLogEvent_UsesEventParameters_WhenNoGlobalParametersExist() {
        let logger = addMockLogger()
        let event = TestAnalyticsEvent(name: "screen_view", parameters: ["screen": "home"])

        manager.logEvent(event: event)

        XCTAssertEqual(logger.loggedEvents.count, 1)
        XCTAssertEqual(logger.loggedEvents[0].eventName, "screen_view")
        XCTAssertEqual(logger.loggedEvents[0].parameters, ["screen": "home"])
    }

    func testLogEvent_MergesGlobalParameters() {
        let logger = addMockLogger()
        let event = TestAnalyticsEvent(name: "screen_view", parameters: ["screen": "home"])
        manager.setGlobalParameters(["app_version": "1.0.0"])

        manager.logEvent(event: event)

        XCTAssertEqual(logger.loggedEvents.count, 1)
        XCTAssertEqual(
            logger.loggedEvents[0].parameters,
            ["screen": "home", "app_version": "1.0.0"]
        )
    }

    func testLogEvent_CallSiteParametersOverrideGlobal() {
        let logger = addMockLogger()
        let event = TestAnalyticsEvent(name: "app_opened", parameters: nil)
        manager.setGlobalParameters(["app_version": "1.0.0", "device": "iPhone"])

        manager.logEvent(event: event, parameters: ["app_version": "2.0.0"])

        XCTAssertEqual(logger.loggedEvents.count, 1)
        XCTAssertEqual(
            logger.loggedEvents[0].parameters,
            ["app_version": "2.0.0", "device": "iPhone"]
        )
    }

    func testLogEvent_GlobalOverridesEventDefaultParameters() {
        let logger = addMockLogger()
        let event = TestAnalyticsEvent(
            name: "screen_view",
            parameters: ["locale": "en_US", "screen": "home"]
        )
        manager.setGlobalParameters(["locale": "fr_FR"])

        manager.logEvent(event: event)

        XCTAssertEqual(logger.loggedEvents.count, 1)
        XCTAssertEqual(
            logger.loggedEvents[0].parameters,
            ["locale": "fr_FR", "screen": "home"]
        )
    }

    func testClearGlobalParameters_RemovesGlobalMetadataFromSubsequentEvents() {
        let logger = addMockLogger()
        let event = TestAnalyticsEvent(name: "screen_view", parameters: ["screen": "home"])
        manager.setGlobalParameters(["device": "iPhone"])

        manager.logEvent(event: event)
        manager.clearGlobalParameters()
        manager.logEvent(event: event)

        XCTAssertEqual(logger.loggedEvents.count, 2)
        XCTAssertEqual(logger.loggedEvents[0].parameters, ["screen": "home", "device": "iPhone"])
        XCTAssertEqual(logger.loggedEvents[1].parameters, ["screen": "home"])
    }

    private func addMockLogger() -> MockAnalyticsLogger {
        let logger = MockAnalyticsLogger()
        manager.addLogger(logger)
        return logger
    }
}

private struct TestAnalyticsEvent: AnalyticsEvent {
    let rawValue: String
    let parameters: [String: String]?

    init(name: String, parameters: [String: String]?) {
        self.rawValue = name
        self.parameters = parameters
    }
}

private final class MockAnalyticsLogger: AnalyticsLogger {
    struct LoggedEvent {
        let eventName: String
        let parameters: [String: String]?
    }

    private(set) var loggedEvents: [LoggedEvent] = []

    func logEvent(event: AnalyticsEvent, additionalParameters: [String: String]?) {
        loggedEvents.append(
            LoggedEvent(eventName: event.rawValue, parameters: additionalParameters)
        )
    }
}
