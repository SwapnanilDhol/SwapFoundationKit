/*****************************************************************************
 * SFKAppPromotion.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import StoreKit
import SwiftUI
import UIKit

/// Another app from the same developer that a host app can promote.
///
/// Keep the copy short and specific: `pitch` is one line under the app name.
/// `urlScheme` lets the host hide the promotion from people who already have
/// the app; the scheme must also be listed under `LSApplicationQueriesSchemes`
/// in the host's Info.plist, or `isInstalled` always reports `false`.
public struct SFKAppPromotion: Sendable, Hashable {
    public let appStoreID: String
    public let name: String
    public let pitch: String
    public let actionTitle: String
    /// An image in the host app's asset catalog, usually the promoted app's icon.
    public let iconImageName: String?
    public let urlScheme: String?
    /// The App Analytics provider token (`pt`), if the account has one.
    public let providerToken: String?

    public init(
        appStoreID: String,
        name: String,
        pitch: String,
        actionTitle: String,
        iconImageName: String? = nil,
        urlScheme: String? = nil,
        providerToken: String? = nil
    ) {
        self.appStoreID = appStoreID
        self.name = name
        self.pitch = pitch
        self.actionTitle = actionTitle
        self.iconImageName = iconImageName
        self.urlScheme = urlScheme
        self.providerToken = providerToken
    }

    /// Whether the promoted app is installed, judged by its URL scheme.
    @MainActor
    public var isInstalled: Bool {
        guard let urlScheme, let url = URL(string: "\(urlScheme)://") else { return false }
        return UIApplication.shared.canOpenURL(url)
    }

    /// The public App Store page, tagged with a campaign token (`ct`) so App
    /// Analytics attributes installs to the placement that drove them.
    public func appStoreURL(campaignToken: String? = nil) -> URL {
        var components = URLComponents(string: "https://apps.apple.com/app/id\(appStoreID)")!
        var items: [URLQueryItem] = []
        if let campaignToken { items.append(URLQueryItem(name: "ct", value: campaignToken)) }
        if let providerToken { items.append(URLQueryItem(name: "pt", value: providerToken)) }
        components.queryItems = items.isEmpty ? nil : items
        return components.url!
    }
}

/// Shows a promoted app's App Store page without leaving the host app.
@MainActor
public enum SFKAppStorePresenter {

    /// Presents the system App Store overlay along the bottom of the active
    /// scene. Falls back to opening the App Store page when no scene is active.
    ///
    /// - Parameter campaignToken: Names the placement (for example
    ///   `goaley_home`) so App Analytics can tell placements apart.
    public static func present(_ promotion: SFKAppPromotion, campaignToken: String? = nil) {
        guard let scene = activeScene else {
            UIApplication.shared.open(promotion.appStoreURL(campaignToken: campaignToken))
            return
        }
        let configuration = SKOverlay.AppConfiguration(
            appIdentifier: promotion.appStoreID,
            position: .bottom
        )
        configuration.campaignToken = campaignToken
        configuration.providerToken = promotion.providerToken
        SKOverlay(configuration: configuration).present(in: scene)
    }

    private static var activeScene: UIWindowScene? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }
    }
}
