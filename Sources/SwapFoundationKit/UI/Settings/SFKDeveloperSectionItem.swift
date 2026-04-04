//
//  SFKDeveloperSectionItem.swift
//  SwapFoundationKit
//
//  Created by Swapnanil Dhol on 4/4/26.
//

import Foundation
import SwiftUI

/// Developer information section items for settings screens.
///
/// These are common developer-related settings items:
/// - Website link
/// - Social media (Twitter/X)
/// - Link to other apps by the developer
///
/// ## Usage
/// ```swift
/// ForEach(SFKDeveloperSectionItem.allCases, id: \.id) { item in
///     SFKSettingsRow(item: item) {
///         handleAction(item)
///     }
/// }
/// ```
public enum SFKDeveloperSectionItem: String, SettingsItem {

    /// Link to the developer's website.
    case website

    /// Link to the developer's Twitter/X profile.
    case twitter

    /// Link to view another app by the same developer.
    case anotherApp

    public var id: String { rawValue }

    public var icon: String {
        switch self {
        case .website:
            return "globe"
        case .twitter:
            return "heart.circle"
        case .anotherApp:
            return "heart.circle.fill"
        }
    }

    public var title: String {
        switch self {
        case .website:
            return "Website"
        case .twitter:
            return "Twitter (X)"
        case .anotherApp:
            return "View Another App"
        }
    }

    public var subtitle: String {
        switch self {
        case .website:
            return "Visit the developer website."
        case .twitter:
            return "Follow updates and product notes."
        case .anotherApp:
            return "See another app from the same developer."
        }
    }

    public var tint: Color {
        switch self {
        case .website:
            return .blue
        case .twitter:
            return .purple
        case .anotherApp:
            return .pink
        }
    }
}
