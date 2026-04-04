//
//  SettingsItem.swift
//  SwapFoundationKit
//
//  Created by Swapnanil Dhol on 4/4/26.
//

import Foundation
import SwiftUI

/// A protocol defining the contract for a settings row item.
///
/// Conforming types define the visual properties (icon, title, subtitle, tint)
/// and are used to build reusable settings rows in `SFKSettingsRow`.
///
/// Example usage:
/// ```swift
/// enum AppInfoSectionItem: String, SettingsItem {
///     case version
///     case rateApp
///
///     var id: String { rawValue }
///
///     var icon: String {
///         switch self {
///         case .version: return "info.circle.fill"
///         case .rateApp: return "star.circle.fill"
///         }
///     }
///
///     var title: String {
///         switch self {
///         case .version: return "Version"
///         case .rateApp: return "Rate App"
///         }
///     }
///
///     var subtitle: String {
///         switch self {
///         case .version: return "Current app version"
///         case .rateApp: return "Leave a review"
///         }
///     }
///
///     var tint: Color {
///         switch self {
///         case .version: return .secondary
///         case .rateApp: return .yellow
///         }
///     }
/// }
/// ```
public protocol SettingsItem: CaseIterable, Identifiable {
    /// A unique identifier for this settings item.
    var id: String { get }

    /// SF Symbol name for the icon displayed in the row.
    var icon: String { get }

    /// Primary text label for the row.
    var title: String { get }

    /// Secondary text label displayed below the title.
    var subtitle: String { get }

    /// Tint color applied to the icon background and icon itself.
    var tint: Color { get }
}
