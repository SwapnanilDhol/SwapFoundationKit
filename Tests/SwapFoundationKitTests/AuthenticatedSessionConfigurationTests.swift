/****************************************************************************
 * AuthenticatedSessionConfigurationTests.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import Foundation
import XCTest
@testable import SwapFoundationKitAuthentication

final class AuthenticatedSessionConfigurationTests: XCTestCase {
    private let baseURL = URL(string: "https://auth.example.com:8443")!
    private let appIdentifier = "com.example.app"
    private let environment = "production"

    func testOmittedOptionsMatchExplicitDefaults() {
        let omitted = AuthenticatedSessionConfiguration(
            baseURL: baseURL,
            appIdentifier: appIdentifier,
            environment: environment
        )
        let explicit = AuthenticatedSessionConfiguration(
            baseURL: baseURL,
            appIdentifier: appIdentifier,
            environment: environment,
            options: .init(
                storageKeys: nil,
                appAttestEnabled: true,
                operationTimeout: 15,
                sessionFreshness: 30,
                identityHeaderName: "X-App-User-ID",
                authVersionHeaderName: "X-App-Auth-Version",
                authVersion: "1",
                legacyMigration: nil
            )
        )

        XCTAssertEqual(omitted.baseURL, explicit.baseURL)
        XCTAssertEqual(omitted.appIdentifier, explicit.appIdentifier)
        XCTAssertEqual(omitted.environment, explicit.environment)
        XCTAssertEqual(omitted.storageKeys, explicit.storageKeys)
        XCTAssertEqual(omitted.appAttestEnabled, explicit.appAttestEnabled)
        XCTAssertEqual(omitted.operationTimeout, explicit.operationTimeout)
        XCTAssertEqual(omitted.sessionFreshness, explicit.sessionFreshness)
        XCTAssertEqual(omitted.identityHeaderName, explicit.identityHeaderName)
        XCTAssertEqual(omitted.authVersionHeaderName, explicit.authVersionHeaderName)
        XCTAssertEqual(omitted.authVersion, explicit.authVersion)
        XCTAssertNil(omitted.legacyMigration)
        XCTAssertNil(explicit.legacyMigration)
    }

    func testNegativeTimeoutAndFreshnessAreClamped() {
        let configuration = AuthenticatedSessionConfiguration(
            baseURL: baseURL,
            appIdentifier: appIdentifier,
            environment: environment,
            options: .init(operationTimeout: -10, sessionFreshness: -1)
        )

        XCTAssertEqual(configuration.operationTimeout, 0.1)
        XCTAssertEqual(configuration.sessionFreshness, 0)
    }

    func testCustomOptionsAreRetained() throws {
        let keys = AuthenticatedSessionStorageKeys(
            session: "custom.session",
            enrollment: "custom.enrollment",
            binding: "custom.binding",
            pendingEnrollment: "custom.pending",
            appAttestKeyID: "custom.app-attest"
        )
        let migration = AuthenticatedSessionLegacyMigration(
            decodeEnrollment: { data in data == Data("enrolled".utf8) ? true : nil }
        )
        let configuration = AuthenticatedSessionConfiguration(
            baseURL: baseURL,
            appIdentifier: appIdentifier,
            environment: environment,
            options: .init(
                storageKeys: keys,
                appAttestEnabled: false,
                operationTimeout: 7.5,
                sessionFreshness: 12,
                identityHeaderName: "X-Custom-Identity",
                authVersionHeaderName: "X-Custom-Version",
                authVersion: "v4",
                legacyMigration: migration
            )
        )

        XCTAssertEqual(configuration.storageKeys, keys)
        XCTAssertFalse(configuration.appAttestEnabled)
        XCTAssertEqual(configuration.operationTimeout, 7.5)
        XCTAssertEqual(configuration.sessionFreshness, 12)
        XCTAssertEqual(configuration.identityHeaderName, "X-Custom-Identity")
        XCTAssertEqual(configuration.authVersionHeaderName, "X-Custom-Version")
        XCTAssertEqual(configuration.authVersion, "v4")
        let decoded = try XCTUnwrap(configuration.legacyMigration?.decodeEnrollment?(Data("enrolled".utf8)))
        XCTAssertTrue(decoded)
    }

    func testDerivedKeysPreservePreviousGoldenNamespace() {
        let configuration = AuthenticatedSessionConfiguration(
            baseURL: baseURL,
            appIdentifier: appIdentifier,
            environment: environment
        )
        let prefix = "com.swapfoundationkit.auth.fd5f7fb0d60dcfbc7768425f"

        XCTAssertEqual(configuration.storageKeys.session, "\(prefix).session")
        XCTAssertEqual(configuration.storageKeys.enrollment, "\(prefix).enrollment")
        XCTAssertEqual(configuration.storageKeys.binding, "\(prefix).binding")
        XCTAssertEqual(configuration.storageKeys.pendingEnrollment, "\(prefix).pending")
        XCTAssertEqual(configuration.storageKeys.appAttestKeyID, "\(prefix).app-attest-key-id")
    }

    func testDerivedKeysIsolateOriginApplicationAndEnvironment() {
        let originVariant = AuthenticatedSessionConfiguration(
            baseURL: URL(string: "https://auth.example.com:9443")!,
            appIdentifier: appIdentifier,
            environment: environment
        )
        let applicationVariant = AuthenticatedSessionConfiguration(
            baseURL: baseURL,
            appIdentifier: "com.other.app",
            environment: environment
        )
        let environmentVariant = AuthenticatedSessionConfiguration(
            baseURL: baseURL,
            appIdentifier: appIdentifier,
            environment: "staging"
        )
        let baseline = AuthenticatedSessionConfiguration(
            baseURL: baseURL,
            appIdentifier: appIdentifier,
            environment: environment
        )

        XCTAssertNotEqual(baseline.storageKeys, originVariant.storageKeys)
        XCTAssertNotEqual(baseline.storageKeys, applicationVariant.storageKeys)
        XCTAssertNotEqual(baseline.storageKeys, environmentVariant.storageKeys)
    }
}
