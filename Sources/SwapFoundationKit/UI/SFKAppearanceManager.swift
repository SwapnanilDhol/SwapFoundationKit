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

    /// Rounded title font shared by `configure()` and `applyRoundedFonts(to:)` so
    /// re-applied appearances always match the initial configuration.
    private static let titleFont = UIFont.roundedSystemFont(ofSize: 17, weight: .semibold)
    /// Rounded large-title font shared by `configure()` and `applyRoundedFonts(to:)`.
    private static let largeTitleFont = UIFont.roundedSystemFont(ofSize: 34, weight: .bold)
    /// Rounded bar-button font shared by `configure()` and `applyRoundedFonts(to:)`.
    private static let barButtonFont = UIFont.roundedSystemFont(ofSize: 17, weight: .semibold)
    /// Rounded font used for tab bar item titles.
    private static let tabFont = UIFont.roundedSystemFont(ofSize: 10, weight: .semibold)
    /// Rounded font used for segmented control titles.
    private static let segmentedFont = UIFont.roundedSystemFont(ofSize: 13, weight: .semibold)

    /// Applies rounded system font to all UIKit chrome.
    ///
    /// Affects:
    /// - `UINavigationBar` title, large title, bar buttons
    /// - `UITabBar` item normal and selected labels
    /// - `UIBarButtonItem` normal and highlighted
    /// - `UISegmentedControl` normal and selected
    public static func configure() {
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

        reinforceRoundedNavigationTypography()
    }

    /// Patches a live navigation bar after SwiftUI may have replaced its appearances.
    ///
    /// SwiftUI modifiers like `toolbarBackground` synthesize fresh, per-instance
    /// `UINavigationBarAppearance` values that do not inherit the `UINavigationBar.appearance()`
    /// proxy configured by `configure()`. Call this from a hosting controller's lifecycle methods
    /// (see `SFKRoundedHostingController`) to keep rounded typography applied after SwiftUI
    /// re-synthesizes those appearances.
    public static func applyRoundedFonts(to navigationBar: UINavigationBar) {
        navigationBar.titleTextAttributes = [.font: titleFont]
        navigationBar.largeTitleTextAttributes = [.font: largeTitleFont]

        let appearances = [
            navigationBar.standardAppearance,
            navigationBar.scrollEdgeAppearance,
            navigationBar.compactAppearance,
            navigationBar.compactScrollEdgeAppearance
        ].compactMap { $0 }

        appearances.forEach(applyRoundedFonts(to:))
    }

    /// Patches navigation-item appearances SwiftUI synthesizes for toolbar backgrounds.
    public static func applyRoundedFonts(to navigationItem: UINavigationItem) {
        [
            navigationItem.standardAppearance,
            navigationItem.scrollEdgeAppearance,
            navigationItem.compactAppearance,
            navigationItem.compactScrollEdgeAppearance
        ]
        .compactMap { $0 }
        .forEach(applyRoundedFonts(to:))
    }

    /// SwiftUI can synthesize a new navigation-bar appearance when a view uses
    /// toolbar background modifiers. Keep the direct appearance-proxy values in
    /// sync so those synthesized appearances still resolve to rounded fonts.
    private static func reinforceRoundedNavigationTypography() {
        let navigationBar = UINavigationBar.appearance()

        navigationBar.titleTextAttributes = [.font: titleFont]
        navigationBar.largeTitleTextAttributes = [.font: largeTitleFont]

        let appearances = [
            navigationBar.standardAppearance,
            navigationBar.scrollEdgeAppearance,
            navigationBar.compactAppearance,
            navigationBar.compactScrollEdgeAppearance
        ].compactMap { $0 }

        appearances.forEach(applyRoundedFonts(to:))
        navigationBar.compactScrollEdgeAppearance = navigationBar.compactAppearance

        let barButton = UIBarButtonItem.appearance()
        [UIControl.State.normal, .highlighted, .disabled, .focused].forEach { state in
            barButton.setTitleTextAttributes([.font: barButtonFont], for: state)
        }
    }

    private static func applyRoundedFonts(to appearance: UINavigationBarAppearance) {
        appearance.titleTextAttributes[.font] = titleFont
        appearance.largeTitleTextAttributes[.font] = largeTitleFont
        apply(barButtonFont, to: appearance.buttonAppearance)
        apply(barButtonFont, to: appearance.doneButtonAppearance)
        apply(barButtonFont, to: appearance.backButtonAppearance)
    }

    private static func apply(_ font: UIFont, to appearance: UIBarButtonItemAppearance) {
        appearance.normal.titleTextAttributes[.font] = font
        appearance.highlighted.titleTextAttributes[.font] = font
        appearance.disabled.titleTextAttributes[.font] = font
        appearance.focused.titleTextAttributes[.font] = font
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
