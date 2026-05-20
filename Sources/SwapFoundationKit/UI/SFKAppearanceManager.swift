#if canImport(UIKit) && os(iOS)
import UIKit
import SwiftUI

/// Configures global UIKit appearance with a rounded font design.
///
/// Call `SFKAppearanceManager.configure()` early in `application(_:didFinishLaunchingWithOptions:)`
/// to apply a consistent rounded typography to navigation bars, tab bars, bar button items,
/// tab bar items, and segmented controls.
///
/// ## Usage
/// ```swift
/// SFKAppearanceManager.configure()
/// ```
@MainActor
public enum SFKAppearanceManager {

    /// Applies rounded system font to all UIKit chrome.
    ///
    /// Affects:
    /// - `UINavigationBar` title, large title, bar buttons
    /// - `UITabBar` item normal and selected labels
    /// - `UIBarButtonItem` normal and highlighted
    /// - `UISegmentedControl` normal and selected
    public static func configure() {
        let titleFont = UIFont.roundedSystemFont(ofSize: 17, weight: .semibold)
        let largeTitleFont = UIFont.roundedSystemFont(ofSize: 34, weight: .bold)
        let barButtonFont = UIFont.roundedSystemFont(ofSize: 17, weight: .semibold)
        let tabFont = UIFont.roundedSystemFont(ofSize: 10, weight: .semibold)
        let segmentedFont = UIFont.roundedSystemFont(ofSize: 13, weight: .semibold)

        let navigationAppearance = UINavigationBarAppearance()
        navigationAppearance.configureWithDefaultBackground()
        navigationAppearance.titleTextAttributes = [.font: titleFont]
        navigationAppearance.largeTitleTextAttributes = [.font: largeTitleFont]
        navigationAppearance.buttonAppearance.normal.titleTextAttributes = [.font: barButtonFont]
        navigationAppearance.doneButtonAppearance.normal.titleTextAttributes = [.font: barButtonFont]
        navigationAppearance.backButtonAppearance.normal.titleTextAttributes = [.font: barButtonFont]

        UINavigationBar.appearance().standardAppearance = navigationAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationAppearance
        UINavigationBar.appearance().compactAppearance = navigationAppearance

        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = .systemBackground

        let layoutAppearances = [
            tabBarAppearance.stackedLayoutAppearance,
            tabBarAppearance.inlineLayoutAppearance,
            tabBarAppearance.compactInlineLayoutAppearance
        ]
        layoutAppearances.forEach { appearance in
            appearance.normal.titleTextAttributes = [.font: tabFont]
            appearance.selected.titleTextAttributes = [.font: tabFont]
        }

        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance

        UIBarButtonItem.appearance().setTitleTextAttributes([.font: barButtonFont], for: .normal)
        UIBarButtonItem.appearance().setTitleTextAttributes([.font: barButtonFont], for: .highlighted)

        UITabBarItem.appearance().setTitleTextAttributes([.font: tabFont], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([.font: tabFont], for: .selected)

        UISegmentedControl.appearance().setTitleTextAttributes([.font: segmentedFont], for: .normal)
        UISegmentedControl.appearance().setTitleTextAttributes([.font: segmentedFont], for: .selected)
    }
}

public extension UIFont {
    /// Returns a rounded variant of `systemFont(ofSize:weight:)`.
    ///
    /// Falls back to the standard system font if the rounded design is unavailable.
    static func roundedSystemFont(ofSize size: CGFloat, weight: Weight) -> UIFont {
        let baseFont = UIFont.systemFont(ofSize: size, weight: weight)
        guard let descriptor = baseFont.fontDescriptor.withDesign(.rounded) else { return baseFont }
        return UIFont(descriptor: descriptor, size: size)
    }
}
#endif
