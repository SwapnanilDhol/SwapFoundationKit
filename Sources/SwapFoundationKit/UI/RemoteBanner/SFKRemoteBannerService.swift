/*****************************************************************************
 * SFKRemoteBannerService.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import Foundation

/// Fetches a remote banner file, keeps the last good copy, and decides which
/// banner, if any, this install should see.
///
/// The service remembers per banner `id` how many launches have shown it and
/// whether it was dismissed, so a banner stops appearing once it has used its
/// `maxImpressions` (one by default) or the person closes it. Publishing a
/// new `id` starts fresh. An empty `banners` array takes every banner down.
///
/// The last file fetched is kept across launches, so a banner can appear
/// before the network answers and while offline. Give time-limited banners an
/// `endsAt`, which holds even when the file cannot be refreshed.
///
/// ## Usage
/// ```swift
/// let banners = SFKRemoteBannerService(url: URL(string: "https://example.com/app/banners.json")!)
///
/// await banners.refresh()
/// if let banner = banners.banner(for: .init(isPro: isPro)) {
///     banners.recordImpression(of: banner)
///     // Show SFKRemoteBannerCard(banner: banner, ...)
/// }
/// ```
@MainActor
public final class SFKRemoteBannerService {

    private struct Ledger: Codable {
        var impressions: [String: Int] = [:]
        var dismissed: Set<String> = []
    }

    private let url: URL
    private let userDefaults: UserDefaults
    private let minimumRefreshInterval: TimeInterval
    private let transport: @Sendable (URLRequest) async throws -> (Data, URLResponse)
    private let payloadKey: String
    private let ledgerKey: String

    private var banners: [SFKRemoteBanner]
    private var ledger: Ledger
    private var lastRefresh: Date?
    /// Banners already counted for this launch; they stay visible until the
    /// app is relaunched even after their last impression is spent.
    private var shownThisLaunch: Set<String> = []

    /// - Parameters:
    ///   - url: Where the payload described on ``SFKRemoteBanner`` is hosted.
    ///   - userDefaults: Holds the cached payload and the impression ledger.
    ///   - storageKey: Prefix for the two defaults keys the service owns.
    ///   - minimumRefreshInterval: ``refresh(force:)`` is a no-op when the last
    ///     successful fetch is more recent than this.
    ///   - transport: The network call, replaceable in tests.
    public init(
        url: URL,
        userDefaults: UserDefaults = .standard,
        storageKey: String = "sfk.remoteBanner",
        minimumRefreshInterval: TimeInterval = 15 * 60,
        transport: @escaping @Sendable (URLRequest) async throws -> (Data, URLResponse) = {
            try await URLSession.shared.data(for: $0)
        }
    ) {
        self.url = url
        self.userDefaults = userDefaults
        self.minimumRefreshInterval = minimumRefreshInterval
        self.transport = transport
        self.payloadKey = storageKey + ".payload"
        self.ledgerKey = storageKey + ".ledger"
        self.banners = userDefaults.data(forKey: payloadKey)
            .flatMap { try? SFKRemoteBanner.banners(fromPayload: $0) } ?? []
        self.ledger = userDefaults.data(forKey: ledgerKey)
            .flatMap { try? JSONDecoder().decode(Ledger.self, from: $0) } ?? Ledger()
    }

    /// Downloads the payload and replaces the cached copy.
    ///
    /// A failed request, a non-200 response or an unreadable file leaves the
    /// cached copy in place.
    ///
    /// - Returns: `true` when a payload was fetched and stored.
    @discardableResult
    public func refresh(force: Bool = false) async -> Bool {
        if !force, let lastRefresh, Date().timeIntervalSince(lastRefresh) < minimumRefreshInterval {
            return false
        }
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.timeoutInterval = 15
        do {
            let (data, response) = try await transport(request)
            if let http = response as? HTTPURLResponse, http.statusCode != 200 { return false }
            banners = try SFKRemoteBanner.banners(fromPayload: data)
            userDefaults.set(data, forKey: payloadKey)
            lastRefresh = Date()
            return true
        } catch {
            return false
        }
    }

    /// The banner to show now, with its copy localized, or `nil`.
    ///
    /// Picks the highest `priority` among banners whose targeting accepts
    /// `context`, that have impressions left and were not dismissed. Ties go
    /// to the banner listed first in the payload.
    public func banner(for context: SFKRemoteBanner.Context) -> SFKRemoteBanner? {
        var best: SFKRemoteBanner?
        for banner in banners where isAvailable(banner) && banner.isEligible(in: context) {
            if best == nil || banner.priority > best!.priority { best = banner }
        }
        return best?.localized(for: context.languageCode)
    }

    /// Counts one impression for this launch. Repeated calls in the same
    /// launch count once.
    public func recordImpression(of banner: SFKRemoteBanner) {
        guard shownThisLaunch.insert(banner.id).inserted else { return }
        ledger.impressions[banner.id, default: 0] += 1
        persistLedger()
    }

    /// Hides the banner for good.
    public func dismiss(_ banner: SFKRemoteBanner) {
        ledger.dismissed.insert(banner.id)
        persistLedger()
    }

    private func isAvailable(_ banner: SFKRemoteBanner) -> Bool {
        guard !ledger.dismissed.contains(banner.id) else { return false }
        return shownThisLaunch.contains(banner.id)
            || ledger.impressions[banner.id, default: 0] < banner.maxImpressions
    }

    private func persistLedger() {
        guard let data = try? JSONEncoder().encode(ledger) else { return }
        userDefaults.set(data, forKey: ledgerKey)
    }
}
