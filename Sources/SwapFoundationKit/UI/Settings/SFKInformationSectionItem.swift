//
//  SFKInformationSectionItem.swift
//  SwapFoundationKit
//
//  Created by Swapnanil Dhol on 4/4/26.
//

import Foundation
import SwiftUI

/// Standard information/reporting/rating section items for settings screens.
///
/// These are common settings items that appear in most iOS apps:
/// - Version info
/// - Report a bug / feedback
/// - Rate on the App Store
/// - Share with friends
/// - Privacy Policy
/// - Terms and Conditions
///
/// ## Usage
/// ```swift
/// ForEach(SFKInformationSectionItem.allCases, id: \.id) { item in
///     SFKSettingsRow(item: item) {
///         handleAction(item)
///     }
/// }
/// ```
public enum SFKInformationSectionItem: String, SettingsItem {

    /// Shows the current app version.
    case version

    /// Report a bug or send feedback via email.
    case reportABug

    /// Rate/review the app on the App Store.
    case rateOnTheAppStore

    /// Share the app with friends.
    case referToFriends

    /// Link to the app's privacy policy.
    case privacyPolicy

    /// Link to the app's terms and conditions.
    case termsAndConditions

    public var id: String { rawValue }

    public var icon: String {
        switch self {
        case .version:
            return "info.circle.fill"
        case .reportABug:
            return "ant.circle.fill"
        case .rateOnTheAppStore:
            return "star.circle.fill"
        case .referToFriends:
            return "person.2.circle"
        case .privacyPolicy, .termsAndConditions:
            return "globe"
        }
    }

    public var title: String {
        switch self {
        case .version:
            return "Version"
        case .reportABug:
            return "Report a Bug"
        case .rateOnTheAppStore:
            return "Rate on the App Store"
        case .referToFriends:
            return "Refer to Friends"
        case .privacyPolicy:
            return "Privacy Policy"
        case .termsAndConditions:
            return "Terms and Conditions"
        }
    }

    public var subtitle: String {
        switch self {
        case .version:
            return "See what's new in the latest update."
        case .reportABug:
            return "Email feedback or a bug report directly to the developer."
        case .rateOnTheAppStore:
            return "Leave a rating or review to help other users."
        case .referToFriends:
            return "Share the app with someone who might enjoy it."
        case .privacyPolicy:
            return "Read how the app handles your data and privacy."
        case .termsAndConditions:
            return "Review the terms that apply to your use of the app."
        }
    }

    public var tint: Color {
        switch self {
        case .version:
            return .secondary
        case .reportABug:
            return .orange
        case .rateOnTheAppStore:
            return .yellow
        case .referToFriends:
            return .pink
        case .privacyPolicy, .termsAndConditions:
            return .blue
        }
    }
}
