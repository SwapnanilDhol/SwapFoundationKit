import Combine
import Foundation
import UpdateAvailableKit

/// SFK bridge around `UpdateAvailableKit` used by app surfaces that render
/// update prompts (for example `SFKUpdateAvailableBannerView`).
@MainActor
public final class SFKUpdateAvailabilityService: ObservableObject {
    public static let shared = SFKUpdateAvailabilityService()

    /// Version currently shown in UI. `nil` means no banner.
    @Published public var bannerVersion: String?

    private var resultObserver: AnyCancellable?

    private init() {
        resultObserver = UpdateAvailableManager.shared.$result
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                switch result {
                case .updateAvailable(let newVersion):
                    self?.bannerVersion = newVersion
                case .noUpdatesAvailable:
                    self?.bannerVersion = nil
                }
            }
    }

    /// Starts the update availability check flow.
    public func start() {
        UpdateAvailableManager.shared.start()
    }

    /// Clears currently visible banner state.
    public func dismissBanner() {
        bannerVersion = nil
    }
}
