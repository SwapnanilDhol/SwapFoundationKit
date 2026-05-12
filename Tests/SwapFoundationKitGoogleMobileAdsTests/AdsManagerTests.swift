/*****************************************************************************
 * AdsManagerTests.swift
 * SwapFoundationKitGoogleMobileAdsTests
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

#if canImport(UIKit)
import UIKit
import XCTest
@testable import SwapFoundationKit
@testable import SwapFoundationKitGoogleMobileAds

@MainActor
final class AdsManagerTests: XCTestCase {
    private var provider: FakeAdsProvider!
    private var manager: AdsManager!

    override func setUp() {
        super.setUp()
        provider = FakeAdsProvider()
        manager = AdsManager.makeForTesting(providerFactory: FakeAdsProviderFactory(provider: provider))
        SwapFoundationKit.shared.resetForTesting()
        AdsManager.shared.resetForTesting()
    }

    override func tearDown() {
        provider = nil
        manager = nil
        SwapFoundationKit.shared.resetForTesting()
        AdsManager.shared.resetForTesting()
        super.tearDown()
    }

    func testPreload_RequestsExpectedPlacements() async {
        await manager.start(with: makeConfiguration(preloadOnStart: []))

        manager.preload([.banner, .interstitial, .rewarded])

        XCTAssertEqual(Set(provider.preloadedPlacements), Set([.interstitial, .rewarded]))
    }

    func testPresentInterstitial_ReturnsSkippedWhenIneligible() async {
        await manager.start(with: makeConfiguration(isEligibleToShowAds: false))

        let result = await manager.presentInterstitial()

        XCTAssertEqual(result, .skippedIneligible)
        XCTAssertTrue(provider.presentedPlacements.isEmpty)
    }

    func testPresentInterstitial_ReturnsUnavailableWhenProviderHasNoAd() async {
        provider.presentationResults[.interstitial] = .unavailable
        await manager.start(with: makeConfiguration())

        let result = await manager.presentInterstitial()

        XCTAssertEqual(result, .unavailable)
        XCTAssertEqual(provider.presentedPlacements, [.interstitial])
    }

    func testPresentInterstitial_ForwardsLifecycleEvents() async {
        let recorder = EventRecorder()
        provider.presentationResults[.interstitial] = .shown
        provider.presentationEvents[.interstitial] = [
            .impression(.interstitial),
            .dismissed(.interstitial)
        ]
        await manager.start(with: makeConfiguration(eventRecorder: recorder))

        let result = await manager.presentInterstitial()

        XCTAssertEqual(result, .shown)
        XCTAssertEqual(
            recorder.events,
            [.impression(.interstitial), .dismissed(.interstitial)]
        )
    }

    func testPresentRewarded_ReturnsSkippedWhenIneligible() async {
        await manager.start(with: makeConfiguration(isEligibleToShowAds: false))

        let result = await manager.presentRewarded()

        XCTAssertEqual(result, .skippedIneligible)
        XCTAssertTrue(provider.presentedPlacements.isEmpty)
    }

    func testPresentRewarded_ReturnsUnavailableWhenProviderHasNoAd() async {
        provider.presentationResults[.rewarded] = .unavailable
        await manager.start(with: makeConfiguration())

        let result = await manager.presentRewarded()

        XCTAssertEqual(result, .unavailable)
        XCTAssertEqual(provider.presentedPlacements, [.rewarded])
    }

    func testPresentRewarded_ForwardsLifecycleEvents() async {
        let recorder = EventRecorder()
        provider.presentationResults[.rewarded] = .shown
        provider.presentationEvents[.rewarded] = [
            .impression(.rewarded),
            .dismissed(.rewarded)
        ]
        await manager.start(with: makeConfiguration(eventRecorder: recorder))

        let result = await manager.presentRewarded()

        XCTAssertEqual(result, .shown)
        XCTAssertEqual(
            recorder.events,
            [.impression(.rewarded), .dismissed(.rewarded)]
        )
    }

#if !targetEnvironment(simulator)
    func testStartIfNeeded_PreloadsAfterSwapFoundationKitStart() async throws {
        let sharedProvider = FakeAdsProvider()
        AdsManager.shared.setProviderFactoryForTesting(FakeAdsProviderFactory(provider: sharedProvider))

        let kitConfiguration = SwapFoundationKitConfiguration(
            appMetadata: AppMetaData(appGroupIdentifier: "tests.swapfoundationkit"),
            enableItemSync: false,
            enableNetworking: false
        )

        try await SwapFoundationKit.shared.start(with: kitConfiguration)

        let adsConfiguration = makeConfiguration(preloadOnStart: [.interstitial])
        await AdsManager.startIfNeeded(configuration: adsConfiguration)

        XCTAssertTrue(AdsManager.shared.isConfigured)
        XCTAssertEqual(sharedProvider.preloadedPlacements, [.interstitial])
    }
#endif

    func testAdsManager_StaysUnconfiguredWhenStartIfNeededNeverCalled() async throws {
        let configuration = SwapFoundationKitConfiguration(
            appMetadata: AppMetaData(appGroupIdentifier: "tests.swapfoundationkit"),
            enableItemSync: false,
            enableNetworking: false
        )

        try await SwapFoundationKit.shared.start(with: configuration)

        XCTAssertFalse(AdsManager.shared.isConfigured)
    }

#if targetEnvironment(simulator)
    func testStartIfNeeded_IsNoOpOnSimulator() async {
        AdsManager.shared.setProviderFactoryForTesting(FakeAdsProviderFactory(provider: FakeAdsProvider()))
        await AdsManager.startIfNeeded(configuration: makeConfiguration(preloadOnStart: [.interstitial]))
        XCTAssertFalse(AdsManager.shared.isConfigured)
    }
#endif

    private func makeConfiguration(
        preloadOnStart: Set<AdPlacement> = [],
        isEligibleToShowAds: Bool = true,
        eventRecorder: EventRecorder? = nil
    ) -> AdsConfiguration {
        AdsConfiguration(
            provider: .google(GoogleAdsConfiguration()),
            adUnits: AdUnitConfiguration(
                banner: "banner",
                interstitial: "interstitial",
                rewarded: "rewarded"
            ),
            preloadOnStart: preloadOnStart,
            isEligibleToShowAds: { isEligibleToShowAds },
            presentingViewController: { UIViewController() },
            eventHandler: { event in
                eventRecorder?.events.append(event)
            }
        )
    }
}

private struct FakeAdsProviderFactory: AdsProviderFactory {
    let provider: FakeAdsProvider

    func makeProvider(from configuration: AdsProviderConfiguration) -> AdsProvider {
        provider
    }
}

@MainActor
private final class FakeAdsProvider: AdsProvider {
    var didStart = false
    var preloadedPlacements: [AdPlacement] = []
    var presentedPlacements: [AdPlacement] = []
    var presentationResults: [AdPlacement: AdPresentationResult] = [:]
    var presentationEvents: [AdPlacement: [AdLifecycleEvent]] = [:]

    func start() async {
        didStart = true
    }

    func preload(
        _ placement: AdPlacement,
        adUnitID: String,
        eventHandler: @escaping @MainActor (AdLifecycleEvent) -> Void
    ) {
        preloadedPlacements.append(placement)
    }

    func present(
        _ placement: AdPlacement,
        adUnitID: String,
        from viewController: UIViewController,
        eventHandler: @escaping @MainActor (AdLifecycleEvent) -> Void
    ) async -> AdPresentationResult {
        presentedPlacements.append(placement)
        for event in presentationEvents[placement] ?? [] {
            eventHandler(event)
        }
        return presentationResults[placement] ?? .shown
    }

    func makeBannerViewController(
        adUnitID: String,
        eventHandler: @escaping @MainActor (AdLifecycleEvent) -> Void
    ) -> UIViewController {
        UIViewController()
    }
}

private final class EventRecorder {
    var events: [AdLifecycleEvent] = []
}
#endif
