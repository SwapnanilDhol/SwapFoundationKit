/*****************************************************************************
 * WatchSyncIntegrationTests.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import XCTest
import Combine
@testable import SwapFoundationKit

final class WatchSyncIntegrationTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()

    func testWatchSyncServiceSendWrapsEnvelope() async throws {
        let connectivity = MockWatchConnectivityService()
        let service = WatchSyncServiceImpl(
            connectivityService: connectivity,
            options: WatchSyncOptions(preferredTransport: .applicationContext)
        )

        try await service.send(MockProfile(id: "42", name: "Ada"))

        XCTAssertNotNil(connectivity.lastSentData)
        XCTAssertEqual(connectivity.lastPreferredTransport, .applicationContext)

        let envelope = try JSONDecoder().decode(WatchSyncEnvelope.self, from: try XCTUnwrap(connectivity.lastSentData))
        let decoded: MockProfile = try envelope.decodePayload(MockProfile.self)
        XCTAssertEqual(decoded.id, "42")
    }

    func testDataSyncServiceEmitsWatchDataSentEvent() async throws {
        let storage = MockStorageService()
        let watchSync = MockWatchSyncService()
        let service = DataSyncServiceImpl(storage: storage, watchSyncService: watchSync)
        let expectation = expectation(description: "watchDataSent emitted")

        service.syncPublisher
            .sink { event in
                if case .watchDataSent(let identifier) = event, identifier == MockProfile.syncIdentifier {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        try await service.save(MockProfile(id: "7", name: "Grace"))
        await fulfillment(of: [expectation], timeout: 1.0)
    }
}

private struct MockProfile: SyncableData, Equatable {
    let id: String
    let name: String
    static let syncIdentifier = "mock_profile"
}

private final class MockWatchConnectivityService: WatchConnectivityService {
    let payloadSubject = PassthroughSubject<WatchConnectivityPayload, Never>()
    var activated = false
    var lastSentData: Data?
    var lastPreferredTransport: WatchSyncTransport?

    func activate() {
        activated = true
    }

    var isReachable: Bool { true }

    func sendData(
        _ data: Data,
        preferredTransport: WatchSyncTransport,
        fallbackTransports _: [WatchSyncTransport],
        maxInlinePayloadBytes _: Int
    ) throws {
        lastSentData = data
        lastPreferredTransport = preferredTransport
    }

    var payloadReceivedPublisher: AnyPublisher<WatchConnectivityPayload, Never> {
        payloadSubject.eraseToAnyPublisher()
    }

    var dataReceivedPublisher: AnyPublisher<Data, Never> {
        payloadSubject.map(\.data).eraseToAnyPublisher()
    }
}

private final class MockWatchSyncService: WatchSyncService {
    let envelopeSubject = PassthroughSubject<WatchSyncEnvelope, Never>()
    let eventSubject = PassthroughSubject<WatchSyncEvent, Never>()

    func activate() {}

    func send<T>(_ value: T) async throws where T: SyncableData {
        let envelope = try WatchSyncEnvelope.make(value)
        envelopeSubject.send(envelope)
        eventSubject.send(.sent(identifier: T.syncIdentifier, transport: .applicationContext))
    }

    func sendEnvelope(_ envelope: WatchSyncEnvelope) async throws {
        envelopeSubject.send(envelope)
        eventSubject.send(.sent(identifier: envelope.identifier, transport: .applicationContext))
    }

    var envelopePublisher: AnyPublisher<WatchSyncEnvelope, Never> {
        envelopeSubject.eraseToAnyPublisher()
    }

    var eventPublisher: AnyPublisher<WatchSyncEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }

    func publisher<T>(for type: T.Type) -> AnyPublisher<T, Never> where T: SyncableData {
        envelopeSubject
            .compactMap { try? $0.decodePayload(type) }
            .eraseToAnyPublisher()
    }
}

private final class MockStorageService: FileStorageService {
    private var storage: [String: Data] = [:]

    func save<T>(_ data: T) throws where T: SyncableData {
        storage[T.syncIdentifier] = try JSONEncoder().encode(data)
    }

    func read<T>(_ type: T.Type) throws -> T where T: SyncableData {
        guard let data = storage[T.syncIdentifier] else {
            throw FileStorageError.fileNotFound
        }
        return try JSONDecoder().decode(type, from: data)
    }

    func exists<T>(_ type: T.Type) -> Bool where T: SyncableData {
        storage[T.syncIdentifier] != nil
    }

    func delete<T>(_ type: T.Type) throws where T: SyncableData {
        storage[T.syncIdentifier] = nil
    }
}
