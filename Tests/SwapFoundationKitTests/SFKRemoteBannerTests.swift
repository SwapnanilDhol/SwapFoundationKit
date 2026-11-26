/*****************************************************************************
 * SFKRemoteBannerTests.swift
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

final class SFKRemoteBannerTests: XCTestCase {

    private let now = Date(timeIntervalSince1970: 1_795_000_000)

    private func context(
        isPro: Bool = false,
        appVersion: String = "1.16.1",
        regionCode: String? = "US",
        languageCode: String? = "en",
        now: Date? = nil
    ) -> SFKRemoteBanner.Context {
        .init(
            isPro: isPro,
            appVersion: appVersion,
            regionCode: regionCode,
            languageCode: languageCode,
            now: now ?? self.now
        )
    }

    private func payload(_ banners: String) -> Data {
        Data(#"{ "banners": [\#(banners)] }"#.utf8)
    }

    // MARK: - Decoding

    func testDecodesAFullBanner() throws {
        let data = payload(#"""
        {
          "id": "bf", "title": "Half off", "message": "Until Monday", "actionTitle": "ignored legacy key",
          "symbol": "tag.fill", "tint": "#FF3B30",
          "action": { "type": "paywall", "plan": "lifetime" },
          "startsAt": "2026-11-27T00:00:00Z", "endsAt": "2026-12-01T08:00:00Z",
          "maxImpressions": 3, "priority": 10,
          "audience": { "plan": "free", "minAppVersion": "1.16.1", "regions": ["US"], "languages": ["en"] }
        }
        """#)
        let banner = try XCTUnwrap(SFKRemoteBanner.banners(fromPayload: data).first)
        XCTAssertEqual(banner.id, "bf")
        XCTAssertEqual(banner.action, .paywall(plan: "lifetime"))
        XCTAssertEqual(banner.audience.plan, .free)
        XCTAssertEqual(banner.maxImpressions, 3)
        XCTAssertEqual(banner.priority, 10)
        XCTAssertEqual(banner.symbolName, "tag.fill")
        XCTAssertEqual(banner.startsAt, ISO8601DateFormatter().date(from: "2026-11-27T00:00:00Z"))
    }

    func testMinimalBannerGetsDefaults() throws {
        let banner = try XCTUnwrap(
            SFKRemoteBanner.banners(fromPayload: payload(#"{ "id": "a", "title": "Hi" }"#)).first
        )
        XCTAssertEqual(banner.action, .none)
        XCTAssertEqual(banner.audience.plan, .all)
        XCTAssertEqual(banner.maxImpressions, 1)
        XCTAssertNil(banner.endsAt)
    }

    func testUnreadableBannersAreSkippedAndTheRestLoad() throws {
        let data = payload(#"""
        { "title": "No id" },
        { "id": "future", "title": "T", "action": { "type": "open_minigame" } },
        { "id": "bad-date", "title": "T", "endsAt": "next tuesday" },
        { "id": "bad-plan", "title": "T", "audience": { "plan": "vip" } },
        { "id": "bad-url", "title": "T", "action": { "type": "url", "url": "not a url" } },
        { "id": "good", "title": "T", "action": { "type": "url", "url": "https://example.com/x" } }
        """#)
        let banners = try SFKRemoteBanner.banners(fromPayload: data)
        XCTAssertEqual(banners.map(\.id), ["good"])
        XCTAssertEqual(banners.first?.action, .url(URL(string: "https://example.com/x")!))
    }

    func testAFileThatIsNotAPayloadThrows() {
        XCTAssertThrowsError(try SFKRemoteBanner.banners(fromPayload: Data("<html>".utf8)))
        XCTAssertThrowsError(try SFKRemoteBanner.banners(fromPayload: Data("{}".utf8)))
    }

    // MARK: - Targeting

    func testDateWindow() {
        let banner = SFKRemoteBanner(
            id: "a", title: "T",
            startsAt: now.addingTimeInterval(-10), endsAt: now.addingTimeInterval(10)
        )
        XCTAssertTrue(banner.isEligible(in: context()))
        XCTAssertFalse(banner.isEligible(in: context(now: now.addingTimeInterval(-11))))
        XCTAssertFalse(banner.isEligible(in: context(now: now.addingTimeInterval(10))))
    }

    func testPlanTargeting() {
        let free = SFKRemoteBanner(id: "a", title: "T", audience: .init(plan: .free))
        let pro = SFKRemoteBanner(id: "b", title: "T", audience: .init(plan: .pro))
        let all = SFKRemoteBanner(id: "c", title: "T")
        XCTAssertTrue(free.isEligible(in: context(isPro: false)))
        XCTAssertFalse(free.isEligible(in: context(isPro: true)))
        XCTAssertFalse(pro.isEligible(in: context(isPro: false)))
        XCTAssertTrue(pro.isEligible(in: context(isPro: true)))
        XCTAssertTrue(all.isEligible(in: context(isPro: true)))
        XCTAssertTrue(all.isEligible(in: context(isPro: false)))
    }

    func testVersionRangeComparesNumerically() {
        let banner = SFKRemoteBanner(
            id: "a", title: "T", audience: .init(minAppVersion: "1.9.0", maxAppVersion: "1.16")
        )
        XCTAssertFalse(banner.isEligible(in: context(appVersion: "1.8.9")))
        XCTAssertTrue(banner.isEligible(in: context(appVersion: "1.9")))
        XCTAssertTrue(banner.isEligible(in: context(appVersion: "1.10.0")))
        XCTAssertTrue(banner.isEligible(in: context(appVersion: "1.16.0")))
        XCTAssertFalse(banner.isEligible(in: context(appVersion: "1.16.1")))
    }

    func testRegionAndLanguageTargeting() {
        let banner = SFKRemoteBanner(
            id: "a", title: "T", audience: .init(regions: ["us", "GB"], languages: ["en", "zh-Hans"])
        )
        XCTAssertTrue(banner.isEligible(in: context(regionCode: "US", languageCode: "en-GB")))
        XCTAssertTrue(banner.isEligible(in: context(regionCode: "GB", languageCode: "zh-Hans")))
        XCTAssertFalse(banner.isEligible(in: context(regionCode: "DE", languageCode: "en")))
        XCTAssertFalse(banner.isEligible(in: context(regionCode: "US", languageCode: "zh-Hant")))
        XCTAssertFalse(banner.isEligible(in: context(regionCode: nil, languageCode: "en")))
    }

    // MARK: - Localization

    func testLocalizationFallsBackFieldByField() throws {
        let data = payload(#"""
        {
          "id": "a", "title": "Sale", "message": "Until Monday",
          "localizations": {
            "de": { "title": "Angebot" },
            "zh": { "title": "ZH" },
            "zh-Hant": { "title": "HANT", "message": "MSG" }
          }
        }
        """#)
        let banner = try XCTUnwrap(SFKRemoteBanner.banners(fromPayload: data).first)
        XCTAssertEqual(banner.localized(for: "de").title, "Angebot")
        XCTAssertEqual(banner.localized(for: "de").message, "Until Monday")
        XCTAssertEqual(banner.localized(for: "zh-Hant").title, "HANT")
        XCTAssertEqual(banner.localized(for: "zh-Hant").message, "MSG")
        XCTAssertEqual(banner.localized(for: "zh-Hans").title, "ZH")
        XCTAssertEqual(banner.localized(for: "ja").title, "Sale")
        XCTAssertEqual(banner.localized(for: nil).title, "Sale")
    }
}

// MARK: - Service

@MainActor
final class SFKRemoteBannerServiceTests: XCTestCase {

    private var defaults: UserDefaults!
    private var suiteName: String!
    private let url = URL(string: "https://example.com/banners.json")!

    override func setUp() async throws {
        suiteName = "SFKRemoteBannerServiceTests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)
    }

    override func tearDown() async throws {
        defaults.removePersistentDomain(forName: suiteName)
    }

    private func service(
        returning body: String,
        status: Int = 200,
        minimumRefreshInterval: TimeInterval = 0
    ) -> SFKRemoteBannerService {
        let url = url
        return SFKRemoteBannerService(
            url: url,
            userDefaults: defaults,
            minimumRefreshInterval: minimumRefreshInterval,
            transport: { _ in
                let response = HTTPURLResponse(url: url, statusCode: status, httpVersion: nil, headerFields: nil)!
                return (Data(body.utf8), response)
            }
        )
    }

    private func failingService() -> SFKRemoteBannerService {
        SFKRemoteBannerService(
            url: url, userDefaults: defaults, minimumRefreshInterval: 0,
            transport: { _ in throw URLError(.notConnectedToInternet) }
        )
    }

    private let context = SFKRemoteBanner.Context(
        isPro: false, appVersion: "1.0", regionCode: "US", languageCode: "en"
    )

    private let oneBanner = #"{ "banners": [{ "id": "a", "title": "A" }] }"#

    func testNothingToShowBeforeTheFirstFetch() {
        XCTAssertNil(service(returning: oneBanner).banner(for: context))
    }

    func testFetchedBannerIsOffered() async {
        let service = service(returning: oneBanner)
        let didRefresh = await service.refresh()
        XCTAssertTrue(didRefresh)
        XCTAssertEqual(service.banner(for: context)?.id, "a")
    }

    func testShownBannerStaysForTheLaunchThenNeverReturns() async {
        let first = service(returning: oneBanner)
        await first.refresh()
        let banner = first.banner(for: context)!
        first.recordImpression(of: banner)
        first.recordImpression(of: banner)
        XCTAssertEqual(first.banner(for: context)?.id, "a", "Still visible during the launch that showed it")

        // A new service on the same defaults stands in for the next launch.
        let second = service(returning: oneBanner)
        XCTAssertNil(second.banner(for: context), "Cached payload, but the impression is spent")
        await second.refresh()
        XCTAssertNil(second.banner(for: context))
    }

    func testMaxImpressionsCountsLaunches() async {
        let body = #"{ "banners": [{ "id": "a", "title": "A", "maxImpressions": 2 }] }"#
        for launch in 1...2 {
            let service = service(returning: body)
            await service.refresh()
            let banner = service.banner(for: context)
            XCTAssertNotNil(banner, "Launch \(launch) should show it")
            banner.map(service.recordImpression(of:))
        }
        let third = service(returning: body)
        await third.refresh()
        XCTAssertNil(third.banner(for: context))
    }

    func testDismissalIsImmediateAndPermanent() async {
        let body = #"{ "banners": [{ "id": "a", "title": "A", "maxImpressions": 5 }] }"#
        let first = service(returning: body)
        await first.refresh()
        let banner = first.banner(for: context)!
        first.recordImpression(of: banner)
        first.dismiss(banner)
        XCTAssertNil(first.banner(for: context))

        let second = service(returning: body)
        await second.refresh()
        XCTAssertNil(second.banner(for: context))
    }

    func testANewIDShowsAfterAnOldOneWasSeen() async {
        let first = service(returning: oneBanner)
        await first.refresh()
        first.recordImpression(of: first.banner(for: context)!)

        let second = service(returning: #"{ "banners": [{ "id": "a", "title": "A" }, { "id": "b", "title": "B" }] }"#)
        await second.refresh()
        XCTAssertEqual(second.banner(for: context)?.id, "b")
    }

    func testHighestPriorityEligibleBannerWins() async {
        let service = service(returning: #"""
        { "banners": [
          { "id": "low", "title": "L" },
          { "id": "pro-only", "title": "P", "priority": 9, "audience": { "plan": "pro" } },
          { "id": "high", "title": "H", "priority": 5 },
          { "id": "tie", "title": "T", "priority": 5 }
        ] }
        """#)
        await service.refresh()
        XCTAssertEqual(service.banner(for: context)?.id, "high")
    }

    func testBannerCopyIsLocalizedForTheContext() async {
        let service = service(returning: #"""
        { "banners": [{ "id": "a", "title": "Sale", "localizations": { "de": { "title": "Angebot" } } }] }
        """#)
        await service.refresh()
        var german = context
        german.languageCode = "de"
        XCTAssertEqual(service.banner(for: german)?.title, "Angebot")
    }

    func testFailedRefreshKeepsTheCachedPayload() async {
        await service(returning: oneBanner).refresh()

        let offline = failingService()
        let didRefresh = await offline.refresh()
        XCTAssertFalse(didRefresh)
        XCTAssertEqual(offline.banner(for: context)?.id, "a")

        let serverError = service(returning: "oops", status: 500)
        let didRefreshOnError = await serverError.refresh()
        XCTAssertFalse(didRefreshOnError)
        XCTAssertEqual(serverError.banner(for: context)?.id, "a")

        let garbage = service(returning: "<html>")
        let didRefreshOnGarbage = await garbage.refresh()
        XCTAssertFalse(didRefreshOnGarbage)
        XCTAssertEqual(garbage.banner(for: context)?.id, "a")
    }

    func testAnEmptyPayloadTakesBannersDown() async {
        await service(returning: oneBanner).refresh()
        let emptied = service(returning: #"{ "banners": [] }"#)
        XCTAssertNotNil(emptied.banner(for: context))
        await emptied.refresh()
        XCTAssertNil(emptied.banner(for: context))
        XCTAssertNil(service(returning: oneBanner).banner(for: context), "The empty file is what stays cached")
    }

    func testRefreshIsThrottled() async {
        let service = service(returning: oneBanner, minimumRefreshInterval: 600)
        let first = await service.refresh()
        let second = await service.refresh()
        let forced = await service.refresh(force: true)
        XCTAssertTrue(first)
        XCTAssertFalse(second)
        XCTAssertTrue(forced)
    }
}
