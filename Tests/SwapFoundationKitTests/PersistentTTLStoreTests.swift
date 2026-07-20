/****************************************************************************
 * PersistentTTLStoreTests.swift
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

@Suite(.serialized)
struct PersistentTTLStoreTests {
    @Test
    func setAndReadValueBeforeExpiry() async throws {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        let now = Date(timeIntervalSince1970: 1_000)
        let store = fixture.makeStore(now: now)

        await store.set(.blocked, forKey: "merchant", ttl: 60, at: now)

        #expect(await store.value(forKey: "merchant", at: now.addingTimeInterval(59)) == .blocked)
        #expect(await store.expirationDate(forKey: "merchant", at: now) == now.addingTimeInterval(60))
    }

    @Test
    func expiredValueIsRemovedAndPersisted() async throws {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        let now = Date(timeIntervalSince1970: 1_000)
        let store = fixture.makeStore(now: now)
        await store.set(
            .blocked,
            forKey: "merchant",
            expiresAt: now.addingTimeInterval(60),
            at: now
        )

        #expect(await store.value(forKey: "merchant", at: now.addingTimeInterval(61)) == nil)
        #expect(await store.count(at: now.addingTimeInterval(61)) == 0)

        let restored = fixture.makeStore(now: now.addingTimeInterval(61))
        #expect(await restored.count(at: now.addingTimeInterval(61)) == 0)
    }

    @Test
    func valuesPersistAcrossStoreInstances() async throws {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        let now = Date()
        let firstStore = fixture.makeStore(now: now)
        await firstStore.set(.blocked, forKey: "merchant", ttl: 60, at: now)

        let restoredStore = fixture.makeStore(now: now)

        #expect(await restoredStore.value(forKey: "merchant", at: now) == .blocked)
    }

    @Test
    func capacityEvictsLeastRecentlySetValue() async throws {
        let fixture = try Fixture(maximumEntryCount: 2)
        defer { fixture.cleanup() }
        let now = Date()
        let store = fixture.makeStore(now: now)

        await store.set(.blocked, forKey: "first", ttl: 60, at: now)
        await store.set(.blocked, forKey: "second", ttl: 60, at: now)
        await store.set(.blocked, forKey: "third", ttl: 60, at: now)

        #expect(await store.value(forKey: "first", at: now) == nil)
        #expect(await store.value(forKey: "second", at: now) == .blocked)
        #expect(await store.value(forKey: "third", at: now) == .blocked)
    }

    @Test
    func nonPositiveTTLAndRemoveAllDeleteValues() async throws {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        let store = fixture.makeStore()

        await store.set(.blocked, forKey: "temporary", ttl: 0)
        #expect(await store.value(forKey: "temporary") == nil)

        await store.set(.blocked, forKey: "one", ttl: 60)
        await store.set(.blocked, forKey: "two", ttl: 60)
        await store.removeAll()
        #expect(await store.count() == 0)
        #expect(fixture.userDefaults.object(forKey: fixture.storageKey) == nil)
    }
}

private extension PersistentTTLStoreTests {
    enum TestValue: String, Codable, Sendable {
        case blocked
    }

    struct Fixture {
        let userDefaults: UserDefaults
        let suiteName: String
        let storageKey = "persistent-ttl-store"
        let maximumEntryCount: Int

        init(maximumEntryCount: Int = 10) throws {
            suiteName = "PersistentTTLStoreTests.\(UUID().uuidString)"
            userDefaults = try #require(UserDefaults(suiteName: suiteName))
            self.maximumEntryCount = maximumEntryCount
        }

        func makeStore(now: Date = Date()) -> PersistentTTLStore<TestValue> {
            PersistentTTLStore(
                userDefaults: userDefaults,
                storageKey: storageKey,
                maximumEntryCount: maximumEntryCount,
                now: now
            )
        }

        func cleanup() {
            userDefaults.removePersistentDomain(forName: suiteName)
        }
    }
}
