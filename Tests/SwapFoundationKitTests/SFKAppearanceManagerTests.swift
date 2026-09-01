/****************************************************************************
 * SFKAppearanceManagerTests.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import Testing
#if canImport(UIKit) && os(iOS)
import UIKit
@testable import SwapFoundationKit

@MainActor
struct SFKAppearanceManagerTests {

    @Test
    func roundedSystemFontProducesARoundedDescriptor() {
        let roundedFont = UIFont.roundedSystemFont(ofSize: 17, weight: .semibold)
        let plainFont = UIFont.systemFont(ofSize: 17, weight: .semibold)

        #expect(isRounded(roundedFont))
        #expect(!isRounded(plainFont))
    }

    @Test
    func applyRoundedFontsToNavigationBarPatchesEveryAppearanceSlot() {
        let navigationBar = UINavigationBar()
        // `standardAppearance` is always non-nil; the rest default to nil until assigned.
        navigationBar.scrollEdgeAppearance = UINavigationBarAppearance()
        navigationBar.compactAppearance = UINavigationBarAppearance()
        navigationBar.compactScrollEdgeAppearance = UINavigationBarAppearance()

        SFKAppearanceManager.applyRoundedFonts(to: navigationBar)

        #expect(isRounded(navigationBar.titleTextAttributes?[.font] as? UIFont))
        #expect(isRounded(navigationBar.largeTitleTextAttributes?[.font] as? UIFont))

        let appearances = [
            navigationBar.standardAppearance,
            navigationBar.scrollEdgeAppearance,
            navigationBar.compactAppearance,
            navigationBar.compactScrollEdgeAppearance
        ].compactMap { $0 }
        #expect(appearances.count == 4)

        for appearance in appearances {
            assertRoundedFonts(on: appearance)
        }
    }

    @Test
    func applyRoundedFontsToNavigationItemPatchesEveryAppearanceSlot() {
        let navigationItem = UINavigationItem(title: "Test")
        // All four slots default to nil on a fresh item; assign them so the patch has
        // something to touch, mirroring what SwiftUI's toolbar synthesis produces at runtime.
        navigationItem.standardAppearance = UINavigationBarAppearance()
        navigationItem.scrollEdgeAppearance = UINavigationBarAppearance()
        navigationItem.compactAppearance = UINavigationBarAppearance()
        navigationItem.compactScrollEdgeAppearance = UINavigationBarAppearance()

        SFKAppearanceManager.applyRoundedFonts(to: navigationItem)

        let appearances = [
            navigationItem.standardAppearance,
            navigationItem.scrollEdgeAppearance,
            navigationItem.compactAppearance,
            navigationItem.compactScrollEdgeAppearance
        ].compactMap { $0 }
        #expect(appearances.count == 4)

        for appearance in appearances {
            assertRoundedFonts(on: appearance)
        }
    }

    // MARK: - Helpers

    private func assertRoundedFonts(on appearance: UINavigationBarAppearance) {
        #expect(isRounded(appearance.titleTextAttributes[.font] as? UIFont))
        #expect(isRounded(appearance.largeTitleTextAttributes[.font] as? UIFont))
        #expect(isRounded(appearance.buttonAppearance.normal.titleTextAttributes[.font] as? UIFont))
        #expect(isRounded(appearance.doneButtonAppearance.normal.titleTextAttributes[.font] as? UIFont))
        #expect(isRounded(appearance.backButtonAppearance.normal.titleTextAttributes[.font] as? UIFont))
    }

    /// System rounded fonts resolve to a concrete font whose name contains "Rounded"
    /// (e.g. `.AppleSystemUIFontRounded-Semibold`). Descriptor-level equality checks are
    /// unreliable here because `UIFont.systemFont` descriptors use an opaque
    /// `NSCTFontUIUsageAttribute` shorthand that does not round-trip through `withDesign(_:)`
    /// equality, so this checks the resolved font's public `fontName` instead.
    private func isRounded(_ font: UIFont?) -> Bool {
        guard let font else { return false }
        return font.fontName.localizedCaseInsensitiveContains("rounded")
    }
}
#endif
