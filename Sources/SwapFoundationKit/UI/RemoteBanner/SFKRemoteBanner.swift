/*****************************************************************************
 * SFKRemoteBanner.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import Foundation

/// A banner described by a remote JSON file: a sale, an announcement, a notice.
///
/// The host app hosts one small file and ``SFKRemoteBannerService`` fetches it,
/// so copy, dates and targeting change without an app update.
///
/// ## Payload
/// ```json
/// {
///   "banners": [
///     {
///       "id": "black-friday-2026",
///       "title": "Black Friday: 50% off Pro",
///       "message": "Until Monday night.",
///       "symbol": "tag.fill",
///       "tint": "#FF3B30",
///       "action": { "type": "paywall", "plan": "lifetime" },
///       "startsAt": "2026-11-27T00:00:00Z",
///       "endsAt": "2026-12-01T08:00:00Z",
///       "maxImpressions": 3,
///       "priority": 10,
///       "audience": {
///         "plan": "free",
///         "minAppVersion": "1.16.1",
///         "regions": ["US", "GB"],
///         "languages": ["en"]
///       },
///       "localizations": {
///         "de": { "title": "Black Friday: 50 % auf Pro", "message": "Bis Montagnacht." }
///       }
///     }
///   ]
/// }
/// ```
///
/// Only `id` and `title` are required. The whole card is the tap target:
/// `action.type` is `paywall`, `url` (with a `url` string) or absent. `audience.plan` is `all` (default), `free`
/// or `pro`. Dates are ISO 8601 with a time zone. `maxImpressions` defaults to
/// `1`: a banner is shown during one launch and not again. A banner this build
/// cannot read (missing `id`, unknown action type, malformed date) is skipped
/// and the rest of the file still loads.
public struct SFKRemoteBanner: Identifiable, Equatable, Sendable {

    /// What tapping the banner does. The host performs it.
    public enum Action: Equatable, Sendable {
        /// The banner only informs and is not tappable.
        case none
        /// Open the host's paywall, optionally with a plan in front. `plan` is
        /// whatever identifies a plan to the host, such as a package identifier.
        case paywall(plan: String?)
        /// Open a link: an offer-code redemption URL, an App Store page, a web page.
        case url(URL)
    }

    /// Who may see the banner. Every rule that is set must match.
    public struct Audience: Equatable, Sendable {
        public enum Plan: String, Sendable {
            case all, free, pro
        }

        public var plan: Plan
        /// Inclusive lower bound on the host app's marketing version.
        public var minAppVersion: String?
        /// Inclusive upper bound on the host app's marketing version.
        public var maxAppVersion: String?
        /// ISO region codes such as `US`. `nil` means every region.
        public var regions: [String]?
        /// Language codes such as `en` or `zh-Hans`. `nil` means every language.
        public var languages: [String]?

        public init(
            plan: Plan = .all,
            minAppVersion: String? = nil,
            maxAppVersion: String? = nil,
            regions: [String]? = nil,
            languages: [String]? = nil
        ) {
            self.plan = plan
            self.minAppVersion = minAppVersion
            self.maxAppVersion = maxAppVersion
            self.regions = regions
            self.languages = languages
        }
    }

    /// The facts about this install that targeting is judged against.
    public struct Context: Equatable, Sendable {
        public var isPro: Bool
        public var appVersion: String
        public var regionCode: String?
        /// The language the app is running in, such as `de` or `zh-Hans`.
        public var languageCode: String?
        public var now: Date

        public init(
            isPro: Bool,
            appVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "",
            regionCode: String? = Locale.current.region?.identifier,
            languageCode: String? = Bundle.main.preferredLocalizations.first,
            now: Date = Date()
        ) {
            self.isPro = isPro
            self.appVersion = appVersion
            self.regionCode = regionCode
            self.languageCode = languageCode
            self.now = now
        }
    }

    public let id: String
    public var title: String
    public var message: String?
    /// An SF Symbol name. Set after `init`; the payload key is `symbol`.
    public var symbolName: String?
    /// A hex color such as `#FF3B30` for the symbol. Set after
    /// `init`; the payload key is `tint`.
    public var tintHex: String?
    public var action: Action
    public var audience: Audience
    public var startsAt: Date?
    public var endsAt: Date?
    /// How many launches may show the banner before it stops appearing.
    public var maxImpressions: Int
    /// The higher priority wins when several banners are eligible.
    public var priority: Int

    var localizations: [String: LocalizedCopy] = [:]

    public init(
        id: String,
        title: String,
        message: String? = nil,
        action: Action = .none,
        audience: Audience = Audience(),
        startsAt: Date? = nil,
        endsAt: Date? = nil,
        maxImpressions: Int = 1,
        priority: Int = 0
    ) {
        self.id = id
        self.title = title
        self.message = message
        self.action = action
        self.audience = audience
        self.startsAt = startsAt
        self.endsAt = endsAt
        self.maxImpressions = max(1, maxImpressions)
        self.priority = priority
    }

    /// Whether the date window and every audience rule accept this install.
    ///
    /// This does not look at impressions or dismissal; ``SFKRemoteBannerService``
    /// adds those.
    public func isEligible(in context: Context) -> Bool {
        if let startsAt, context.now < startsAt { return false }
        if let endsAt, context.now >= endsAt { return false }

        switch audience.plan {
        case .all: break
        case .free: if context.isPro { return false }
        case .pro: if !context.isPro { return false }
        }

        if let minimum = audience.minAppVersion,
           Self.compareVersions(context.appVersion, minimum) == .orderedAscending {
            return false
        }
        if let maximum = audience.maxAppVersion,
           Self.compareVersions(context.appVersion, maximum) == .orderedDescending {
            return false
        }
        if let regions = audience.regions {
            guard let region = context.regionCode?.uppercased(),
                  regions.contains(where: { $0.uppercased() == region })
            else { return false }
        }
        if let languages = audience.languages {
            guard let language = context.languageCode,
                  languages.contains(where: { Self.language(language, matches: $0) })
            else { return false }
        }
        return true
    }

    /// The banner with its copy replaced by the best matching localization.
    ///
    /// `zh-Hans` matches a `zh-Hans` entry first, then a `zh` entry. Fields a
    /// localization leaves out keep the default copy.
    public func localized(for languageCode: String?) -> SFKRemoteBanner {
        guard let languageCode, !localizations.isEmpty else { return self }
        let copy = localizations.first { $0.key.lowercased() == languageCode.lowercased() }?.value
            ?? localizations.first { Self.language(languageCode, matches: $0.key) }?.value
        guard let copy else { return self }
        var banner = self
        if let title = copy.title { banner.title = title }
        if let message = copy.message { banner.message = message }
        return banner
    }

    /// Decodes a payload file, dropping the banners this build cannot read.
    ///
    /// - Throws: When the file itself is not a `{ "banners": [...] }` object.
    public static func banners(fromPayload data: Data) throws -> [SFKRemoteBanner] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(Payload.self, from: data).banners.compactMap(\.banner)
    }

    /// Compares dotted versions number by number, so `1.16` equals `1.16.0`
    /// and `1.9` sorts before `1.10`.
    static func compareVersions(_ lhs: String, _ rhs: String) -> ComparisonResult {
        let left = lhs.split(separator: ".").map { Int($0) ?? 0 }
        let right = rhs.split(separator: ".").map { Int($0) ?? 0 }
        for index in 0..<max(left.count, right.count) {
            let l = index < left.count ? left[index] : 0
            let r = index < right.count ? right[index] : 0
            if l != r { return l < r ? .orderedAscending : .orderedDescending }
        }
        return .orderedSame
    }

    /// `de` covers `de-AT`; an exact match always counts.
    private static func language(_ code: String, matches candidate: String) -> Bool {
        let code = code.lowercased()
        let candidate = candidate.lowercased()
        return code == candidate || code.hasPrefix(candidate + "-")
    }
}

// MARK: - Decoding

extension SFKRemoteBanner {

    struct LocalizedCopy: Equatable, Sendable, Decodable {
        var title: String?
        var message: String?
    }

    private struct Payload: Decodable {
        let banners: [Lenient]
    }

    /// One array element that failed to decode must not fail the whole file.
    private struct Lenient: Decodable {
        let banner: SFKRemoteBanner?

        init(from decoder: Decoder) throws {
            banner = try? SFKRemoteBanner(from: decoder)
        }
    }
}

extension SFKRemoteBanner: Decodable {

    private enum CodingKeys: String, CodingKey {
        case id, title, message, symbol, tint, action, audience
        case startsAt, endsAt, maxImpressions, priority, localizations
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(String.self, forKey: .id)
        let title = try container.decode(String.self, forKey: .title)
        guard !id.isEmpty, !title.isEmpty else {
            throw DecodingError.dataCorruptedError(
                forKey: .id, in: container, debugDescription: "A banner needs an id and a title."
            )
        }
        self.init(
            id: id,
            title: title,
            message: try container.decodeIfPresent(String.self, forKey: .message),
            action: try container.decodeIfPresent(Action.self, forKey: .action) ?? .none,
            audience: try container.decodeIfPresent(Audience.self, forKey: .audience) ?? Audience(),
            startsAt: try container.decodeIfPresent(Date.self, forKey: .startsAt),
            endsAt: try container.decodeIfPresent(Date.self, forKey: .endsAt),
            maxImpressions: try container.decodeIfPresent(Int.self, forKey: .maxImpressions) ?? 1,
            priority: try container.decodeIfPresent(Int.self, forKey: .priority) ?? 0
        )
        symbolName = try container.decodeIfPresent(String.self, forKey: .symbol)
        tintHex = try container.decodeIfPresent(String.self, forKey: .tint)
        localizations = try container.decodeIfPresent(
            [String: LocalizedCopy].self, forKey: .localizations
        ) ?? [:]
    }
}

extension SFKRemoteBanner.Action: Decodable {

    private enum CodingKeys: String, CodingKey {
        case type, plan, url
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "none":
            self = .none
        case "paywall":
            self = .paywall(plan: try container.decodeIfPresent(String.self, forKey: .plan))
        case "url":
            let string = try container.decode(String.self, forKey: .url)
            guard let url = URL(string: string), url.scheme != nil else {
                throw DecodingError.dataCorruptedError(
                    forKey: .url, in: container, debugDescription: "Not a URL: \(string)"
                )
            }
            self = .url(url)
        default:
            // A newer payload asking for something this build cannot do.
            throw DecodingError.dataCorruptedError(
                forKey: .type, in: container, debugDescription: "Unknown action type: \(type)"
            )
        }
    }
}

extension SFKRemoteBanner.Audience: Decodable {

    private enum CodingKeys: String, CodingKey {
        case plan, minAppVersion, maxAppVersion, regions, languages
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let planName = try container.decodeIfPresent(String.self, forKey: .plan) ?? Plan.all.rawValue
        // An unknown plan must not widen the audience to everyone.
        guard let plan = Plan(rawValue: planName) else {
            throw DecodingError.dataCorruptedError(
                forKey: .plan, in: container, debugDescription: "Unknown plan: \(planName)"
            )
        }
        self.init(
            plan: plan,
            minAppVersion: try container.decodeIfPresent(String.self, forKey: .minAppVersion),
            maxAppVersion: try container.decodeIfPresent(String.self, forKey: .maxAppVersion),
            regions: try container.decodeIfPresent([String].self, forKey: .regions),
            languages: try container.decodeIfPresent([String].self, forKey: .languages)
        )
    }
}
