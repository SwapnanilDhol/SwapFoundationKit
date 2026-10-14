/*****************************************************************************
 * FoldRegionLayoutTests.swift
 * SwapFoundationKitOnboardingTests
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import CoreGraphics
import Testing
@testable import SwapFoundationKitOnboarding

struct SFKFoldRegionLayoutTests {
    /// Inner display of a book-folded iPhone Duo: 951 x 669 pt, fold centred at 475.5.
    private static let bookContainer = CGSize(width: 951, height: 669)
    private static let bookFold = CGRect(x: 455, y: 0, width: 41, height: 669)

    /// The same display held portrait and folded on a table.
    private static let tabletopContainer = CGSize(width: 669, height: 951)
    private static let tabletopFold = CGRect(x: 0, y: 455, width: 669, height: 41)

    @Test
    func noRegionIsFlatAndCentresTheColumn() {
        let layout = SFKFoldRegionLayout(containerSize: Self.bookContainer, divisionFrame: nil)

        #expect(layout.pose == .flat)
        #expect(layout.columnPane == nil)
        #expect(layout.columnFrame(maxWidth: 560) == CGRect(x: 195.5, y: 0, width: 560, height: 669))
        #expect(layout.placement(maxWidth: 560, contentHeight: 300) == .centred)
    }

    @Test
    func zeroWidthRegionOfAFlatDeviceIsFlat() {
        let layout = SFKFoldRegionLayout(
            containerSize: Self.bookContainer,
            divisionFrame: CGRect(x: 475.5, y: 0, width: 0, height: 669)
        )

        #expect(layout.pose == .flat)
        #expect(layout.placement(maxWidth: 560, contentHeight: nil) == .centred)
    }

    @Test
    func regionOutsideTheContainerIsFlat() {
        // A pane that sits entirely beside the fold (for example a split view column).
        let layout = SFKFoldRegionLayout(
            containerSize: CGSize(width: 400, height: 669),
            divisionFrame: CGRect(x: 420, y: 0, width: 41, height: 669)
        )

        #expect(layout.pose == .flat)
    }

    @Test
    func tallRegionIsABookWithLeftAndRightHalves() {
        let layout = SFKFoldRegionLayout(containerSize: Self.bookContainer, divisionFrame: Self.bookFold)

        #expect(
            layout.pose == .book(
                leading: CGRect(x: 0, y: 0, width: 455, height: 669),
                trailing: CGRect(x: 496, y: 0, width: 455, height: 669)
            )
        )
    }

    @Test
    func bookPlacesTheColumnInTheTrailingHalf() {
        let layout = SFKFoldRegionLayout(containerSize: Self.bookContainer, divisionFrame: Self.bookFold)

        let wide = layout.columnFrame(maxWidth: 560)
        #expect(wide == CGRect(x: 496, y: 0, width: 455, height: 669))

        let narrow = layout.columnFrame(maxWidth: 300)
        #expect(narrow == CGRect(x: 573.5, y: 0, width: 300, height: 669))
        #expect(narrow.minX >= Self.bookFold.maxX)

        #expect(layout.placement(maxWidth: 300, contentHeight: nil) == .bookPane(narrow))
        #expect(layout.placement(maxWidth: 300, contentHeight: 2000) == .bookPane(narrow))
    }

    @Test
    func shortContainerStillReadsABookFoldFromTheRegionShape() {
        // A footer 80pt tall clips the fold into a sliver wider than tall.
        let layout = SFKFoldRegionLayout(
            containerSize: CGSize(width: 819, height: 80),
            divisionFrame: CGRect(x: 431, y: -500, width: 41, height: 669)
        )

        #expect(
            layout.pose == .book(
                leading: CGRect(x: 0, y: 0, width: 431, height: 80),
                trailing: CGRect(x: 472, y: 0, width: 347, height: 80)
            )
        )
        #expect(layout.columnFrame(maxWidth: 560) == CGRect(x: 472, y: 0, width: 347, height: 80))
    }

    @Test
    func bookHalvesAreReportedOnlyWhenBothAreWideEnough() {
        // Measured on the book-folded Duo: an 835pt-wide card row, fold at x 439.5.
        let duo = SFKFoldRegionLayout(
            containerSize: CGSize(width: 835, height: 400),
            divisionFrame: CGRect(x: 439.5, y: -200, width: 40, height: 669)
        )
        let halves = duo.usableBookHalves
        #expect(halves != nil)
        #expect(halves?.leading == CGRect(x: 0, y: 0, width: 439.5, height: 400))
        #expect(halves?.trailing == CGRect(x: 479.5, y: 0, width: 355.5, height: 400))

        let lopsided = SFKFoldRegionLayout(
            containerSize: CGSize(width: 800, height: 400),
            divisionFrame: CGRect(x: 600, y: 0, width: 40, height: 400)
        )
        #expect(lopsided.usableBookHalves == nil)

        let flat = SFKFoldRegionLayout(containerSize: CGSize(width: 835, height: 400), divisionFrame: nil)
        #expect(flat.usableBookHalves == nil)

        let tabletop = SFKFoldRegionLayout(containerSize: Self.tabletopContainer, divisionFrame: Self.tabletopFold)
        #expect(tabletop.usableBookHalves == nil)
    }

    @Test
    func wideRegionIsTabletopWithTopAndBottomHalves() {
        let layout = SFKFoldRegionLayout(containerSize: Self.tabletopContainer, divisionFrame: Self.tabletopFold)

        #expect(
            layout.pose == .tabletop(
                top: CGRect(x: 0, y: 0, width: 669, height: 455),
                bottom: CGRect(x: 0, y: 496, width: 669, height: 455)
            )
        )
    }

    @Test
    func tabletopPlacesTheColumnInTheBottomHalf() {
        let layout = SFKFoldRegionLayout(containerSize: Self.tabletopContainer, divisionFrame: Self.tabletopFold)
        let expected = CGRect(x: 54.5, y: 496, width: 560, height: 455)

        #expect(layout.columnFrame(maxWidth: 560) == expected)
        #expect(layout.placement(maxWidth: 560, contentHeight: 400) == .tabletopPane(expected))
    }

    @Test
    func tabletopKeepsContentTallerThanTheHalfCentred() {
        let layout = SFKFoldRegionLayout(containerSize: Self.tabletopContainer, divisionFrame: Self.tabletopFold)

        #expect(layout.placement(maxWidth: 560, contentHeight: 456) == .centred)
        #expect(layout.placement(maxWidth: 560, contentHeight: nil) == .centred)
    }

    @Test
    func narrowHalvesFallBackToTheCentredColumn() {
        let layout = SFKFoldRegionLayout(
            containerSize: CGSize(width: 540, height: 600),
            divisionFrame: CGRect(x: 250, y: 0, width: 40, height: 600)
        )

        #expect(layout.columnPane == nil)
        #expect(layout.columnFrame(maxWidth: 400) == CGRect(x: 70, y: 0, width: 400, height: 600))
        #expect(layout.placement(maxWidth: 400, contentHeight: nil) == .centred)
    }

    @Test
    func narrowPreferredHalfUsesTheOtherHalf() {
        let layout = SFKFoldRegionLayout(
            containerSize: CGSize(width: 800, height: 600),
            divisionFrame: CGRect(x: 600, y: 0, width: 40, height: 600)
        )

        #expect(layout.columnPane == CGRect(x: 0, y: 0, width: 600, height: 600))
        #expect(layout.columnFrame(maxWidth: 400) == CGRect(x: 100, y: 0, width: 400, height: 600))
    }

    @Test
    func shortTabletopHalvesFallBackToTheCentredColumn() {
        let layout = SFKFoldRegionLayout(
            containerSize: CGSize(width: 669, height: 560),
            divisionFrame: CGRect(x: 0, y: 260, width: 669, height: 40)
        )

        #expect(layout.columnPane == nil)
        #expect(layout.placement(maxWidth: 560, contentHeight: 100) == .centred)
    }

    @Test(arguments: [
        // Left-to-right frame, and the same fold mirrored for right-to-left.
        CGRect(x: 400, y: 0, width: 40, height: 669),
        CGRect(x: 460, y: 0, width: 40, height: 669)
    ])
    func mirroredRegionsStillLandInTheTrailingHalf(fold: CGRect) {
        // SwiftUI mirrors region frames for RTL, so the math only sees frames:
        // the column always sits past the fold on the trailing (larger x) side.
        let layout = SFKFoldRegionLayout(containerSize: CGSize(width: 900, height: 669), divisionFrame: fold)
        let column = layout.columnFrame(maxWidth: 320)

        #expect(column.minX >= fold.maxX)
        #expect(column.maxX <= 900)
        #expect(column.width == 320)
    }
}
