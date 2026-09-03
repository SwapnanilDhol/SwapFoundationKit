/****************************************************************************
 * SFKButtonColorResolverTests.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI
import UIKit
import XCTest
@testable import SwapFoundationKit

final class SFKButtonColorResolverTests: XCTestCase {
    func testBlackBackgroundResolvesToWhiteLabel() {
        let label = resolve(background: .black, colorScheme: .light)

        XCTAssertTrue(label.isWhite)
    }

    func testWhiteBackgroundResolvesToDarkLabel() {
        let label = resolve(background: .white, colorScheme: .light)

        XCTAssertEqual(label.hexString(), UIColor.preferredDarkForeground.hexString())
    }

    func testPrimaryInvertsAcrossAppearances() {
        let lightLabel = resolve(background: .primary, colorScheme: .light)
        let darkLabel = resolve(background: .primary, colorScheme: .dark)

        XCTAssertTrue(lightLabel.isWhite)
        XCTAssertEqual(darkLabel.hexString(), UIColor.preferredDarkForeground.hexString())
    }

    func testExplicitLabelColorWinsOverBackgroundContrast() {
        let label = SFKButtonLabelColorResolver.resolve(
            background: .black,
            explicitLabelColor: .yellow,
            colorScheme: .light
        )

        XCTAssertEqual(label.hexString(), UIColor.yellow.hexString())
    }

    func testBorderlessExplicitLabelColorWinsWithoutBackground() {
        let label = SFKButtonLabelColorResolver.resolve(.red, colorScheme: .dark)

        XCTAssertEqual(label.hexString(), UIColor.red.hexString())
    }

    func testRenderingRoleMatrix() {
        XCTAssertEqual(SFKButtonRendering.role(for: .primary, supportsGlass: true), .glassProminent)
        XCTAssertEqual(SFKButtonRendering.role(for: .destructive, supportsGlass: true), .glassProminent)
        XCTAssertEqual(SFKButtonRendering.role(for: .secondary, supportsGlass: true), .glass)
        XCTAssertEqual(SFKButtonRendering.role(for: .primary, supportsGlass: false), .borderedProminent)
        XCTAssertEqual(SFKButtonRendering.role(for: .destructive, supportsGlass: false), .borderedProminent)
        XCTAssertEqual(SFKButtonRendering.role(for: .secondary, supportsGlass: false), .bordered)
        XCTAssertEqual(SFKButtonRendering.role(for: .borderless, supportsGlass: true), .plain)
    }

    private func resolve(background: Color, colorScheme: ColorScheme) -> UIColor {
        SFKButtonLabelColorResolver.resolve(
            background: background,
            explicitLabelColor: nil,
            colorScheme: colorScheme
        )
    }
}
