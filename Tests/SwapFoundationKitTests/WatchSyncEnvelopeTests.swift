/*****************************************************************************
 * WatchSyncEnvelopeTests.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import XCTest
@testable import SwapFoundationKit

final class WatchSyncEnvelopeTests: XCTestCase {
    func testMakeAndDecodePayload() throws {
        let model = MockProfile(id: "1", name: "SFK")

        let envelope = try WatchSyncEnvelope.make(model)
        let decoded: MockProfile = try envelope.decodePayload(MockProfile.self)

        XCTAssertEqual(envelope.identifier, MockProfile.syncIdentifier)
        XCTAssertEqual(decoded, model)
        XCTAssertEqual(envelope.version, 1)
    }

    func testDecodePayloadThrowsForIdentifierMismatch() throws {
        let payload = try JSONEncoder().encode(MockProfile(id: "1", name: "SFK"))
        let envelope = WatchSyncEnvelope(identifier: "other_identifier", payload: payload)

        XCTAssertThrowsError(try envelope.decodePayload(MockProfile.self)) { error in
            guard case WatchSyncError.identifierMismatch = error else {
                XCTFail("Expected identifier mismatch error")
                return
            }
        }
    }
}

private struct MockProfile: SyncableData, Equatable {
    let id: String
    let name: String

    static let syncIdentifier = "mock_profile"
}
