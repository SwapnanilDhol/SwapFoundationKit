/****************************************************************************
 * AuthenticatedSessionService.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import Foundation

/// Coordinates App Attest enrollment, bearer sessions, and generic proof binding.
public actor AuthenticatedSessionService {
    private let configuration: AuthenticatedSessionConfiguration
    private let appAttest: any AppAttestProviding
    private let backend: any AuthenticatedSessionBackend
    private let identityProvider: any AuthenticatedSessionIdentityProviding
    private let proofProvider: (any SessionBindingProofProviding)?
    private let storage: any AuthenticatedSessionStorage
    private let clock: any AuthenticatedSessionClock
    private let sleeper: any AuthenticatedSessionSleeper

    private var session: AuthenticatedSessionCredential?
    private var binding: AuthenticatedSessionBindingMetadata?
    private var sessionTask: Task<AuthenticatedSessionCredential, Error>?
    private var bindingTask: Task<Void, Error>?
    private var sessionTaskID: UUID?
    private var bindingTaskID: UUID?
    private var sessionTaskGeneration: UInt64?
    private var bindingTaskGeneration: UInt64?
    private var generation: UInt64 = 0
    private var keyResetGeneration: UInt64?
    private var lastKeyResetAt: Date?
    private var transientRetryGeneration: UInt64?

    public init(
        configuration: AuthenticatedSessionConfiguration,
        appAttest: any AppAttestProviding,
        backend: any AuthenticatedSessionBackend,
        identityProvider: any AuthenticatedSessionIdentityProviding,
        proofProvider: (any SessionBindingProofProviding)? = nil,
        storage: any AuthenticatedSessionStorage = KeychainAuthenticatedSessionStorage(),
        clock: any AuthenticatedSessionClock = SystemAuthenticatedSessionClock(),
        sleeper: any AuthenticatedSessionSleeper = SystemAuthenticatedSessionSleeper()
    ) {
        self.configuration = configuration
        self.appAttest = appAttest
        self.backend = backend
        self.identityProvider = identityProvider
        self.proofProvider = proofProvider
        self.storage = storage
        self.clock = clock
        self.sleeper = sleeper
    }

    public func currentSession(requireBinding: Bool = false) async throws -> AuthenticatedSessionCredential {
        guard configuration.appAttestEnabled else { throw AuthenticatedSessionError.appAttestUnsupported }
        guard await appAttest.isSupported() else { throw AuthenticatedSessionError.appAttestUnsupported }

        _ = try await ensureSession()
        if requireBinding {
            try await ensureBinding()
            _ = try await ensureSession()
        }

        guard let session,
              session.identity == appUserID,
              session.isUsable(at: clock.now, freshness: configuration.sessionFreshness) else {
            throw AuthenticatedSessionError.sessionUnavailable
        }
        return session
    }

    /// Rebinds the current proof, refreshing it even when a binding is cached,
    /// so a new purchase or restore reaches the server.
    public func bindCurrentProof() async throws {
        guard configuration.appAttestEnabled, await appAttest.isSupported() else {
            throw AuthenticatedSessionError.appAttestUnsupported
        }
        try await ensureBinding(forceRefresh: true)
    }

    public func bindCurrentProofIfPossible() async {
        do { try await bindCurrentProof() } catch { }
    }

    public func invalidateSession() async {
        generation &+= 1
        session = nil
        try? storage.removeData(forKey: configuration.storageKeys.session)
    }

    public func invalidateBinding() async throws {
        generation &+= 1
        binding = nil
        try storage.removeData(forKey: configuration.storageKeys.binding)
    }

    public func bootstrap() async {
        do { _ = try await currentSession() }
        catch let error as AuthenticatedSessionError where error.clearsSession { await invalidateSession() }
        catch { }
    }

    private var appUserID: String {
        identityProvider.identity.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func ensureSession() async throws -> AuthenticatedSessionCredential {
        try Task.checkCancellation()
        let expectedIdentity = appUserID
        guard !expectedIdentity.isEmpty else { throw AuthenticatedSessionError.identityMismatch }

        if let session,
           session.identity == expectedIdentity,
           session.isUsable(at: clock.now, freshness: configuration.sessionFreshness) {
            return session
        }

        if let session, session.identity != expectedIdentity {
            await invalidateSession()
            binding = nil
            try? storage.removeData(forKey: configuration.storageKeys.binding)
        } else if session != nil {
            self.session = nil
            try? storage.removeData(forKey: configuration.storageKeys.session)
        }

        let operationGeneration = generation
        if let task = sessionTask, let taskID = sessionTaskID {
            guard sessionTaskGeneration == operationGeneration else {
                throw AuthenticatedSessionError.transientAppleFailure
            }
            return try await awaitSessionTask(task, id: taskID, deadline: clock.now.addingTimeInterval(configuration.operationTimeout))
        }

        let operationID = UUID()
        let deadline = clock.now.addingTimeInterval(configuration.operationTimeout)
        transientRetryGeneration = nil
        let task = Task { [weak self] in
            guard let self else { throw AuthenticatedSessionError.sessionUnavailable }
            do {
                let result = try await self.establishSession(
                    identity: expectedIdentity,
                    generation: operationGeneration,
                    mayRecoverKey: true,
                    deadline: deadline
                )
                await self.finishSessionTask(id: operationID)
                return result
            } catch {
                await self.finishSessionTask(id: operationID)
                throw error
            }
        }
        sessionTask = task
        sessionTaskID = operationID
        sessionTaskGeneration = operationGeneration
        return try await awaitSessionTask(task, id: operationID, deadline: deadline)
    }

    private func awaitSessionTask(
        _ task: Task<AuthenticatedSessionCredential, Error>,
        id: UUID,
        deadline: Date
    ) async throws -> AuthenticatedSessionCredential {
        let gate = ContinuationGate<AuthenticatedSessionCredential>()
        let resultTask = Task {
            do { gate.resume(returning: try await task.value) }
            catch { gate.resume(throwing: error) }
        }
        let timeoutTask = Task {
            do {
                try await sleeper.sleep(seconds: max(0, deadline.timeIntervalSince(clock.now)))
                gate.resume(throwing: AuthenticatedSessionError.transientAppleFailure)
            } catch is CancellationError { }
            catch { }
        }
        defer { resultTask.cancel(); timeoutTask.cancel() }

        return try await withTaskCancellationHandler(operation: {
            try await withCheckedThrowingContinuation { continuation in
                gate.install(continuation)
                if Task.isCancelled { gate.resume(throwing: CancellationError()) }
            }
        }, onCancel: {
            gate.resume(throwing: CancellationError())
        })
    }

    private func finishSessionTask(id: UUID) {
        guard sessionTaskID == id else { return }
        sessionTask = nil
        sessionTaskID = nil
        sessionTaskGeneration = nil
    }

    private func establishSession(
        identity: String,
        generation operationGeneration: UInt64,
        mayRecoverKey: Bool,
        deadline: Date
    ) async throws -> AuthenticatedSessionCredential {
        guard self.generation == operationGeneration, clock.now < deadline else {
            throw AuthenticatedSessionError.staleOperation
        }

        let keyID: String
        do {
            keyID = try await appAttest.keyID()
        } catch {
            if error is CancellationError {
                throw CancellationError()
            }
            if mayRecoverKey, shouldRecover(from: error) {
                try await recoverInvalidKey(generation: operationGeneration)
                return try await establishSession(identity: identity, generation: self.generation, mayRecoverKey: false, deadline: deadline)
            }
            throw mapAppAttestError(error)
        }
        guard self.generation == operationGeneration,
              appUserID == identity else {
            throw AuthenticatedSessionError.staleOperation
        }

        if let stored = try loadSession(),
           stored.keyID == keyID,
           stored.identity == identity,
           stored.isUsable(at: clock.now, freshness: configuration.sessionFreshness) {
            session = stored
            return stored
        }

        if try loadEnrollmentState() == .pending {
            do {
                let result = try await issueSession(identity: identity, keyID: keyID, generation: operationGeneration, deadline: deadline)
                try storage.removeData(forKey: configuration.storageKeys.pendingEnrollment)
                try saveEnrollmentState(.enrolled)
                return result
            } catch let error as AuthenticatedSessionError where error.isTransient {
                throw error
            } catch {
                let pending = try loadPendingEnrollment()
                if pending == nil {
                    guard isKeyNotEnrolled(error) || mapAppAttestError(error) == .appAttestKeyInvalid,
                          keyResetGeneration != operationGeneration,
                          cooldownElapsed else { throw AuthenticatedSessionError.enrollmentIndeterminate }
                    try await recoverInvalidKey(generation: operationGeneration)
                    return try await establishSession(identity: identity, generation: self.generation, mayRecoverKey: false, deadline: deadline)
                }
                guard let pending, pending.keyID == keyID, isKeyNotEnrolled(error) else {
                    throw AuthenticatedSessionError.enrollmentIndeterminate
                }
                if pending.expiresAt <= clock.now {
                    guard keyResetGeneration != operationGeneration, cooldownElapsed else { throw AuthenticatedSessionError.enrollmentIndeterminate }
                    try await recoverInvalidKey(generation: operationGeneration)
                    return try await establishSession(identity: identity, generation: self.generation, mayRecoverKey: false, deadline: deadline)
                }
                do {
                    try await backend.enroll(
                        challenge: AuthenticatedSessionChallenge(value: pending.challenge, expiresAt: pending.expiresAt),
                        keyID: pending.keyID,
                        attestationObject: pending.attestationObject,
                        identity: identity,
                        deadline: deadline
                    )
                    guard self.generation == operationGeneration,
                          appUserID == identity,
                          clock.now < deadline else {
                        throw AuthenticatedSessionError.staleOperation
                    }
                    try storage.removeData(forKey: configuration.storageKeys.pendingEnrollment)
                    try saveEnrollmentState(.enrolled)
                    return try await issueSession(identity: identity, keyID: keyID, generation: operationGeneration, deadline: deadline)
                } catch is CancellationError { throw CancellationError() }
                catch {
                    do {
                        let result = try await issueSession(identity: identity, keyID: keyID, generation: operationGeneration, deadline: deadline)
                        try storage.removeData(forKey: configuration.storageKeys.pendingEnrollment)
                        try saveEnrollmentState(.enrolled)
                        return result
                    } catch is CancellationError { throw CancellationError() }
                    catch { throw AuthenticatedSessionError.enrollmentIndeterminate }
                }
            }
        }

        try await enrollIfNeeded(identity: identity, keyID: keyID, generation: operationGeneration, deadline: deadline)
        do {
            return try await issueSession(identity: identity, keyID: keyID, generation: operationGeneration, deadline: deadline)
        } catch {
            if mayRecoverKey,
               let state = try? loadEnrollmentState(),
               state == .enrolled,
               shouldRecover(from: error) {
                try await recoverInvalidKey(generation: operationGeneration)
                return try await establishSession(identity: identity, generation: self.generation, mayRecoverKey: false, deadline: deadline)
            }
            throw mapAppAttestError(error)
        }
    }

    private func enrollIfNeeded(identity: String, keyID: String, generation operationGeneration: UInt64, deadline: Date) async throws {
        switch try loadEnrollmentState() {
        case .enrolled:
            // Enrollment is server-confirmed and durable. Do not attest again.
            return
        case .pending:
            throw AuthenticatedSessionError.enrollmentIndeterminate
        case .none:
            break
        }
        let challenge = try await backend.challenge(purpose: "enroll", identity: identity, deadline: deadline)
        guard challenge.expiresAt > clock.now,
              self.generation == operationGeneration,
              appUserID == identity else {
            throw AuthenticatedSessionError.staleOperation
        }
        try saveEnrollmentState(.pending)

        let attestation: AppAttestAttestation
        do {
            attestation = try await appAttest.attest(clientData: Data(challenge.value.utf8))
        } catch let error as AppAttestError where error == .transientAppleFailure && consumeTransientRetry(generation: operationGeneration) {
            attestation = try await appAttest.attest(clientData: Data(challenge.value.utf8))
        } catch {
            if error is CancellationError {
                throw CancellationError()
            }
            throw mapAppAttestError(error)
        }
        guard attestation.keyID == keyID else { throw AuthenticatedSessionError.identityMismatch }

        let artifact = PendingEnrollment(challenge: challenge.value, keyID: keyID, attestationObject: attestation.attestationObject, expiresAt: challenge.expiresAt)
        let artifactData = try JSONEncoder().encode(artifact)
        if self.generation != operationGeneration || appUserID != identity {
            // The Apple callback may outlive an identity invalidation. Preserve
            // the installation artifact so the next process can reconcile it.
            try storage.storeData(artifactData, forKey: configuration.storageKeys.pendingEnrollment)
            throw AuthenticatedSessionError.staleOperation
        }
        try storage.storeData(artifactData, forKey: configuration.storageKeys.pendingEnrollment)
        guard clock.now < deadline, appUserID == identity else {
            throw AuthenticatedSessionError.staleOperation
        }

        do {
            try await backend.enroll(challenge: challenge, keyID: keyID, attestationObject: attestation.attestationObject, identity: identity, deadline: deadline)
        } catch let error as AuthenticatedSessionError where error.isTransient && consumeTransientRetry(generation: operationGeneration) {
            try await backend.enroll(challenge: challenge, keyID: keyID, attestationObject: attestation.attestationObject, identity: identity, deadline: deadline)
        }
        guard self.generation == operationGeneration,
              appUserID == identity,
              clock.now < deadline else {
            throw AuthenticatedSessionError.staleOperation
        }
        try storage.removeData(forKey: configuration.storageKeys.pendingEnrollment)
        try saveEnrollmentState(.enrolled)
    }

    private func issueSession(identity: String, keyID: String, generation operationGeneration: UInt64, deadline: Date) async throws -> AuthenticatedSessionCredential {
        let challenge = try await backend.challenge(purpose: "session", identity: identity, deadline: deadline)
        guard challenge.expiresAt > clock.now,
              self.generation == operationGeneration,
              appUserID == identity,
              clock.now < deadline else {
            throw AuthenticatedSessionError.staleOperation
        }
        let assertion: AppAttestAssertion
        do {
            assertion = try await appAttest.assertion(clientData: Data(challenge.value.utf8))
        } catch let error as AppAttestError where error == .transientAppleFailure && consumeTransientRetry(generation: operationGeneration) {
            assertion = try await appAttest.assertion(clientData: Data(challenge.value.utf8))
        } catch {
            if error is CancellationError {
                throw CancellationError()
            }
            throw mapAppAttestError(error)
        }
        guard self.generation == operationGeneration,
              appUserID == identity,
              clock.now < deadline,
              assertion.keyID == keyID else {
            throw AuthenticatedSessionError.staleOperation
        }
        do {
            let result = try await backend.issueSession(challenge: challenge, keyID: keyID, assertion: assertion.assertion, identity: identity, deadline: deadline)
            guard result.identity == identity,
                  self.generation == operationGeneration,
                  appUserID == identity,
                  clock.now < deadline else {
                throw AuthenticatedSessionError.staleOperation
            }
            try storage.storeData(try JSONEncoder().encode(result), forKey: configuration.storageKeys.session)
            session = result
            return result
        } catch let error as AuthenticatedSessionError where error.isTransient && consumeTransientRetry(generation: operationGeneration) {
            return try await issueSession(identity: identity, keyID: keyID, generation: operationGeneration, deadline: deadline)
        }
    }

    private func ensureBinding(forceRefresh: Bool = false) async throws {
        guard let proofProvider else { throw AuthenticatedSessionError.noBindingProof }
        let expectedIdentity = appUserID
        guard !expectedIdentity.isEmpty else { throw AuthenticatedSessionError.identityMismatch }
        if !forceRefresh,
           let binding = try loadBinding(),
           binding.identity == expectedIdentity,
           binding.keyID == session?.keyID {
            self.binding = binding
            return
        }
        let operationGeneration = generation
        if let task = bindingTask, let taskID = bindingTaskID {
            guard bindingTaskGeneration == operationGeneration else { throw AuthenticatedSessionError.transientAppleFailure }
            return try await awaitBindingTask(task, id: taskID, deadline: clock.now.addingTimeInterval(configuration.operationTimeout))
        }
        let operationID = UUID()
        let deadline = clock.now.addingTimeInterval(configuration.operationTimeout)
        let task = Task { [weak self] in
            guard let self else { throw AuthenticatedSessionError.sessionUnavailable }
            do {
                try await self.performBinding(provider: proofProvider, identity: expectedIdentity, generation: operationGeneration, deadline: deadline)
                await self.finishBindingTask(id: operationID)
            } catch {
                await self.finishBindingTask(id: operationID)
                throw error
            }
        }
        bindingTask = task
        bindingTaskID = operationID
        bindingTaskGeneration = operationGeneration
        try await awaitBindingTask(task, id: operationID, deadline: deadline)
    }

    private func awaitBindingTask(_ task: Task<Void, Error>, id: UUID, deadline: Date) async throws {
        let gate = ContinuationGate<Void>()
        let resultTask = Task {
            do { gate.resume(returning: try await task.value) }
            catch { gate.resume(throwing: error) }
        }
        let timeoutTask = Task {
            do {
                try await sleeper.sleep(seconds: max(0, deadline.timeIntervalSince(clock.now)))
                gate.resume(throwing: AuthenticatedSessionError.transientAppleFailure)
            } catch { }
        }
        defer { resultTask.cancel(); timeoutTask.cancel() }

        _ = try await withTaskCancellationHandler(operation: {
            try await withCheckedThrowingContinuation { continuation in
                gate.install(continuation)
                if Task.isCancelled { gate.resume(throwing: CancellationError()) }
            }
        }, onCancel: { gate.resume(throwing: CancellationError()) })
    }

    private func finishBindingTask(id: UUID) {
        guard bindingTaskID == id else { return }
        bindingTask = nil
        bindingTaskID = nil
        bindingTaskGeneration = nil
    }

    private func performBinding(
        provider: any SessionBindingProofProviding,
        identity: String,
        generation operationGeneration: UInt64,
        deadline: Date
    ) async throws {
        var credential = try await ensureSession()
        let proof = try await provider.currentProof()
        guard self.generation == operationGeneration,
              proof.identity == identity,
              credential.identity == identity else {
            throw AuthenticatedSessionError.identityMismatch
        }
        if let existing = try loadBinding(),
           existing.keyID == credential.keyID,
           existing.identity == identity,
           existing.fingerprint == proof.fingerprint {
            binding = existing
            return
        }
        do {
            try await backend.bind(proof: proof, credential: credential, identity: identity, deadline: deadline)
        } catch let error as AuthenticatedSessionError where isPreExecutionSessionRejection(error) {
            invalidateSessionWithoutFence()
            credential = try await ensureSession()
            guard self.generation == operationGeneration,
                  appUserID == identity,
                  clock.now < deadline else {
                throw AuthenticatedSessionError.staleOperation
            }
            try await backend.bind(proof: proof, credential: credential, identity: identity, deadline: deadline)
        }
        guard self.generation == operationGeneration,
              appUserID == identity,
              clock.now < deadline else {
            throw AuthenticatedSessionError.staleOperation
        }
        let metadata = AuthenticatedSessionBindingMetadata(keyID: credential.keyID, identity: identity, fingerprint: proof.fingerprint)
        try storage.storeData(try JSONEncoder().encode(metadata), forKey: configuration.storageKeys.binding)
        binding = metadata
    }

    /// Drops the cached bearer without bumping the generation, so an in-flight
    /// binding operation can refresh and retry rather than being superseded.
    private func invalidateSessionWithoutFence() {
        session = nil
        try? storage.removeData(forKey: configuration.storageKeys.session)
    }

    private func loadSession() throws -> AuthenticatedSessionCredential? {
        guard let data = try storage.loadData(forKey: configuration.storageKeys.session) else { return nil }
        if let value = try? JSONDecoder().decode(AuthenticatedSessionCredential.self, from: data) {
            return value
        }
        if let legacy = try storage.loadLegacyData(forKey: configuration.storageKeys.session),
           let decode = configuration.legacyMigration?.decodeSession,
           let value = try decode(legacy) {
            try storage.storeData(try JSONEncoder().encode(value), forKey: configuration.storageKeys.session)
            return value
        }
        try storage.removeData(forKey: configuration.storageKeys.session)
        return nil
    }

    private func loadBinding() throws -> AuthenticatedSessionBindingMetadata? {
        guard let data = try storage.loadData(forKey: configuration.storageKeys.binding) else { return nil }
        if let value = try? JSONDecoder().decode(AuthenticatedSessionBindingMetadata.self, from: data) {
            return value
        }
        if let legacy = try storage.loadLegacyData(forKey: configuration.storageKeys.binding),
           let decode = configuration.legacyMigration?.decodeBinding,
           let value = try decode(legacy) {
            try storage.storeData(try JSONEncoder().encode(value), forKey: configuration.storageKeys.binding)
            return value
        }
        try storage.removeData(forKey: configuration.storageKeys.binding)
        return nil
    }

    private func loadPendingEnrollment() throws -> PendingEnrollment? {
        guard let data = try storage.loadData(forKey: configuration.storageKeys.pendingEnrollment) else { return nil }
        guard let value = try? JSONDecoder().decode(PendingEnrollment.self, from: data) else {
            try storage.removeData(forKey: configuration.storageKeys.pendingEnrollment)
            return nil
        }
        return value
    }

    private func loadEnrollmentState() throws -> EnrollmentState {
        guard let data = try storage.loadData(forKey: configuration.storageKeys.enrollment) else {
            guard let legacy = try storage.loadLegacyData(forKey: configuration.storageKeys.enrollment),
                  let state = try migratedEnrollmentState(from: legacy) else {
                return .none
            }
            return state
        }
        if let value = try? JSONDecoder().decode(EnrollmentState.self, from: data) { return value }
        // A host adopting this engine may already store an enrollment marker in
        // its own format under the same key. Migrating it here is what keeps an
        // extraction from re-enrolling every shipped installation.
        if let state = try migratedEnrollmentState(from: data) { return state }
        return .pending
    }

    private func migratedEnrollmentState(from data: Data) throws -> EnrollmentState? {
        guard let decoded = try configuration.legacyMigration?.decodeEnrollment?(data) else { return nil }
        let state: EnrollmentState = decoded ? .enrolled : .none
        try saveEnrollmentState(state)
        return state
    }

    private func saveEnrollmentState(_ state: EnrollmentState) throws {
        try storage.storeData(try JSONEncoder().encode(state), forKey: configuration.storageKeys.enrollment)
    }

    private var cooldownElapsed: Bool {
        guard let lastKeyResetAt else { return true }
        return clock.now.timeIntervalSince(lastKeyResetAt) >= 300
    }

    private func shouldRecover(from error: Error) -> Bool {
        mapAppAttestError(error) == .appAttestKeyInvalid && keyResetGeneration != generation && cooldownElapsed
    }

    private func recoverInvalidKey(generation operationGeneration: UInt64) async throws {
        guard generation == operationGeneration else { throw AuthenticatedSessionError.staleOperation }
        keyResetGeneration = operationGeneration
        lastKeyResetAt = clock.now
        do {
            try await appAttest.resetKey()
        } catch {
            keyResetGeneration = nil
            throw mapAppAttestError(error)
        }
        guard generation == operationGeneration else { throw AuthenticatedSessionError.staleOperation }
        generation &+= 1
        keyResetGeneration = nil
        session = nil
        binding = nil
        try storage.removeData(forKey: configuration.storageKeys.session)
        try storage.removeData(forKey: configuration.storageKeys.enrollment)
        try storage.removeData(forKey: configuration.storageKeys.binding)
        try storage.removeData(forKey: configuration.storageKeys.pendingEnrollment)
    }

    private func mapAppAttestError(_ error: Error) -> AuthenticatedSessionError {
        guard let error = error as? AppAttestError else { return (error as? AuthenticatedSessionError) ?? .invalidResponse }
        switch error {
        case .unsupported: return .appAttestUnsupported
        case .keyInvalid, .invalidStoredKeyID: return .appAttestKeyInvalid
        case .keyStoreFailure: return .keychainFailure
        case .transientAppleFailure: return .transientAppleFailure
        case .invalidClientData: return .invalidResponse
        case .keyGenerationFailed, .attestationFailed, .assertionFailed: return .appAttestFailure
        }
    }

    private func isKeyNotEnrolled(_ error: Error) -> Bool {
        guard case let .http(status, code) = mapAppAttestError(error), status == 401 else { return false }
        return code == "APP_ATTEST_KEY_NOT_ENROLLED"
    }

    private func isPreExecutionSessionRejection(_ error: AuthenticatedSessionError) -> Bool {
        guard case let .http(status, code) = error, status == 401 else { return false }
        return code == "AUTH_REQUIRED" || code == "AUTH_INVALID_SESSION"
    }

    private func consumeTransientRetry(generation operationGeneration: UInt64) -> Bool {
        guard transientRetryGeneration != operationGeneration else { return false }
        transientRetryGeneration = operationGeneration
        return true
    }

    private enum EnrollmentState: String, Codable {
        case none
        case pending
        case enrolled
    }

    /// The attestation artifact retained when a server enrollment outcome is unknown,
    /// so the next launch can replay it instead of attesting again.
    private struct PendingEnrollment: Codable {
        let challenge: String
        let keyID: String
        let attestationObject: Data
        let expiresAt: Date
    }

    /// Resolves a waiter exactly once, whichever of the shared operation, the
    /// deadline or the waiter's own cancellation finishes first.
    private final class ContinuationGate<Value>: @unchecked Sendable {
        private let lock = NSLock()
        private var continuation: CheckedContinuation<Value, Error>?
        private var result: Result<Value, Error>?

        func install(_ continuation: CheckedContinuation<Value, Error>) {
            lock.lock()
            if let result {
                lock.unlock()
                continuation.resume(with: result)
                return
            }
            self.continuation = continuation
            lock.unlock()
        }

        func resume(returning value: Value) { resume(with: .success(value)) }

        func resume(throwing error: Error) { resume(with: .failure(error)) }

        private func resume(with result: Result<Value, Error>) {
            lock.lock()
            guard self.result == nil else {
                lock.unlock()
                return
            }
            self.result = result
            let continuation = self.continuation
            self.continuation = nil
            lock.unlock()
            continuation?.resume(with: result)
        }
    }
}
