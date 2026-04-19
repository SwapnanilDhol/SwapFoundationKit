/*****************************************************************************
 * GoogleAdsProvider.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

#if !targetEnvironment(simulator) && canImport(UIKit) && canImport(GoogleMobileAds)
import GoogleMobileAds
import UIKit

@MainActor
final class GoogleAdsProvider: NSObject, AdsProvider {
    private let configuration: GoogleAdsConfiguration

    private var interstitialAd: InterstitialAd?
    private var rewardedAd: RewardedAd?
    private var isLoadingInterstitial = false
    private var isLoadingRewarded = false
    private var interstitialDelegate: GoogleFullScreenAdDelegate?
    private var rewardedDelegate: GoogleFullScreenAdDelegate?

    init(configuration: GoogleAdsConfiguration) {
        self.configuration = configuration
    }

    func start() async {
        await MobileAds.shared.start()
    }

    func preload(
        _ placement: AdPlacement,
        adUnitID: String,
        eventHandler: @escaping @MainActor (AdLifecycleEvent) -> Void
    ) {
        switch placement {
        case .banner:
            break
        case .interstitial:
            loadInterstitial(adUnitID: adUnitID, eventHandler: eventHandler)
        case .rewarded:
            loadRewarded(adUnitID: adUnitID, eventHandler: eventHandler)
        }
    }

    func present(
        _ placement: AdPlacement,
        adUnitID: String,
        from viewController: UIViewController,
        eventHandler: @escaping @MainActor (AdLifecycleEvent) -> Void
    ) async -> AdPresentationResult {
        switch placement {
        case .banner:
            return .failed
        case .interstitial:
            guard let interstitialAd else { return .unavailable }
            self.interstitialAd = nil
            return await presentInterstitial(
                interstitialAd,
                adUnitID: adUnitID,
                from: viewController,
                eventHandler: eventHandler
            )
        case .rewarded:
            guard let rewardedAd else { return .unavailable }
            self.rewardedAd = nil
            return await presentRewarded(
                rewardedAd,
                adUnitID: adUnitID,
                from: viewController,
                eventHandler: eventHandler
            )
        }
    }

    func makeBannerViewController(
        adUnitID: String,
        eventHandler: @escaping @MainActor (AdLifecycleEvent) -> Void
    ) -> UIViewController {
        GoogleAdaptiveBannerViewController(adUnitID: adUnitID, eventHandler: eventHandler)
    }

    private func loadInterstitial(
        adUnitID: String,
        eventHandler: @escaping @MainActor (AdLifecycleEvent) -> Void
    ) {
        guard !isLoadingInterstitial else { return }
        isLoadingInterstitial = true

        InterstitialAd.load(with: adUnitID, request: Request()) { [weak self] ad, error in
            Task { @MainActor in
                guard let self else { return }
                self.isLoadingInterstitial = false

                if let error {
                    eventHandler(.failed(.interstitial, message: error.localizedDescription))
                    return
                }

                self.interstitialAd = ad
                eventHandler(.loaded(.interstitial))
            }
        }
    }

    private func loadRewarded(
        adUnitID: String,
        eventHandler: @escaping @MainActor (AdLifecycleEvent) -> Void
    ) {
        guard !isLoadingRewarded else { return }
        isLoadingRewarded = true

        RewardedAd.load(with: adUnitID, request: Request()) { [weak self] ad, error in
            Task { @MainActor in
                guard let self else { return }
                self.isLoadingRewarded = false

                if let error {
                    eventHandler(.failed(.rewarded, message: error.localizedDescription))
                    return
                }

                self.rewardedAd = ad
                eventHandler(.loaded(.rewarded))
            }
        }
    }

    private func presentInterstitial(
        _ interstitialAd: InterstitialAd,
        adUnitID: String,
        from viewController: UIViewController,
        eventHandler: @escaping @MainActor (AdLifecycleEvent) -> Void
    ) async -> AdPresentationResult {
        await withCheckedContinuation { continuation in
            let delegate = GoogleFullScreenAdDelegate(
                placement: .interstitial,
                eventHandler: eventHandler
            ) { [weak self] result in
                continuation.resume(returning: result)
                self?.interstitialDelegate = nil
                self?.loadInterstitial(adUnitID: adUnitID, eventHandler: eventHandler)
            }

            interstitialDelegate = delegate
            interstitialAd.fullScreenContentDelegate = delegate
            interstitialAd.present(from: viewController)
        }
    }

    private func presentRewarded(
        _ rewardedAd: RewardedAd,
        adUnitID: String,
        from viewController: UIViewController,
        eventHandler: @escaping @MainActor (AdLifecycleEvent) -> Void
    ) async -> AdPresentationResult {
        await withCheckedContinuation { continuation in
            let delegate = GoogleFullScreenAdDelegate(
                placement: .rewarded,
                eventHandler: eventHandler
            ) { [weak self] result in
                continuation.resume(returning: result)
                self?.rewardedDelegate = nil
                self?.loadRewarded(adUnitID: adUnitID, eventHandler: eventHandler)
            }

            rewardedDelegate = delegate
            rewardedAd.fullScreenContentDelegate = delegate
            rewardedAd.present(from: viewController) { }
        }
    }
}

@MainActor
private final class GoogleFullScreenAdDelegate: NSObject, FullScreenContentDelegate {
    private let placement: AdPlacement
    private let eventHandler: @MainActor (AdLifecycleEvent) -> Void
    private let completion: @MainActor (AdPresentationResult) -> Void
    private var hasCompleted = false

    init(
        placement: AdPlacement,
        eventHandler: @escaping @MainActor (AdLifecycleEvent) -> Void,
        completion: @escaping @MainActor (AdPresentationResult) -> Void
    ) {
        self.placement = placement
        self.eventHandler = eventHandler
        self.completion = completion
    }

    nonisolated func adDidRecordImpression(_ ad: any FullScreenPresentingAd) {
        Task { @MainActor in
            eventHandler(.impression(placement))
        }
    }

    nonisolated func adDidRecordClick(_ ad: any FullScreenPresentingAd) {
        Task { @MainActor in
            eventHandler(.click(placement))
        }
    }

    nonisolated func ad(
        _ ad: any FullScreenPresentingAd,
        didFailToPresentFullScreenContentWithError error: any Error
    ) {
        Task { @MainActor in
            eventHandler(.failed(placement, message: error.localizedDescription))
            complete(with: .failed)
        }
    }

    nonisolated func adDidDismissFullScreenContent(_ ad: any FullScreenPresentingAd) {
        Task { @MainActor in
            eventHandler(.dismissed(placement))
            complete(with: .shown)
        }
    }

    private func complete(with result: AdPresentationResult) {
        guard !hasCompleted else { return }
        hasCompleted = true
        completion(result)
    }
}

@MainActor
private final class GoogleAdaptiveBannerViewController: UIViewController {
    private let adUnitID: String
    private let eventHandler: @MainActor (AdLifecycleEvent) -> Void
    private let bannerView = BannerView()
    private var widthConstraint: NSLayoutConstraint?
    private var heightConstraint: NSLayoutConstraint?

    init(
        adUnitID: String,
        eventHandler: @escaping @MainActor (AdLifecycleEvent) -> Void
    ) {
        self.adUnitID = adUnitID
        self.eventHandler = eventHandler
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        bannerView.adUnitID = adUnitID
        bannerView.rootViewController = self
        bannerView.delegate = self
        view.addSubview(bannerView)

        let widthConstraint = bannerView.widthAnchor.constraint(equalToConstant: 0)
        let heightConstraint = bannerView.heightAnchor.constraint(equalToConstant: 0)
        self.widthConstraint = widthConstraint
        self.heightConstraint = heightConstraint

        NSLayoutConstraint.activate([
            bannerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bannerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            widthConstraint,
            heightConstraint
        ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadBannerAd()
    }

    override func viewWillTransition(
        to size: CGSize,
        with coordinator: UIViewControllerTransitionCoordinator
    ) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { _ in
            self.bannerView.isHidden = true
        } completion: { _ in
            self.bannerView.isHidden = false
            self.loadBannerAd()
        }
    }

    private func loadBannerAd() {
        let viewWidth = max(view.bounds.inset(by: view.safeAreaInsets).width, UIScreen.main.bounds.width)
        let adSize = currentOrientationAnchoredAdaptiveBanner(width: viewWidth)
        widthConstraint?.constant = adSize.size.width
        heightConstraint?.constant = adSize.size.height
        bannerView.adSize = adSize
        bannerView.load(Request())
    }
}

extension GoogleAdaptiveBannerViewController: BannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: BannerView) {
        eventHandler(.loaded(.banner))
    }

    func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: any Error) {
        eventHandler(.failed(.banner, message: error.localizedDescription))
    }

    func bannerViewDidRecordImpression(_ bannerView: BannerView) {
        eventHandler(.impression(.banner))
    }

    func bannerViewDidRecordClick(_ bannerView: BannerView) {
        eventHandler(.click(.banner))
    }
}
#endif
