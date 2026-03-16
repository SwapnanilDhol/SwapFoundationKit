import Foundation

#if canImport(UIKit)
import UIKit
public typealias AdsPresentationViewController = UIViewController
#else
public protocol AdsPresentationViewController: AnyObject { }
#endif

public enum AdPlacement: String, CaseIterable, Sendable {
    case banner
    case interstitial
    case rewarded
}

public enum AdLifecycleEvent: Sendable, Equatable {
    case loaded(AdPlacement)
    case failed(AdPlacement, message: String?)
    case impression(AdPlacement)
    case click(AdPlacement)
    case dismissed(AdPlacement)
}

public enum AdPresentationResult: Sendable, Equatable {
    case shown
    case skippedIneligible
    case unavailable
    case failed
}

public struct AdUnitConfiguration: Sendable, Equatable {
    public let banner: String
    public let interstitial: String
    public let rewarded: String

    public init(
        banner: String,
        interstitial: String,
        rewarded: String
    ) {
        self.banner = banner
        self.interstitial = interstitial
        self.rewarded = rewarded
    }

    internal func adUnitID(for placement: AdPlacement) -> String {
        switch placement {
        case .banner:
            return banner
        case .interstitial:
            return interstitial
        case .rewarded:
            return rewarded
        }
    }
}

public struct GoogleAdsConfiguration: Sendable, Equatable {
    public init() { }
}

public enum AdsProviderConfiguration: Sendable, Equatable {
    case google(GoogleAdsConfiguration)
}

public struct AdsConfiguration {
    public let provider: AdsProviderConfiguration
    public let adUnits: AdUnitConfiguration
    public let preloadOnStart: Set<AdPlacement>
    public let isEligibleToShowAds: @MainActor () -> Bool
    public let presentingViewController: @MainActor () -> AdsPresentationViewController?
    public let eventHandler: @MainActor (AdLifecycleEvent) -> Void

    public init(
        provider: AdsProviderConfiguration,
        adUnits: AdUnitConfiguration,
        preloadOnStart: Set<AdPlacement> = [],
        isEligibleToShowAds: @escaping @MainActor () -> Bool,
        presentingViewController: @escaping @MainActor () -> AdsPresentationViewController?,
        eventHandler: @escaping @MainActor (AdLifecycleEvent) -> Void = { _ in }
    ) {
        self.provider = provider
        self.adUnits = adUnits
        self.preloadOnStart = preloadOnStart
        self.isEligibleToShowAds = isEligibleToShowAds
        self.presentingViewController = presentingViewController
        self.eventHandler = eventHandler
    }
}
