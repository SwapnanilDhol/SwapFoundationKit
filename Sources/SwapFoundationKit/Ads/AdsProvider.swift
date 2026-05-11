/*****************************************************************************
 * AdsProvider.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import UIKit

@MainActor
protocol AdsProvider: AnyObject {
    func start() async
    func preload(
        _ placement: AdPlacement,
        adUnitID: String,
        eventHandler: @escaping @MainActor (AdLifecycleEvent) -> Void
    )
    func present(
        _ placement: AdPlacement,
        adUnitID: String,
        from viewController: UIViewController,
        eventHandler: @escaping @MainActor (AdLifecycleEvent) -> Void
    ) async -> AdPresentationResult
    func makeBannerViewController(
        adUnitID: String,
        eventHandler: @escaping @MainActor (AdLifecycleEvent) -> Void
    ) -> UIViewController
}

@MainActor
protocol AdsProviderFactory {
    func makeProvider(from configuration: AdsProviderConfiguration) -> AdsProvider
}

@MainActor
private final class NoOpAdsProvider: AdsProvider {
    func start() async { }

    func preload(
        _ placement: AdPlacement,
        adUnitID: String,
        eventHandler: @escaping @MainActor (AdLifecycleEvent) -> Void
    ) { }

    func present(
        _ placement: AdPlacement,
        adUnitID: String,
        from viewController: UIViewController,
        eventHandler: @escaping @MainActor (AdLifecycleEvent) -> Void
    ) async -> AdPresentationResult {
        .unavailable
    }

    func makeBannerViewController(
        adUnitID: String,
        eventHandler: @escaping @MainActor (AdLifecycleEvent) -> Void
    ) -> UIViewController {
        EmptyBannerViewController()
    }
}

@MainActor
struct DefaultAdsProviderFactory: AdsProviderFactory {
    func makeProvider(from configuration: AdsProviderConfiguration) -> AdsProvider {
        switch configuration {
        case .google:
            return NoOpAdsProvider()
        }
    }
}
