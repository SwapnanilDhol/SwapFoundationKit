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

    /// `nil` keeps the pre-existing behaviour of falling back to the field's tint, so adding
    /// the override does not change any appearance that does not set it.
    func testStandardAppearanceLeavesFocusBorderToTheTint() {
        XCTAssertNil(SFKTextFieldAppearance.standard.focusedBorderColor)
    }

    /// A field embedded in a `Form` row needs to suppress the focus ring: the row already
    /// carries the surface, so a ring inside it reads as a stray rectangle.
    func testFocusBorderCanBeSuppressed() {
        let appearance = SFKTextFieldAppearance(
            backgroundColor: .clear,
            borderColor: .clear,
            focusedBorderColor: .clear
        )

        XCTAssertEqual(appearance.focusedBorderColor, .clear)
    }

    @MainActor
    func testChromelessAppearanceCanBeHosted() {
        let field = SFKTextField(
            text: .constant(""),
            placeholder: "Name",
            leadingSystemImage: "figure.walk",
            appearance: SFKTextFieldAppearance(
                backgroundColor: .clear,
                focusedBackgroundColor: .clear,
                disabledBackgroundColor: .clear,
                borderColor: .clear,
                focusedBorderColor: .clear,
                horizontalPadding: 0
            )
        )
        let host = UIHostingController(rootView: field)

        host.loadViewIfNeeded()

        XCTAssertNotNil(host.view)
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
