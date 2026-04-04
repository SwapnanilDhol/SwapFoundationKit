//
//  SFKSettingsActionHandler.swift
//  SwapFoundationKit
//
//  Created by Swapnanil Dhol on 4/4/26.
//

import Foundation

#if canImport(UIKit) && os(iOS)
import UIKit
import StoreKit
#endif

// MARK: - SFKSettingsActionHandler

/// A helper class for handling common settings item actions.
///
/// Provides methods for:
/// - Opening App Store review page
/// - Sharing the app
/// - Opening URLs (privacy policy, terms, developer website)
///
/// ## Usage
/// ```swift
/// let handler = SFKSettingsActionHandler(appID: "123456789")
///
/// // In your settings action handler:
/// if let item = item as? SFKInformationSectionItem {
///     switch item {
///     case .rateOnTheAppStore:
///         handler.rateOnTheAppStore()
///     case .share:
///         handler.shareApp(shareText: "Try this app!", appURL: url)
///     default:
///         break
///     }
/// }
/// ```
@MainActor
public final class SFKSettingsActionHandler {

    #if canImport(UIKit) && os(iOS)
    private let appID: String
    private weak var presentingViewController: UIViewController?

    /// Creates a settings action handler.
    /// - Parameters:
    ///   - appID: The App Store ID of the app.
    ///   - presentingViewController: Optional view controller for presenting sheets. Defaults to top view controller.
    public init(appID: String, presentingViewController: UIViewController? = nil) {
        self.appID = appID
        self.presentingViewController = presentingViewController
    }

    /// Opens the App Store review page for the app.
    public func rateOnTheAppStore() {
        let reviewURL = URL(string: "itms-apps://itunes.apple.com/app/id\(appID)?action=write-review")
        let fallbackURL = URL(string: "https://apps.apple.com/app/id\(appID)?action=write-review")

        guard let targetURL = reviewURL ?? fallbackURL else { return }

        if let presentedVC = presentingViewController ?? topViewController {
            presentedVC.dismiss(animated: true) {
                UIApplication.shared.open(targetURL)
            }
        } else {
            UIApplication.shared.open(targetURL)
        }
    }

    /// Shares the app using a UIActivityViewController.
    /// - Parameters:
    ///   - shareText: Custom text to include in the share.
    ///   - appURL: The App Store URL of the app.
    public func shareApp(shareText: String, appURL: URL) {
        let items: [Any] = [shareText, appURL]
        let activityController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityController.popoverPresentationController?.sourceView = topViewController?.view

        if let presenter = presentingViewController ?? topViewController {
            presenter.present(activityController, animated: true)
        }
    }

    /// Opens a URL in the system browser.
    /// - Parameter url: The URL to open.
    public func openURL(_ url: URL) {
        UIApplication.shared.open(url)
    }

    /// Opens a URL from a string.
    /// - Parameter urlString: The URL string to open.
    public func openURLString(_ urlString: String) {
        if let url = URL(string: urlString) {
            openURL(url)
        }
    }

    /// Requests a review from the user using SKStoreReviewController.
    /// Note: May not always show a prompt due to Apple's rate limiting.
    @available(iOS 14.0, *)
    public func requestReview() {
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }

    private var topViewController: UIViewController? {
        UIApplication.topViewController()
    }
    #else
    /// Creates a settings action handler (stub for non-iOS platforms).
    public init(appID: String, presentingViewController: Any? = nil) {}

    /// Opens the App Store review page (stub for non-iOS platforms).
    public func rateOnTheAppStore() {}

    /// Shares the app (stub for non-iOS platforms).
    public func shareApp(shareText: String, appURL: URL) {}

    /// Opens a URL (stub for non-iOS platforms).
    public func openURL(_ url: URL) {}

    /// Opens a URL from string (stub for non-iOS platforms).
    public func openURLString(_ urlString: String) {}

    /// Requests a review (stub for non-iOS platforms).
    public func requestReview() {}
    #endif
}

// MARK: - SFKInformationSectionHandler

/// A type-erased handler for SFKInformationSectionItem taps.
public struct SFKInformationSectionHandler {
    private let handler: SFKSettingsActionHandler
    private let privacyPolicyURL: URL?
    private let termsURL: URL?

    /// Creates an information section handler.
    /// - Parameters:
    ///   - handler: The settings action handler.
    ///   - privacyPolicyURL: Optional URL for privacy policy. Opens Apple's standard if nil.
    ///   - termsURL: Optional URL for terms and conditions. Opens Apple's standard if nil.
    public init(
        handler: SFKSettingsActionHandler,
        privacyPolicyURL: URL? = nil,
        termsURL: URL? = nil
    ) {
        self.handler = handler
        self.privacyPolicyURL = privacyPolicyURL
        self.termsURL = termsURL
    }

    /// Handles a tap on an information section item.
    /// - Parameter item: The tapped item.
    /// - Returns: `true` if the item was handled, `false` otherwise.
    @discardableResult
    @MainActor
    public func handle(_ item: SFKInformationSectionItem) -> Bool {
        switch item {
        case .version:
            return false // No action needed
        case .reportABug:
            return false
        case .rateOnTheAppStore:
            handler.rateOnTheAppStore()
            return true
        case .referToFriends:
            return false
        case .privacyPolicy:
            if let url = privacyPolicyURL {
                handler.openURL(url)
            } else {
                handler.openURLString("https://www.apple.com/legal/privacy/")
            }
            return true
        case .termsAndConditions:
            if let url = termsURL {
                handler.openURL(url)
            } else {
                handler.openURLString("https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")
            }
            return true
        }
    }
}

// MARK: - SFKDeveloperSectionHandler

/// A type-erased handler for SFKDeveloperSectionItem taps.
public struct SFKDeveloperSectionHandler {
    private let handler: SFKSettingsActionHandler
    private let websiteURL: URL?
    private let twitterURL: URL?

    /// Creates a developer section handler.
    /// - Parameters:
    ///   - handler: The settings action handler.
    ///   - websiteURL: URL for the developer website.
    ///   - twitterURL: URL for the Twitter/X profile.
    public init(
        handler: SFKSettingsActionHandler,
        websiteURL: URL? = nil,
        twitterURL: URL? = nil
    ) {
        self.handler = handler
        self.websiteURL = websiteURL
        self.twitterURL = twitterURL
    }

    /// Handles a tap on a developer section item.
    /// - Parameter item: The tapped item.
    /// - Returns: `true` if the item was handled, `false` otherwise.
    @discardableResult
    @MainActor
    public func handle(_ item: SFKDeveloperSectionItem) -> Bool {
        switch item {
        case .website:
            if let url = websiteURL {
                handler.openURL(url)
                return true
            }
            return false
        case .twitter:
            if let url = twitterURL {
                handler.openURL(url)
                return true
            }
            return false
        case .anotherApp:
            return false
        }
    }
}
