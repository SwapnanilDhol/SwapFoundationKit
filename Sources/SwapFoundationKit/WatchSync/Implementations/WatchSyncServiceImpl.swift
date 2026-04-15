/*****************************************************************************
 * WatchSyncServiceImpl.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import Foundation
import Combine

/// Default WatchSync implementation built on top of WatchConnectivityService.
public final class WatchSyncServiceImpl: WatchSyncService {
    private let connectivityService: WatchConnectivityService
    private let options: WatchSyncOptions
    private let envelopeSubject = PassthroughSubject<WatchSyncEnvelope, Never>()
    private let eventSubject = PassthroughSubject<WatchSyncEvent, Never>()
    private var cancellables = Set<AnyCancellable>()
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    public init(
        connectivityService: WatchConnectivityService,
        options: WatchSyncOptions = .default
    ) {
        self.connectivityService = connectivityService
        self.options = options
        observeInboundPayloads()
    }

    public func activate() {
        connectivityService.activate()
        eventSubject.send(.activated)
    }

    public func send<T: SyncableData>(_ value: T) async throws {
        do {
            let envelope = try WatchSyncEnvelope.make(value, encoder: encoder)
            try await sendEnvelope(envelope)
        } catch let error as WatchSyncError {
            eventSubject.send(.error(error.localizedDescription))
            throw error
        } catch {
            let wrapped = WatchSyncError.payloadEncodingFailed(error)
            eventSubject.send(.error(wrapped.localizedDescription))
            throw wrapped
        }
    }

    public func sendEnvelope(_ envelope: WatchSyncEnvelope) async throws {
        do {
            let encodedEnvelope = try encoder.encode(envelope)
            try connectivityService.sendData(
                encodedEnvelope,
                preferredTransport: options.preferredTransport,
                fallbackTransports: options.fallbackOrder,
                maxInlinePayloadBytes: options.maxInlinePayloadBytes
            )
            eventSubject.send(.sent(identifier: envelope.identifier, transport: options.preferredTransport))
        } catch let error as WatchConnectivityError {
            let wrapped = WatchSyncError.transportFailed(error)
            eventSubject.send(.error(wrapped.localizedDescription))
            throw wrapped
        } catch {
            let wrapped = WatchSyncError.transportFailed(error)
            eventSubject.send(.error(wrapped.localizedDescription))
            throw wrapped
        }
    }

    public var envelopePublisher: AnyPublisher<WatchSyncEnvelope, Never> {
        envelopeSubject.eraseToAnyPublisher()
    }

    public var eventPublisher: AnyPublisher<WatchSyncEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }

    public func publisher<T: SyncableData>(for type: T.Type) -> AnyPublisher<T, Never> {
        envelopePublisher
            .compactMap { [decoder, options] envelope in
                if envelope.identifier == T.syncIdentifier {
                    return try? envelope.decodePayload(T.self, decoder: decoder)
                }
                guard options.enableLegacyPayloadDecoding else { return nil }
                return nil
            }
            .eraseToAnyPublisher()
    }

    private func observeInboundPayloads() {
        connectivityService.payloadReceivedPublisher
            .sink { [weak self] payload in
                guard let self else { return }
                self.handleIncomingPayload(payload.data, transport: payload.transport)
            }
            .store(in: &cancellables)
    }

    private func handleIncomingPayload(_ data: Data, transport: WatchSyncTransport) {
        do {
            let envelope = try decoder.decode(WatchSyncEnvelope.self, from: data)
            envelopeSubject.send(envelope)
            eventSubject.send(.received(identifier: envelope.identifier, transport: transport))
        } catch {
            let wrapped = WatchSyncError.envelopeDecodingFailed(error)
            eventSubject.send(.error(wrapped.localizedDescription))
        }
    }
}
