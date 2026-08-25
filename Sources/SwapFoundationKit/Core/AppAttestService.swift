/****************************************************************************
 * AppAttestService.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import CryptoKit
import DeviceCheck
import Foundation
import Security

/// The persisted App Attest key identifier for one app installation.
public protocol AppAttestKeyStore: Sendable {
    func loadKeyID() throws -> String?
    func saveKeyID(_ keyID: String) throws
    func removeKeyID() throws
}

/// A Keychain-backed store for the App Attest key identifier.
///
/// The key identifier is not a secret, but keeping it in a ThisDeviceOnly
/// Keychain item prevents an iCloud restore from moving an installation's
/// App Attest state to another device.
public final class KeychainAppAttestKeyStore: AppAttestKeyStore, @unchecked Sendable {
    private let key: String
    private let securityService: SecurityService

    public init(
        key: String = "com.swapfoundationkit.app-attest.key-id",
        securityService: SecurityService = SecurityService()
    ) {
        self.key = key
        self.securityService = securityService
    }

    public func loadKeyID() throws -> String? {
        do {
            let data = try securityService.retrieveFromKeychain(forKey: key)
            guard let value = String(data: data, encoding: .utf8), !value.isEmpty else {
                throw AppAttestError.invalidStoredKeyID
            }
            return value
        } catch let error as SecurityService.SecurityError {
            if case .keychainError(errSecItemNotFound) = error {
                return nil
            }
            throw error
        }
    }

    public func saveKeyID(_ keyID: String) throws {
        guard !keyID.isEmpty, let data = keyID.data(using: .utf8) else {
            throw AppAttestError.invalidStoredKeyID
        }
        try securityService.storeInKeychain(
            data,
            forKey: key,
            accessibility: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        )
    }

    public func removeKeyID() throws {
        do {
            try securityService.removeFromKeychain(forKey: key)
        } catch let error as SecurityService.SecurityError {
            if case .keychainError(errSecItemNotFound) = error {
                return
            }
            throw error
        }
    }
}

/// A transport-ready App Attest attestation payload.
public struct AppAttestAttestation: Codable, Sendable, Equatable {
    public let keyID: String
    public let attestationObject: Data
    public let clientDataHash: Data

    public init(keyID: String, attestationObject: Data, clientDataHash: Data) {
        self.keyID = keyID
        self.attestationObject = attestationObject
        self.clientDataHash = clientDataHash
    }
}

/// A transport-ready App Attest assertion payload.
public struct AppAttestAssertion: Codable, Sendable, Equatable {
    public let keyID: String
    public let assertion: Data
    public let clientDataHash: Data

    public init(keyID: String, assertion: Data, clientDataHash: Data) {
        self.keyID = keyID
        self.assertion = assertion
        self.clientDataHash = clientDataHash
    }
}

/// Errors raised while creating App Attest credentials or assertions.
public enum AppAttestError: Error, LocalizedError, Sendable, Equatable {
    case unsupported
    case invalidClientData
    case invalidStoredKeyID
    case keyGenerationFailed
    case attestationFailed
    case assertionFailed
    case keyStoreFailure

    public var errorDescription: String? {
        switch self {
        case .unsupported:
            return "App Attest is not supported on this device."
        case .invalidClientData:
            return "App Attest client data must not be empty."
        case .invalidStoredKeyID:
            return "The stored App Attest key identifier is invalid."
        case .keyGenerationFailed:
            return "The App Attest key could not be generated."
        case .attestationFailed:
            return "The App Attest key could not be attested."
        case .assertionFailed:
            return "The App Attest assertion could not be generated."
        case .keyStoreFailure:
            return "The App Attest key identifier could not be stored."
        }
    }
}

/// A small, reusable client-side boundary around Apple's App Attest service.
///
/// The caller owns the challenge flow and the server policy. Pass the exact
/// opaque bytes that the server issued as `clientData`; this type hashes those
/// bytes once with SHA-256 before handing them to Apple's API. It never knows
/// about RevenueCat, entitlements, backend URLs, or app-specific user models.
public protocol AppAttestProviding: Sendable {
    func isSupported() async -> Bool
    func keyID() async throws -> String
    func attest(clientData: Data) async throws -> AppAttestAttestation
    func assertion(clientData: Data) async throws -> AppAttestAssertion
    func resetKey() async throws
}

/// Actor-isolated App Attest client suitable for app and background-task use.
public actor AppAttestService: AppAttestProviding {
    private let service: DCAppAttestService
    private let keyStore: any AppAttestKeyStore
    private var cachedKeyID: String?

    public init(
        service: DCAppAttestService = .shared,
        keyStore: any AppAttestKeyStore = KeychainAppAttestKeyStore()
    ) {
        self.service = service
        self.keyStore = keyStore
    }

    public func isSupported() async -> Bool {
        service.isSupported
    }

    public func keyID() async throws -> String {
        try ensureSupported()

        if let cachedKeyID {
            return cachedKeyID
        }

        do {
            if let storedKeyID = try keyStore.loadKeyID() {
                cachedKeyID = storedKeyID
                return storedKeyID
            }
        } catch is AppAttestError {
            throw AppAttestError.invalidStoredKeyID
        } catch {
            throw AppAttestError.keyStoreFailure
        }

        let generatedKeyID: String
        do {
            generatedKeyID = try await withCheckedThrowingContinuation { continuation in
                service.generateKey { keyID, error in
                    guard let keyID, !keyID.isEmpty else {
                        continuation.resume(throwing: error ?? AppAttestError.keyGenerationFailed)
                        return
                    }
                    continuation.resume(returning: keyID)
                }
            }
        } catch {
            throw AppAttestError.keyGenerationFailed
        }

        do {
            try keyStore.saveKeyID(generatedKeyID)
        } catch {
            throw AppAttestError.keyStoreFailure
        }

        cachedKeyID = generatedKeyID
        return generatedKeyID
    }

    public func attest(clientData: Data) async throws -> AppAttestAttestation {
        guard !clientData.isEmpty else { throw AppAttestError.invalidClientData }
        let keyID = try await keyID()
        let clientDataHash = Data(SHA256.hash(data: clientData))

        do {
            let attestationObject = try await withCheckedThrowingContinuation {
                (continuation: CheckedContinuation<Data, Error>) in
                service.attestKey(keyID, clientDataHash: clientDataHash) { data, error in
                    guard let data, !data.isEmpty else {
                        continuation.resume(throwing: error ?? AppAttestError.attestationFailed)
                        return
                    }
                    continuation.resume(returning: data)
                }
            }
            return AppAttestAttestation(
                keyID: keyID,
                attestationObject: attestationObject,
                clientDataHash: clientDataHash
            )
        } catch {
            throw AppAttestError.attestationFailed
        }
    }

    public func assertion(clientData: Data) async throws -> AppAttestAssertion {
        guard !clientData.isEmpty else { throw AppAttestError.invalidClientData }
        let keyID = try await keyID()
        let clientDataHash = Data(SHA256.hash(data: clientData))

        do {
            let assertion = try await withCheckedThrowingContinuation {
                (continuation: CheckedContinuation<Data, Error>) in
                service.generateAssertion(keyID, clientDataHash: clientDataHash) { data, error in
                    guard let data, !data.isEmpty else {
                        continuation.resume(throwing: error ?? AppAttestError.assertionFailed)
                        return
                    }
                    continuation.resume(returning: data)
                }
            }
            return AppAttestAssertion(
                keyID: keyID,
                assertion: assertion,
                clientDataHash: clientDataHash
            )
        } catch {
            throw AppAttestError.assertionFailed
        }
    }

    public func resetKey() async throws {
        do {
            try keyStore.removeKeyID()
        } catch {
            throw AppAttestError.keyStoreFailure
        }
        cachedKeyID = nil
    }

    private func ensureSupported() throws {
        guard service.isSupported else { throw AppAttestError.unsupported }
    }
}
