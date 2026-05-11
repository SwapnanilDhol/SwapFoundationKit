/*****************************************************************************
 * AdsManager.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI
import UIKit

@MainActor
public final class AdsManager {
    public static let shared = AdsManager(providerFactory: DefaultAdsProviderFactory())

    private let providerFactory: AdsProviderFactory
    private var providerFactoryOverride: AdsProviderFactory?
    private var provider: AdsProvider?
    private(set) var configuration: AdsConfiguration?

    public var isConfigured: Bool {
        configuration != nil && provider != nil
    }

    private init(providerFactory: AdsProviderFactory) {
        self.providerFactory = providerFactory
    }

    internal static func makeForTesting(providerFactory: AdsProviderFactory) -> AdsManager {
        AdsManager(providerFactory: providerFactory)
    }

    public func start(with configuration: AdsConfiguration) async {
        self.configuration = configuration
        let provider = (providerFactoryOverride ?? providerFactory).makeProvider(from: configuration.provider)
        self.provider = provider
        await provider.start()
        preload(configuration.preloadOnStart)
    }

    public func preload(_ placements: Set<AdPlacement>) {
        guard let configuration, let provider else { return }

        for placement in placements {
            guard placement != .banner else { continue }
            provider.preload(
                placement,
                adUnitID: configuration.adUnits.adUnitID(for: placement),
                eventHandler: configuration.eventHandler
            )
        }
    }

    @available(*, deprecated, message: "AdMob support was removed from SwapFoundationKit.")
    public func presentInterstitial() async -> AdPresentationResult {
        await present(.interstitial)
    }

    @available(*, deprecated, message: "AdMob support was removed from SwapFoundationKit.")
    public func presentRewarded() async -> AdPresentationResult {
        await present(.rewarded)
    }

    private func present(_ placement: AdPlacement) async -> AdPresentationResult {
        guard let configuration, let provider else { return .failed }
        guard configuration.isEligibleToShowAds() else { return .skippedIneligible }
        guard let viewController = configuration.presentingViewController() else { return .failed }

        return await provider.present(
            placement,
            adUnitID: configuration.adUnits.adUnitID(for: placement),
            from: viewController,
            eventHandler: configuration.eventHandler
        )
    }

    @available(*, deprecated, message: "AdMob support was removed from SwapFoundationKit.")
    public func makeBannerViewController() -> UIViewController {
        guard
            let configuration,
            let provider,
            configuration.isEligibleToShowAds()
        else {
            return EmptyBannerViewController()
        }

        return provider.makeBannerViewController(
            adUnitID: configuration.adUnits.banner,
            eventHandler: configuration.eventHandler
        )
    }

    internal func resetForTesting() {
        configuration = nil
        provider = nil
        providerFactoryOverride = nil
    }

    internal func setProviderFactoryForTesting(_ providerFactory: AdsProviderFactory?) {
        providerFactoryOverride = providerFactory
    }
}

final class EmptyBannerViewController: UIViewController { }

/// Banner placeholder (AdMob removed; no ads are loaded).
public struct AdaptiveBannerAdView: UIViewControllerRepresentable {
    public init() {}

    public func makeUIViewController(context: Context) -> UIViewController {
        AdsManager.shared.makeBannerViewController()
    }

    public func updateUIViewController(_ uiViewController: UIViewController, context: Context) { }
}
