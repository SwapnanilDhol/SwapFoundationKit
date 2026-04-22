/*****************************************************************************
 * UpdateAvailableBannerView.swift
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

/// State representing update availability.
///
/// Use this to pass update state into ``SFKUpdateAvailableBannerView``.
///
/// ## Usage
/// ```swift
/// @State private var updateState: UpdateBannerState = .none
///
/// // When update is detected:
/// updateState = .available(newVersion: "2.1.0")
///
/// SFKUpdateAvailableBannerView(state: $updateState)
/// ```
public enum UpdateBannerState: Equatable {
    /// No update available.
    case none
    /// An update is available.
    /// - Parameter version: The new version string from the App Store.
    case available(newVersion: String)
}

/// Displays an update available banner when a new app version is detected.
///
/// Tapping the banner opens the App Store listing for the app (`https://apps.apple.com/app/id…`).
///
/// ## Usage
/// ```swift
/// SFKUpdateAvailableBannerView(
///     newVersion: "2.1.0",
///     appStoreID: "123456789"
/// ) {
///     // Optional: analytics, clear local banner state, etc.
/// }
/// ```
public struct SFKUpdateAvailableBannerView: View {

    private let newVersion: String?
    private let theme: UpdateAvailableBannerTheme
    private let appStoreID: String?
    private let onTap: (() -> Void)?

    /// Creates a banner bound to an ``UpdateBannerState``.
    /// - Parameters:
    ///   - state: Binding to the current banner state. Set to ``UpdateBannerState/available`` to show.
    ///   - theme: Theme configuration. Defaults to ``UpdateAvailableBannerTheme/default``.
    ///   - appStoreID: Your app's App Store ID. Defaults to `nil` (falls back to bundle identifier in the URL; prefer passing the numeric ID).
    ///   - onTap: Optional callback after the App Store URL is opened (e.g. analytics).
    public init(
        state: Binding<UpdateBannerState>,
        theme: UpdateAvailableBannerTheme = .default,
        appStoreID: String? = nil,
        onTap: (() -> Void)? = nil
    ) {
        self.newVersion = nil
        self.theme = theme
        self.appStoreID = appStoreID
        self.onTap = onTap
    }

    /// Creates a banner with an explicit new version string.
    /// - Parameters:
    ///   - newVersion: The new version string to display. Pass `nil` to hide the banner.
    ///   - theme: Theme configuration. Defaults to ``UpdateAvailableBannerTheme/default``.
    ///   - appStoreID: Your app's App Store ID. Defaults to `nil` (falls back to bundle identifier in the URL; prefer passing the numeric ID).
    ///   - onTap: Optional callback after the App Store URL is opened (e.g. analytics).
    public init(
        newVersion: String?,
        theme: UpdateAvailableBannerTheme = .default,
        appStoreID: String? = nil,
        onTap: (() -> Void)? = nil
    ) {
        self.newVersion = newVersion
        self.theme = theme
        self.appStoreID = appStoreID
        self.onTap = onTap
    }

    public var body: some View {
        if let version = newVersion {
            bannerContent(version: version)
                .transition(.move(edge: .top).combined(with: .opacity))
        }
    }

    @ViewBuilder
    private func bannerContent(version: String) -> some View {
        VStack(spacing: 0) {
            Button {
                openAppStore()
                onTap?()
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: theme.iconName)
                        .font(.title2)
                        .foregroundStyle(theme.titleColor)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Update Available")
                            .font(.headline)
                            .foregroundStyle(theme.titleColor)

                        Text("Version \(version) is now available")
                            .font(.caption)
                            .foregroundStyle(theme.subtitleColor)
                    }

                    Spacer(minLength: 8)

                    Text(theme.buttonTitle)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(theme.buttonTitleColor)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(theme.buttonColor, in: Capsule())
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            Divider()
        }
        .background(theme.backgroundColor)
    }

    private func openAppStore() {
        let id = appStoreID ?? Bundle.main.bundleIdentifier ?? ""
        if let url = URL(string: "https://apps.apple.com/app/id\(id)") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Previews

#if DEBUG
#Preview("Update Available") {
    VStack {
        Spacer()
        SFKUpdateAvailableBannerView(
            newVersion: "2.1.0",
            appStoreID: "123456789"
        )
    }
    .preferredColorScheme(.dark)
}

#Preview("Custom Theme") {
    VStack {
        Spacer()
        SFKUpdateAvailableBannerView(
            newVersion: "3.0.0",
            theme: UpdateAvailableBannerTheme(
                backgroundColor: .orange.opacity(0.15),
                titleColor: .orange,
                iconName: "star.fill",
                buttonTitle: "Get Update",
                buttonColor: .orange
            ),
            appStoreID: "123456789"
        )
    }
    .preferredColorScheme(.dark)
}

#Preview("Hidden (nil version)") {
    VStack {
        Spacer()
        SFKUpdateAvailableBannerView(newVersion: nil)
        Text("Banner is hidden")
            .foregroundStyle(.secondary)
    }
}
#endif
