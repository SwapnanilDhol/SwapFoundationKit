/****************************************************************************
 * AuthenticatedSessionExtractionTests.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import Foundation
import Testing
@testable import SwapFoundationKit

@Suite(.serialized, .timeLimit(.minutes(1)))
struct AuthenticatedSessionExtractionTests {
    @Test func coldStartCoalescesTwentyCallers() async throws {
        let context = TestContext()
        let service = context.makeService()
        try await withThrowingTaskGroup(of: AuthenticatedSessionCredential.self) { group in
            for _ in 0..<20 { group.addTask { try await service.currentSession() } }
            for try await credential in group { #expect(credential.token == "token-1") }
        }
        #expect(await context.attest.assertionCount == 1)
        #expect(await context.backend.count(path: "session") == 1)
    }

    @Test func validCachedSessionDoesNotGenerateAssertion() async throws {
        let context = TestContext()
        let cached = AuthenticatedSessionCredential(token: "cached", expiresAt: context.clock.now.addingTimeInterval(120), keyID: "key-1", identity: "customer-1")
        context.storage.set(cached, forKey: context.config.storageKeys.session)
        let credential = try await context.makeService().currentSession()
        #expect(credential.token == "cached")
        #expect(await context.attest.assertionCount == 0)
    }

    @Test func expiryRefreshesBeforeBearerIsReturned() async throws {
        let context = TestContext()
        context.storage.set(AuthenticatedSessionCredential(token: "expired", expiresAt: context.clock.now.addingTimeInterval(5), keyID: "key-1", identity: "customer-1"), forKey: context.config.storageKeys.session)
        context.storage.setRaw(Data(#""enrolled""#.utf8), forKey: context.config.storageKeys.enrollment)
        #expect((try await context.makeService().currentSession()).token == "token-1")
        #expect(await context.attest.assertionCount == 1)
    }

    @Test func identityChangeCannotPersistOldSession() async throws {
        let context = TestContext()
        let service = context.makeService()
        #expect((try await service.currentSession()).identity == "customer-1")
        context.identity.value = "customer-2"
        #expect((try await service.currentSession()).identity == "customer-2")
    }

    @Test func cancellationDoesNotCancelSharedAuthentication() async throws {
        let context = TestContext()
        await context.backend.setBlockSession(true)
        let service = context.makeService()
        let cancelled = Task { try await service.currentSession() }
        #expect(await context.backend.waitUntilSessionRequested())
        cancelled.cancel()
        await #expect(throws: CancellationError.self) { try await cancelled.value }
        let survivor = Task { try await service.currentSession() }
        await context.backend.setBlockSession(false)
        #expect((try await survivor.value).token == "token-1")
    }

    @Test func strictBindingCoalescesTwentyCallers() async throws {
        let context = TestContext()
        let service = context.makeService(proof: FixedProof())
        try await withThrowingTaskGroup(of: AuthenticatedSessionCredential.self) { group in
            for _ in 0..<20 { group.addTask { try await service.currentSession(requireBinding: true) } }
            for try await credential in group { #expect(credential.token.hasPrefix("token-")) }
        }
        #expect(await context.backend.count(path: "bind") == 1)
    }

    @Test func explicitPurchaseInvalidationForcesServerBindingAgain() async throws {
        let context = TestContext(); let service = context.makeService(proof: FixedProof())
        _ = try await service.currentSession(requireBinding: true); try await service.invalidateBinding(); _ = try await service.currentSession(requireBinding: true)
        #expect(await context.backend.count(path: "bind") == 2)
    }

    @Test func repeatedPurchaseCallbackWithSameProofIsDeduplicated() async throws {
        let context = TestContext(); let service = context.makeService(proof: FixedProof())
        await service.bindCurrentProofIfPossible(); await service.bindCurrentProofIfPossible()
        #expect(await context.backend.count(path: "bind") == 1)
    }

    @Test func changedPurchaseFingerprintBindsAgain() async throws {
        let context = TestContext(); let proof = MutableProof(); let service = context.makeService(proof: proof)
        await service.bindCurrentProofIfPossible(); await proof.setTransactionID("transaction-2"); await service.bindCurrentProofIfPossible()
        #expect(await context.backend.count(path: "bind") == 2)
    }

    @Test func lostEnrollmentResponseReconcilesWithoutReattestationOrReset() async throws {
        let context = TestContext(); await context.backend.setLostEnrollmentResponse(true); let service = context.makeService()
        await #expect(throws: (any Error).self) { _ = try await service.currentSession() }
        #expect((try await service.currentSession()).token == "token-1")
        #expect(await context.attest.attestationCount == 1)
        #expect(await context.backend.count(path: "enroll") == 2)
    }

    @Test func transientAppleEnrollmentRetriesSameClientData() async throws {
        let context = TestContext(); await context.attest.setTransientAttestationFailures(1)
        _ = try await context.makeService().currentSession()
        #expect(await context.attest.attestationCount == 2)
        let values = await context.attest.attestationClientData
        #expect(values.count == 2 && values[0] == values[1])
    }

    @Test func malformedLegacySessionIsDroppedWithoutBorrowingCurrentIdentity() async throws {
        let context = TestContext(); context.storage.setRaw(Data(#"{"token":"old","expiresAt":3000001000,"appUserID":"customer-1"}"#.utf8), forKey: context.config.storageKeys.session)
        #expect((try await context.makeService().currentSession()).token == "token-1")
    }

    @Test func portChangeUsesAnIsolatedAuthenticationNamespace() async throws {
        let context = TestContext(); _ = try await context.makeService().currentSession()
        let other = TestContext(baseURL: URL(string: "https://staging.example.test:8443")!)
        _ = try await other.makeService().currentSession()
        #expect(context.config.storageKeys.session != other.config.storageKeys.session)
    }

    @Test func deadlineWaiterDoesNotStartAnotherAppleOperation() async throws {
        let context = TestContext(); await context.attest.setHoldAssertions(true)
        let service = context.makeService(sleeper: ImmediateSleeper())
        let first = Task { try await service.currentSession() }
        #expect(await context.attest.waitUntilAssertionStarted())
        await #expect(throws: (any Error).self) { _ = try await first.value }
        let second = Task { try await service.currentSession() }
        await #expect(throws: (any Error).self) { _ = try await second.value }
        #expect(await context.attest.assertionCount == 1)
        await context.attest.setHoldAssertions(false); await context.attest.releaseAssertion()
    }

    @Test func expiredPendingWithDefinitiveNotEnrolledResetsKeyOnce() async throws {
        let context = TestContext(); context.setPending(expired: true); await context.backend.setSessionNotEnrolledOnce(true)
        #expect((try await context.makeService().currentSession()).token == "token-1")
        #expect(await context.attest.resetCount == 1)
        #expect(await context.attest.attestationCount == 1)
        #expect(await context.backend.count(path: "enroll") == 1)
    }

    @Test func unboundSessionNullIdentityUsesCapturedRequestIdentity() async throws {
        let context = TestContext(); await context.backend.setNullSessionIdentity(true)
        #expect((try await context.makeService().currentSession()).identity == "customer-1")
    }

    @Test func lateSuccessfulAttestationIsPersistedAndReplayedExactly() async throws {
        let context = TestContext(); await context.attest.setHoldAttestation(true)
        let service = context.makeService(sleeper: AdvancingSleeper(clock: context.clock, attest: context.attest, advanceBy: 20))
        let first = Task { try await service.currentSession() }
        #expect(await context.attest.waitUntilAttestationStarted()); await #expect(throws: (any Error).self) { _ = try await first.value }
        await context.attest.setHoldAttestation(false); await context.attest.releaseAttestation()
        #expect(await context.storage.waitUntilData(forKey: context.config.storageKeys.pendingEnrollment))
        #expect(await context.attest.attestationCount == 1)
        #expect(await context.backend.count(path: "enroll") == 0)

        await context.backend.setSessionNotEnrolledOnce(true)
        #expect((try await service.currentSession()).token == "token-1")
        #expect(await context.attest.attestationCount == 1)
        #expect(await context.backend.count(path: "enroll") == 1)
    }

    @Test func invalidationDuringAttestationRetainsReplayArtifactForSameIdentity() async throws {
        let context = TestContext(); await context.attest.setHoldAttestation(true); let service = context.makeService(sleeper: ImmediateSleeper())
        let first = Task { try await service.currentSession() }; #expect(await context.attest.waitUntilAttestationStarted()); await service.invalidateSession()
        await context.attest.setHoldAttestation(false); await context.attest.releaseAttestation(); await #expect(throws: (any Error).self) { _ = try await first.value }
        #expect(await context.storage.waitUntilData(forKey: context.config.storageKeys.pendingEnrollment))
    }

    @Test func identityChangeDuringAttestationReplaysInstallationArtifactWithoutReattestation() async throws {
        let context = TestContext(); await context.attest.setHoldAttestation(true); let service = context.makeService(sleeper: ImmediateSleeper())
        let first = Task { try await service.currentSession() }; #expect(await context.attest.waitUntilAttestationStarted()); context.identity.value = "customer-2"
        await context.attest.setHoldAttestation(false); await context.attest.releaseAttestation(); await #expect(throws: (any Error).self) { _ = try await first.value }
        #expect(await context.storage.waitUntilData(forKey: context.config.storageKeys.pendingEnrollment))
    }

    @Test func expiredPendingResetIsCooldownBounded() async throws {
        let context = TestContext(); context.setPending(expired: true); await context.backend.setSessionNotEnrolledOnce(true)
        let service = context.makeService()
        _ = try await service.currentSession()
        #expect(await context.attest.resetCount == 1)

        await service.invalidateSession()
        context.setPending(expired: true, keyID: "key-2"); await context.backend.setSessionNotEnrolledOnce(true)
        await #expect(throws: (any Error).self) { _ = try await service.currentSession() }
        #expect(await context.attest.resetCount == 1)
    }

    @Test func nullUnboundSessionCanBeFollowedByStrictBinding() async throws {
        let context = TestContext(); await context.backend.setNullSessionIdentity(true); let service = context.makeService(proof: FixedProof())
        _ = try await service.currentSession(); _ = try await service.currentSession(requireBinding: true); #expect(await context.backend.count(path: "bind") == 1)
    }

    @Test func enrolledAssertionKeyInvalidResetsOnceForLostLocalKey() async throws {
        let context = TestContext(); context.storage.setRaw(Data(#""enrolled""#.utf8), forKey: context.config.storageKeys.enrollment); await context.attest.setInvalidAssertionFailures(1)
        _ = try await context.makeService().currentSession(); #expect(await context.attest.resetCount == 1)
    }

    @Test func bindAuthRequiredRefreshesSessionAndRetriesExactProofOnce() async throws {
        let context = TestContext(); await context.backend.setBindAuthRequiredOnce(true); let service = context.makeService(proof: FixedProof())
        _ = try await service.currentSession(requireBinding: true); #expect(await context.backend.count(path: "session") == 2); #expect(await context.backend.count(path: "bind") == 2)
    }

    @Test func interruptedBeforeAttestationRecoversMissingPendingArtifact() async throws {
        let context = TestContext(); context.setEnrollmentPending(); await context.backend.setSessionNotEnrolledOnce(true)
        _ = try await context.makeService().currentSession()
        #expect(await context.attest.resetCount == 1)
        #expect(await context.attest.attestationCount == 1)
    }

    @Test func lostAttestationArtifactRecoversOnlyAfterTypedInvalidKey() async throws {
        let context = TestContext(); context.setEnrollmentPending(); await context.attest.markCurrentKeyAttested(); await context.attest.setInvalidAssertionFailures(1)
        _ = try await context.makeService().currentSession()
        #expect(await context.attest.resetCount == 1)
        #expect(await context.attest.attestationCount == 1)
    }

    @Test func twoTransientAppleAttemptsPreservePendingReconciliation() async throws {
        let context = TestContext(); await context.attest.setTransientAttestationFailures(2); await #expect(throws: (any Error).self) { _ = try await context.makeService().currentSession() }
        #expect(await context.attest.attestationCount == 2); #expect(context.storage.isPending(forKey: context.config.storageKeys.enrollment))
    }

    @Test func pendingArtifactStoreFailurePreservesMissingArtifactRecovery() async throws {
        let context = TestContext(); context.storage.failNextStore(forKey: context.config.storageKeys.pendingEnrollment)
        await #expect(throws: (any Error).self) { _ = try await context.makeService().currentSession() }
        #expect(context.storage.isPending(forKey: context.config.storageKeys.enrollment))
    }

    @Test func fingerprintDoesNotCollapseTupleBoundaries() {
        #expect(SessionBindingProof.fingerprint(parts: ["a", "bc"]) != SessionBindingProof.fingerprint(parts: ["ab", "c"]))
    }

    @Test func namespacesSeparateApplicationsEnvironmentsAndPorts() {
        let first = AuthenticatedSessionConfiguration(baseURL: URL(string: "https://auth.example.test:443")!, appIdentifier: "app.one", environment: "production")
        let second = AuthenticatedSessionConfiguration(baseURL: URL(string: "https://auth.example.test:8443")!, appIdentifier: "app.two", environment: "staging")
        #expect(first.storageKeys != second.storageKeys)
    }

    @Test func hostLegacyBindingDecoderReturnsOnlyGenericMetadata() throws {
        let migration = AuthenticatedSessionLegacyMigration(decodeBinding: { data in
            guard let value = try? JSONSerialization.jsonObject(with: data) as? [String: String], let key = value["keyID"], let identity = value["appUserID"] else { return nil }
            return AuthenticatedSessionBindingMetadata(keyID: key, identity: identity, fingerprint: "fingerprint")
        })
        let data = try JSONSerialization.data(withJSONObject: ["keyID": "key", "appUserID": "customer"])
        let metadata = try #require(try migration.decodeBinding?(data)); #expect(metadata.identity == "customer")
    }

    @Test func backendChallengeUsesExactPurposeAndHeaders() async throws {
        let transport = RecordingHTTPTransport(responses: [AuthenticatedSessionHTTPResponse(data: Data(#"{"challenge":"c","expiresAt":3000000100}"#.utf8), statusCode: 200)])
        let backend = AppAttestSessionHTTPBackend(baseURL: URL(string: "https://auth.example.test")!, transport: transport)
        let result = try await backend.challenge(purpose: "enroll", identity: "customer", deadline: Date(timeIntervalSince1970: 3_000_000_000))
        #expect(result.value == "c")
        let request = try #require(await transport.requests.first)
        #expect(request.url?.absoluteString == "https://auth.example.test/v1/auth/challenge?purpose=enroll")
        #expect(request.httpMethod == "POST")
        #expect(request.value(forHTTPHeaderField: "X-App-User-ID") == "customer")
        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
    }

    @Test func backendEnrollmentEncodesAttestationAsBase64() async throws {
        let transport = RecordingHTTPTransport(responses: [AuthenticatedSessionHTTPResponse(data: Data("{}".utf8), statusCode: 200)])
        let backend = AppAttestSessionHTTPBackend(baseURL: URL(string: "https://auth.example.test")!, transport: transport)
        try await backend.enroll(challenge: AuthenticatedSessionChallenge(value: "challenge", expiresAt: Date().addingTimeInterval(30)), keyID: "key", attestationObject: Data([1, 2]), identity: "customer", deadline: Date().addingTimeInterval(30))
        let request = try #require(await transport.requests.first); let body = try #require(request.httpBody)
        let object = try #require(try JSONSerialization.jsonObject(with: body) as? [String: String])
        #expect(object["attestation"] == Data([1, 2]).base64EncodedString()); #expect(object["challenge"] == "challenge"); #expect(object["keyID"] == "key")
    }

    @Test func backendSessionResponseKeepsCapturedIdentityWhenServerOmitsIt() async throws {
        let transport = RecordingHTTPTransport(responses: [AuthenticatedSessionHTTPResponse(data: Data(#"{"token":"bearer","expiresAt":3000000100}"#.utf8), statusCode: 200)])
        let backend = AppAttestSessionHTTPBackend(baseURL: URL(string: "https://auth.example.test")!, transport: transport)
        let credential = try await backend.issueSession(challenge: AuthenticatedSessionChallenge(value: "challenge", expiresAt: Date().addingTimeInterval(30)), keyID: "key", assertion: Data([2]), identity: "customer", deadline: Date(timeIntervalSince1970: 3_000_000_000))
        #expect(credential.identity == "customer"); #expect(credential.token == "bearer")
    }

    @Test func backendBindingPreservesRawPurchaseProofAndBearer() async throws {
        let transport = RecordingHTTPTransport(responses: [AuthenticatedSessionHTTPResponse(data: Data("{}".utf8), statusCode: 200)])
        let backend = AppAttestSessionHTTPBackend(baseURL: URL(string: "https://auth.example.test")!, transport: transport)
        let proof = SessionBindingProof(identity: "customer", fingerprint: "fingerprint", encodedPayload: Data(#"{"transaction":"t","verified":true}"#.utf8))
        let credential = AuthenticatedSessionCredential(token: "bearer", expiresAt: Date().addingTimeInterval(30), keyID: "key", identity: "customer")
        try await backend.bind(proof: proof, credential: credential, identity: "customer", deadline: Date().addingTimeInterval(30))
        let request = try #require(await transport.requests.first); #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer bearer")
        let object = try #require(try JSONSerialization.jsonObject(with: request.httpBody ?? Data()) as? [String: Any]); let payload = try #require(object["purchaseProof"] as? [String: Any])
        #expect(payload["transaction"] as? String == "t"); #expect(payload["verified"] as? Bool == true)
    }

    @Test func backendRejectsNonHTTPSUserinfoAndCrossOriginURLs() async throws {
        let transport = RecordingHTTPTransport(responses: [])
        for value in ["http://auth.example.test", "https://user:secret@auth.example.test"] {
            let backend = AppAttestSessionHTTPBackend(baseURL: URL(string: value)!, transport: transport)
            await #expect(throws: AuthenticatedSessionError.invalidURL) {
                _ = try await backend.challenge(purpose: "session", identity: "customer", deadline: Date().addingTimeInterval(30))
            }
        }
        let crossOrigin = AppAttestSessionHTTPBackend(baseURL: URL(string: "https://auth.example.test")!, paths: .init(challenge: "https://other.example.test/challenge"), transport: transport)
        await #expect(throws: AuthenticatedSessionError.invalidURL) {
            _ = try await crossOrigin.challenge(purpose: "session", identity: "customer", deadline: Date().addingTimeInterval(30))
        }
        #expect(await transport.requests.isEmpty)
    }

    @Test func backendRejectsExpiredResponsesAgainstInjectedClock() async throws {
        let transport = RecordingHTTPTransport(responses: [AuthenticatedSessionHTTPResponse(data: Data(#"{"token":"bearer","expiresAt":100}"#.utf8), statusCode: 200)])
        let clock = FixedClock(now: Date(timeIntervalSince1970: 200))
        let backend = AppAttestSessionHTTPBackend(baseURL: URL(string: "https://auth.example.test")!, transport: transport, clock: clock)
        await #expect(throws: AuthenticatedSessionError.identityMismatch) {
            _ = try await backend.issueSession(challenge: AuthenticatedSessionChallenge(value: "challenge", expiresAt: Date().addingTimeInterval(30)), keyID: "key", assertion: Data([2]), identity: "customer", deadline: Date(timeIntervalSince1970: 300))
        }
    }

    @Test func authenticatedClientAssemblesOwnedHeadersAndPreservesRequestBody() async throws {
        let context = TestContext()
        let transport = RecordingHTTPTransport(responses: [
            AuthenticatedSessionHTTPResponse(data: Data("ok".utf8), statusCode: 200)
        ])
        let client = AuthenticatedHTTPClient(
            sessionService: context.makeService(),
            identityProvider: context.identity,
            configuration: context.config,
            transport: transport
        )
        let request = URLRequestSnapshot(
            urlValue: URL(string: "https://staging.example.test/v1/data")!,
            method: .post,
            body: Data("body".utf8),
            timeout: 12,
            cachePolicy: .reloadIgnoringLocalCacheData,
            headers: ["Authorization": "attacker", "X-App-User-ID": "attacker"]
        )
        _ = try await client.execute(request)
        let sent = try #require(await transport.requests.first)
        #expect(sent.value(forHTTPHeaderField: "Authorization") == "Bearer token-1")
        #expect(sent.value(forHTTPHeaderField: "X-App-User-ID") == "customer-1")
        #expect(sent.httpBody == Data("body".utf8))
        #expect(sent.cachePolicy == .reloadIgnoringLocalCacheData)
        #expect(sent.timeoutInterval == 12)
    }

    @Test func authenticatedClientRetriesOnceAfterConfirmedSessionRejection() async throws {
        let context = TestContext(); let transport = RecordingHTTPTransport(responses: [AuthenticatedSessionHTTPResponse(data: Data(#"{"code":"AUTH_INVALID_SESSION"}"#.utf8), statusCode: 401), AuthenticatedSessionHTTPResponse(data: Data("ok".utf8), statusCode: 200)])
        let client = AuthenticatedHTTPClient(sessionService: context.makeService(), identityProvider: context.identity, configuration: context.config, transport: transport)
        _ = try await client.data(for: URL(string: "https://staging.example.test/v1/data")!, method: .post, body: Data("body".utf8), idempotencyKey: "request-1")
        #expect(await transport.requests.count == 2)
        #expect(await transport.requests.allSatisfy { $0.value(forHTTPHeaderField: "Idempotency-Key") == "request-1" })
    }

    @Test func authenticatedClientRejectsUnapprovedOriginBeforeCredentialResolution() async throws {
        let context = TestContext(); let transport = RecordingHTTPTransport(responses: [])
        let client = AuthenticatedHTTPClient(sessionService: context.makeService(), identityProvider: context.identity, configuration: context.config, transport: transport)
        await #expect(throws: AuthenticatedHTTPClientError.invalidOrigin) {
            _ = try await client.data(for: URL(string: "https://other.example.test/v1/data")!)
        }
        #expect(await transport.requests.isEmpty); #expect(await context.backend.count(path: "session") == 0)
    }

    @Test func compatibilityIsExplicitAndRetainsProtocolHeadersWithoutBearer() async throws {
        let context = TestContext(); let transport = RecordingHTTPTransport(responses: [AuthenticatedSessionHTTPResponse(data: Data("ok".utf8), statusCode: 200)])
        let disabled = AuthenticatedSessionConfiguration(baseURL: context.config.baseURL, appIdentifier: "com.example.app", environment: "production", appAttestEnabled: false)
        let client = AuthenticatedHTTPClient(sessionService: AuthenticatedSessionService(configuration: disabled, appAttest: context.attest, backend: context.backend, identityProvider: context.identity, storage: context.storage, clock: context.clock), identityProvider: context.identity, configuration: disabled, transport: transport)
        _ = try await client.data(for: URL(string: "https://staging.example.test/v1/data")!, policy: .compatibility())
        let request = try #require(await transport.requests.first); #expect(request.value(forHTTPHeaderField: "X-App-Auth-Version") == "1"); #expect(request.value(forHTTPHeaderField: "Authorization") == nil)
    }

    @Test func authenticatedClientDoesNotRetryEntitlementDenial() async throws {
        let context = TestContext(); let transport = RecordingHTTPTransport(responses: [AuthenticatedSessionHTTPResponse(data: Data(#"{"code":"PRO_REQUIRED"}"#.utf8), statusCode: 403)])
        let client = AuthenticatedHTTPClient(sessionService: context.makeService(), identityProvider: context.identity, configuration: context.config, transport: transport)
        await #expect(throws: (any Error).self) { _ = try await client.data(for: URL(string: "https://staging.example.test/v1/data")!, method: .post, body: Data("write".utf8)) }
        #expect(await transport.requests.count == 1)
    }
}

private final class TestContext: @unchecked Sendable {
    let config: AuthenticatedSessionConfiguration
    let clock = MutableClock(now: Date(timeIntervalSince1970: 2_000_000_000))
    let storage = LockedStorage()
    let backend = RecordingBackend()
    let attest = RecordingAttest()
    let identity: MutableIdentity

    init(baseURL: URL = URL(string: "https://staging.example.test")!, identity: String = "customer-1") {
        config = AuthenticatedSessionConfiguration(baseURL: baseURL, appIdentifier: "com.example.app", environment: "production", operationTimeout: 15)
        self.identity = MutableIdentity(identity)
    }

    func makeService(proof: (any SessionBindingProofProviding)? = nil, sleeper: any AuthenticatedSessionSleeper = SystemAuthenticatedSessionSleeper()) -> AuthenticatedSessionService {
        AuthenticatedSessionService(configuration: config, appAttest: attest, backend: backend, identityProvider: identity, proofProvider: proof, storage: storage, clock: clock, sleeper: sleeper)
    }

    /// Marks enrollment as server-unconfirmed without leaving a replayable attestation artifact.
    func setEnrollmentPending() {
        storage.setRaw(Data(#""pending""#.utf8), forKey: config.storageKeys.enrollment)
    }

    func setPending(expired: Bool, keyID: String = "key-1") {
        setEnrollmentPending()
        let value: [String: Any] = [
            "challenge": "expired",
            "keyID": keyID,
            "attestationObject": Data([9]).base64EncodedString(),
            // `PendingEnrollment` is encoded with the default `Codable` date strategy.
            "expiresAt": clock.now.addingTimeInterval(expired ? -1 : 300).timeIntervalSinceReferenceDate
        ]
        storage.setRaw(try! JSONSerialization.data(withJSONObject: value), forKey: config.storageKeys.pendingEnrollment)
    }
}

private final class MutableClock: AuthenticatedSessionClock, @unchecked Sendable {
    private let lock = NSLock(); private var value: Date
    init(now: Date) { value = now }
    var now: Date { lock.lock(); defer { lock.unlock() }; return value }
    func advance(by seconds: TimeInterval) { lock.lock(); value.addTimeInterval(seconds); lock.unlock() }
}

private final class MutableIdentity: AuthenticatedSessionIdentityProviding, @unchecked Sendable {
    private let lock = NSLock(); private var current: String
    init(_ value: String) { current = value }
    var identity: String { lock.lock(); defer { lock.unlock() }; return current }
    var value: String { get { identity } set { lock.lock(); current = newValue; lock.unlock() } }
}

private final class LockedStorage: AuthenticatedSessionStorage, @unchecked Sendable {
    private let lock = NSLock(); private var values: [String: Data] = [:]; private var failingKey: String?
    func loadData(forKey key: String) throws -> Data? { lock.lock(); defer { lock.unlock() }; return values[key] }
    func loadLegacyData(forKey key: String) throws -> Data? { try loadData(forKey: key) }
    func storeData(_ data: Data, forKey key: String) throws { lock.lock(); defer { lock.unlock() }; if failingKey == key { failingKey = nil; throw AuthenticatedSessionError.keychainFailure }; values[key] = data }
    func removeData(forKey key: String) throws { lock.lock(); values.removeValue(forKey: key); lock.unlock() }
    func set<T: Encodable>(_ value: T, forKey key: String) { lock.lock(); values[key] = try? JSONEncoder().encode(value); lock.unlock() }
    func setRaw(_ data: Data, forKey key: String) { lock.lock(); values[key] = data; lock.unlock() }
    func hasData(forKey key: String) -> Bool { lock.lock(); defer { lock.unlock() }; return values[key] != nil }
    func isPending(forKey key: String) -> Bool { String(data: (try? loadData(forKey: key)) ?? Data(), encoding: .utf8) == "\"pending\"" }
    func failNextStore(forKey key: String) { lock.lock(); failingKey = key; lock.unlock() }
    func waitUntilData(forKey key: String) async -> Bool { for _ in 0..<10_000 { if hasData(forKey: key) { return true }; await Task.yield() }; return false }
}

private actor RecordingAttest: AppAttestProviding {
    private(set) var assertionCount = 0; private(set) var attestationCount = 0; private(set) var resetCount = 0; private(set) var attestationClientData: [Data] = []
    private var key = "key-1"; private var transient = 0; private var invalid = 0; private var attested: Set<String> = []; private var holdAssertion = false; private var assertionWaiter: CheckedContinuation<Void, Never>?; private var assertionStarted = false; private var assertionStartWaiter: CheckedContinuation<Bool, Never>?; private var holdAttestation = false; private var attestationWaiter: CheckedContinuation<Void, Never>?; private var attestationStarted = false; private var attestationStartWaiters: [CheckedContinuation<Bool, Never>] = []
    func isSupported() async -> Bool { true }
    func keyID() async throws -> String { key }
    func attest(clientData: Data) async throws -> AppAttestAttestation { attestationCount += 1; attestationClientData.append(clientData); if transient > 0 { transient -= 1; throw AppAttestError.transientAppleFailure }; attestationStarted = true; let waiters = attestationStartWaiters; attestationStartWaiters.removeAll(); waiters.forEach { $0.resume(returning: true) }; if holdAttestation { await withCheckedContinuation { attestationWaiter = $0 } }; guard !attested.contains(key) else { throw AppAttestError.keyInvalid }; attested.insert(key); return AppAttestAttestation(keyID: key, attestationObject: Data([1]), clientDataHash: clientData) }
    func assertion(clientData: Data) async throws -> AppAttestAssertion { assertionCount += 1; assertionStarted = true; assertionStartWaiter?.resume(returning: true); assertionStartWaiter = nil; if holdAssertion { await withCheckedContinuation { assertionWaiter = $0 } }; if invalid > 0 { invalid -= 1; throw AppAttestError.keyInvalid }; return AppAttestAssertion(keyID: key, assertion: Data([2]), clientDataHash: clientData) }
    func resetKey() async throws { resetCount += 1; key = "key-\(resetCount + 1)"; attested.removeAll() }
    func setTransientAttestationFailures(_ value: Int) { transient = value }; func setInvalidAssertionFailures(_ value: Int) { invalid = value }; func markCurrentKeyAttested() { attested.insert(key) }; func setHoldAssertions(_ value: Bool) { holdAssertion = value }; func releaseAssertion() { assertionWaiter?.resume(); assertionWaiter = nil }; func setHoldAttestation(_ value: Bool) { holdAttestation = value }; func releaseAttestation() { attestationWaiter?.resume(); attestationWaiter = nil }
    func waitUntilAssertionStarted() async -> Bool { if assertionStarted { return true }; return await withCheckedContinuation { assertionStartWaiter = $0 } }; func waitUntilAttestationStarted() async -> Bool { if attestationStarted { return true }; return await withCheckedContinuation { attestationStartWaiters.append($0) } }
}

private actor RecordingBackend: AuthenticatedSessionBackend {
    private var requests: [String] = []; private var blocked = false; private var sessionRequested = false; private var lostEnrollment = false; private var enrollmentCount = 0; private var notEnrolled = false; private var nullIdentity = false; private var authRequired = false
    func challenge(purpose: String, identity: String, deadline: Date) async throws -> AuthenticatedSessionChallenge { requests.append("challenge-\(purpose)"); return AuthenticatedSessionChallenge(value: "challenge-\(purpose)-\(enrollmentCount)", expiresAt: deadline.addingTimeInterval(300)) }
    func enroll(challenge: AuthenticatedSessionChallenge, keyID: String, attestationObject: Data, identity: String, deadline: Date) async throws { enrollmentCount += 1; requests.append("enroll"); if lostEnrollment && enrollmentCount == 1 { throw AuthenticatedSessionError.transientAppleFailure }; if lostEnrollment && enrollmentCount == 2 { throw AuthenticatedSessionError.http(status: 401, code: "ATTESTATION_REJECTED") } }
    func issueSession(challenge: AuthenticatedSessionChallenge, keyID: String, assertion: Data, identity: String, deadline: Date) async throws -> AuthenticatedSessionCredential { requests.append("session"); sessionRequested = true; if notEnrolled { notEnrolled = false; throw AuthenticatedSessionError.http(status: 401, code: "APP_ATTEST_KEY_NOT_ENROLLED") }; while blocked { await Task.yield() }; let value = nullIdentity ? "" : identity; return AuthenticatedSessionCredential(token: "token-\(identity.suffix(1))", expiresAt: deadline.addingTimeInterval(1_000), keyID: keyID, identity: value.isEmpty ? identity : value) }
    func bind(proof: SessionBindingProof, credential: AuthenticatedSessionCredential, identity: String, deadline: Date) async throws { requests.append("bind"); if authRequired { authRequired = false; throw AuthenticatedSessionError.http(status: 401, code: "AUTH_INVALID_SESSION") } }
    func count(path: String) -> Int { requests.filter { $0 == path }.count }; func setBlockSession(_ value: Bool) { blocked = value }; func setLostEnrollmentResponse(_ value: Bool) { lostEnrollment = value }; func setSessionNotEnrolledOnce(_ value: Bool) { notEnrolled = value }; func setNullSessionIdentity(_ value: Bool) { nullIdentity = value }; func setBindAuthRequiredOnce(_ value: Bool) { authRequired = value }; func waitUntilSessionRequested() async -> Bool { for _ in 0..<10_000 { if sessionRequested { return true }; await Task.yield() }; return false }
}

private struct FixedProof: SessionBindingProofProviding { func currentProof() async throws -> SessionBindingProof { SessionBindingProof(identity: "customer-1", fingerprint: "proof-1", encodedPayload: Data(#"{"purchase":"proof"}"#.utf8)) } }
private actor MutableProof: SessionBindingProofProviding { private var transaction = "transaction-1"; func setTransactionID(_ value: String) { transaction = value }; func currentProof() async throws -> SessionBindingProof { SessionBindingProof(identity: "customer-1", fingerprint: transaction, encodedPayload: Data(transaction.utf8)) } }
private struct ImmediateSleeper: AuthenticatedSessionSleeper { func sleep(seconds: TimeInterval) async throws {} }

/// Expires the first operation deadline against the injected clock, then behaves
/// normally so later operations cancel their timer instead of racing it.
private final class AdvancingSleeper: AuthenticatedSessionSleeper, @unchecked Sendable {
    private let lock = NSLock()
    private let clock: MutableClock
    private let attest: RecordingAttest
    private let advanceBy: TimeInterval
    private var hasAdvanced = false

    init(clock: MutableClock, attest: RecordingAttest, advanceBy: TimeInterval) {
        self.clock = clock
        self.attest = attest
        self.advanceBy = advanceBy
    }

    func sleep(seconds: TimeInterval) async throws {
        lock.lock()
        let shouldAdvance = !hasAdvanced
        hasAdvanced = true
        lock.unlock()
        guard shouldAdvance else { return try await SystemAuthenticatedSessionSleeper().sleep(seconds: seconds) }
        _ = await attest.waitUntilAttestationStarted()
        clock.advance(by: advanceBy)
    }
}
private struct FixedClock: AuthenticatedSessionClock { let now: Date }
private actor RecordingHTTPTransport: AuthenticatedSessionHTTPTransport {
    private var responses: [AuthenticatedSessionHTTPResponse]
    private(set) var requests: [URLRequest] = []
    init(responses: [AuthenticatedSessionHTTPResponse]) { self.responses = responses }
    func send(_ request: URLRequest) async throws -> AuthenticatedSessionHTTPResponse { requests.append(request); return responses.isEmpty ? AuthenticatedSessionHTTPResponse(data: Data(), statusCode: 200) : responses.removeFirst() }
}
