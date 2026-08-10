/****************************************************************************
 * SFKTextFieldTests.swift
 * SwapFoundationKitTests
 *****************************************************************************/

import SwiftUI
import UIKit
import XCTest
@testable import SwapFoundationKit

final class SFKTextFieldTests: XCTestCase {
    func testStatusExposesOnlyRelevantMessage() {
        XCTAssertNil(SFKTextFieldStatus.normal.message)
        XCTAssertEqual(SFKTextFieldStatus.error("Invalid").message, "Invalid")
        XCTAssertEqual(SFKTextFieldStatus.success("Available").message, "Available")
        XCTAssertNil(SFKTextFieldStatus.success(nil).message)
    }

    func testStandardAppearanceUsesAccessibleControlHeight() {
        XCTAssertGreaterThanOrEqual(SFKTextFieldAppearance.standard.minimumHeight, 44)
    }

    @MainActor
    func testCommonEmailConfigurationCanBeHosted() {
        let field = SFKTextField(
            "Email",
            text: .constant("person@example.com"),
            placeholder: "you@example.com",
            leadingSystemImage: "envelope",
            status: .normal,
            keyboardType: .emailAddress,
            contentType: .emailAddress,
            textInputAutocapitalization: .never,
            autocorrectionDisabled: true
        )
        let host = UIHostingController(rootView: field)

        host.loadViewIfNeeded()

        XCTAssertNotNil(host.view)
    }
}
