import Combine
import Foundation

public enum SFKUpdateAvailabilityResult: Equatable, Sendable {
    case noUpdatesAvailable
    case updateAvailable(newVersion: String)
}

public struct SFKUpdateAvailabilityConfiguration: Equatable, Sendable {
    public var bundleID: String?
    public var currentVersion: String?
    public var cacheDuration: TimeInterval

    public init(
        bundleID: String? = nil,
        currentVersion: String? = nil,
        cacheDuration: TimeInterval = 60 * 60 * 6
    ) {
        self.bundleID = bundleID
        self.currentVersion = currentVersion
        self.cacheDuration = cacheDuration
    }
}

/// Built-in App Store version lookup service used by app surfaces that render
/// update prompts (for example `SFKUpdateAvailableBannerView`).
@MainActor
public final class SFKUpdateAvailabilityService: ObservableObject {
    public static let shared = SFKUpdateAvailabilityService()

    @Published public private(set) var result: SFKUpdateAvailabilityResult = .noUpdatesAvailable

    /// Version currently shown in UI. `nil` means no banner.
    @Published public private(set) var bannerVersion: String?

    public var newVersion: String? {
        if case .updateAvailable(let version) = result {
            return version
        }
        return nil
    }

    private let session: URLSession
    private var configuration = SFKUpdateAvailabilityConfiguration()
    private var lastCheckedAt: Date?
    private var isChecking = false

    init(session: URLSession = .shared) {
        self.session = session
    }

    public func configure(with configuration: SFKUpdateAvailabilityConfiguration) {
        self.configuration = configuration
    }

    /// Starts the update availability check flow.
    public func start() {
        guard !isChecking else { return }

        if let lastCheckedAt,
           configuration.cacheDuration > 0,
           Date().timeIntervalSince(lastCheckedAt) < configuration.cacheDuration {
            apply(result)
            return
        }

        let activeConfiguration = configuration
        isChecking = true

        Task { [weak self] in
            guard let self else { return }
            let result = await self.checkForUpdate(configuration: activeConfiguration)
            await MainActor.run {
                self.lastCheckedAt = Date()
                self.isChecking = false
                self.apply(result)
            }
        }
    }

    /// Clears currently visible banner state.
    public func dismissBanner() {
        bannerVersion = nil
    }

    func checkForUpdate(configuration: SFKUpdateAvailabilityConfiguration) async -> SFKUpdateAvailabilityResult {
        let bundleID = configuration.bundleID ?? Bundle.main.bundleIdentifier ?? ""
        let currentVersion = configuration.currentVersion ?? Self.currentAppVersion

        guard !bundleID.isEmpty, !currentVersion.isEmpty else {
            return .noUpdatesAvailable
        }

        do {
            guard let latestVersion = try await fetchLatestVersion(bundleID: bundleID) else {
                return .noUpdatesAvailable
            }

            if Self.isVersion(latestVersion, newerThan: currentVersion) {
                return .updateAvailable(newVersion: latestVersion)
            }
            return .noUpdatesAvailable
        } catch {
            return .noUpdatesAvailable
        }
    }

    private func fetchLatestVersion(bundleID: String) async throws -> String? {
        var components = URLComponents(string: "https://itunes.apple.com/lookup")
        components?.queryItems = [
            URLQueryItem(name: "bundleId", value: bundleID)
        ]

        guard let url = components?.url else {
            throw URLError(.badURL)
        }

        let (data, _) = try await session.data(from: url)
        let response = try JSONDecoder().decode(ITunesLookupResponse.self, from: data)
        return response.results.first?.version
    }

    private func apply(_ result: SFKUpdateAvailabilityResult) {
        self.result = result
        switch result {
        case .updateAvailable(let newVersion):
            bannerVersion = newVersion
        case .noUpdatesAvailable:
            bannerVersion = nil
        }
    }

    nonisolated static var currentAppVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
            ?? Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
            ?? ""
    }

    nonisolated static func isVersion(_ lhs: String, newerThan rhs: String) -> Bool {
        lhs.compare(rhs, options: .numeric) == .orderedDescending
    }
}

private struct ITunesLookupResponse: Decodable {
    let results: [ITunesLookupResult]
}

private struct ITunesLookupResult: Decodable {
    let version: String
}
