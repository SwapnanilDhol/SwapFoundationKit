#if canImport(UIKit) && canImport(GoogleMobileAds)
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
struct DefaultAdsProviderFactory: AdsProviderFactory {
    func makeProvider(from configuration: AdsProviderConfiguration) -> AdsProvider {
        switch configuration {
        case .google(let googleConfiguration):
            return GoogleAdsProvider(configuration: googleConfiguration)
        }
    }
}
#endif
