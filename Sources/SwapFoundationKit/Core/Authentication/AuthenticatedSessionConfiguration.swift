/****************************************************************************
 * AuthenticatedSessionConfiguration.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/
import CryptoKit
import Foundation

public struct AuthenticatedSessionConfiguration: Sendable {
    public let baseURL: URL
    public let appIdentifier: String
    public let environment: String
    public let storageKeys: AuthenticatedSessionStorageKeys
    public let appAttestEnabled: Bool
    public let operationTimeout: TimeInterval
    public let sessionFreshness: TimeInterval
    public let identityHeaderName: String
    public let authVersionHeaderName: String
    public let authVersion: String
    public let legacyMigration: AuthenticatedSessionLegacyMigration?

    public init(
        baseURL: URL,
        appIdentifier: String,
        environment: String,
        storageKeys: AuthenticatedSessionStorageKeys? = nil,
        appAttestEnabled: Bool = true,
        operationTimeout: TimeInterval = 15,
        sessionFreshness: TimeInterval = 30,
        identityHeaderName: String = "X-App-User-ID",
        authVersionHeaderName: String = "X-App-Auth-Version",
        authVersion: String = "1",
        legacyMigration: AuthenticatedSessionLegacyMigration? = nil
    ) {
        self.baseURL = baseURL
        self.appIdentifier = appIdentifier
        self.environment = environment
        self.storageKeys = storageKeys ?? Self.derivedKeys(
            baseURL: baseURL,
            appIdentifier: appIdentifier,
            environment: environment
        )
        self.appAttestEnabled = appAttestEnabled
        self.operationTimeout = max(0.1, operationTimeout)
        self.sessionFreshness = max(0, sessionFreshness)
        self.identityHeaderName = identityHeaderName
        self.authVersionHeaderName = authVersionHeaderName
        self.authVersion = authVersion
        self.legacyMigration = legacyMigration
    }

    /// Derives Keychain identifiers that keep apps, attestation environments and
    /// backend origins — including ports — in separate namespaces.
    private static func derivedKeys(
        baseURL: URL,
        appIdentifier: String,
        environment: String
    ) -> AuthenticatedSessionStorageKeys {
        let scheme = baseURL.scheme?.lowercased() ?? "unknown"
        let host = baseURL.host?.lowercased() ?? "unknown"
        let origin = "\(scheme)|\(host)|\(baseURL.port.map(String.init) ?? "default")"
        let digest = SHA256
            .hash(data: Data("\(appIdentifier)|\(environment)|\(origin)".utf8))
            .prefix(12)
            .map { String(format: "%02x", $0) }
            .joined()
        let prefix = "com.swapfoundationkit.auth.\(digest)"
        return AuthenticatedSessionStorageKeys(
            session: "\(prefix).session",
            enrollment: "\(prefix).enrollment",
            binding: "\(prefix).binding",
            pendingEnrollment: "\(prefix).pending",
            appAttestKeyID: "\(prefix).app-attest-key-id"
        )
    }
}
