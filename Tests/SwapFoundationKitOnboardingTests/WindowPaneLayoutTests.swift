/*****************************************************************************
 * WindowPaneLayoutTests.swift
 * SwapFoundationKitOnboardingTests
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI
import Testing
@testable import SwapFoundationKitOnboarding

@Suite("Window pane layout")
struct WindowPaneLayoutTests {

    @Test("Compact width keeps one column however wide the window is")
    func compactWidthIsSingle() {
        #expect(SFKWindowPaneLayout.resolve(sizeClass: .compact, width: 466) == .single)
        #expect(SFKWindowPaneLayout.resolve(sizeClass: .compact, width: 1_000) == .single)
        #expect(SFKWindowPaneLayout.resolve(sizeClass: nil, width: 1_000) == .single)
    }

    @Test("Regular width needs room for two phone-shaped panes")
    func regularWidthNeedsTwoPanes() {
        // iPhone Duo inner display (951 pt) and iPad landscape split in two.
        #expect(SFKWindowPaneLayout.resolve(sizeClass: .regular, width: 951) == .twoPane)
        #expect(SFKWindowPaneLayout.resolve(sizeClass: .regular, width: 1_180) == .twoPane)
        #expect(SFKWindowPaneLayout.resolve(sizeClass: .regular, width: 880) == .twoPane)
        // Regular but too narrow for two panes keeps the single column.
        #expect(SFKWindowPaneLayout.resolve(sizeClass: .regular, width: 879) == .single)
        #expect(SFKWindowPaneLayout.resolve(sizeClass: .regular, width: 820) == .single)
    }

    @Test("The split sits on the window's centre, not the safe area's")
    func splitUsesWindowCentre() {
        // Inner display with an 84 pt vertical bar on the trailing edge.
        let split = SFKTwoPaneSplit(safeAreaWidth: 867, leadingInset: 0, trailingInset: 84)
        let gutter = SFKTwoPaneSplit.gutter

        #expect(split.leadingWidth == 475.5 - gutter / 2)
        #expect(split.trailingWidth == 867 - 475.5 - gutter / 2)
        #expect(split.leadingWidth + gutter + split.trailingWidth == 867)
    }

    @Test("Symmetric window splits into equal panes")
    func symmetricSplitIsEven() {
        let split = SFKTwoPaneSplit(safeAreaWidth: 1_180, leadingInset: 0, trailingInset: 0)
        #expect(split.leadingWidth == split.trailingWidth)
    }

    @Test("resolve returns nil when the window keeps one column")
    func resolveReturnsNilForSingleColumn() {
        let compact = SFKTwoPaneSplit.resolve(
            sizeClass: .compact,
            size: CGSize(width: 382, height: 678),
            safeAreaInsets: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 84)
        )
        #expect(compact == nil)

        // Safe width alone (867) is under 880; the full window (951) is not.
        let inner = SFKTwoPaneSplit.resolve(
            sizeClass: .regular,
            size: CGSize(width: 867, height: 669),
            safeAreaInsets: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 84)
        )
        #expect(inner != nil)
    }
}

@Suite("Wide window mode")
struct WideWindowModeTests {

    @Test("Only the centred column carries a width")
    func centredColumnWidth() {
        #expect(SFKOnboardingWideWindowMode.twoPane.centredColumnWidth == nil)
        #expect(SFKOnboardingWideWindowMode.centredColumn().centredColumnWidth == 560)
        #expect(SFKOnboardingWideWindowMode.centredColumn(maxWidth: 420).centredColumnWidth == 420)
    }

    @Test("Icon stage fits its pane")
    func iconStageFits() {
        #expect(SFKOnboardingLayout.iconStageWidth(fitting: 2_000) == SFKOnboardingLayout.iconStageWidth)
        #expect(abs(SFKOnboardingLayout.iconStageWidth(fitting: 400) - 200) < 0.001)
        #expect(SFKOnboardingLayout.iconStageWidth(fitting: 100) == 0)
    }
}
