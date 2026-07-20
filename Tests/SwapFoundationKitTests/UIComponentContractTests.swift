/****************************************************************************
 * UIComponentContractTests.swift
 * SwapFoundationKitTests
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

final class UIComponentContractTests: XCTestCase {
    private enum Priority: Hashable {
        case low
        case high
    }

    private enum FirstSettingsItem: String, SettingsItem {
        case account

        var id: String { rawValue }
        var icon: String { "person.crop.circle" }
        var title: String { "Account" }
        var subtitle: String { "Manage account" }
        var tint: Color { .blue }
    }

    private enum SecondSettingsItem: String, SettingsItem {
        case privacy

        var id: String { rawValue }
        var icon: String { "hand.raised" }
        var title: String { "Privacy" }
        var subtitle: String { "Manage privacy" }
        var tint: Color { .green }
    }

    func testSettingsPickerOptionPreservesNonStringValue() {
        let option = SFKSettingsPickerOption(value: Priority.high, label: "High")

        XCTAssertEqual(option.value, .high)
        XCTAssertEqual(option.id, .high)
    }

    func testSettingsSectionUsesItemIdentityInsteadOfArrayPosition() {
        let section = SFKSettingsSectionConfiguration(
            title: "General",
            items: [FirstSettingsItem.account, SecondSettingsItem.privacy]
        )

        XCTAssertEqual(section.rows.map(\.id), ["account", "privacy"])
    }

    func testAlertActionStylesMapToUIKitRoles() {
        XCTAssertEqual(AlertActionStyle.default.uiStyle, .default)
        XCTAssertEqual(AlertActionStyle.cancel.uiStyle, .cancel)
        XCTAssertEqual(AlertActionStyle.destructive.uiStyle, .destructive)
    }

    @MainActor
    func testTextInputReadsCurrentTextFieldValue() {
        let controller = AlertPresenter.makeTextInputAlert(
            title: "Name",
            message: "Enter a name",
            placeholder: "Name",
            prefilledText: "Before",
            keyboardType: .default,
            submitTitle: "Save",
            cancelTitle: "Cancel",
            onSubmit: { _ in },
            onCancel: nil
        )
        controller.textFields?.first?.text = "After"

        XCTAssertEqual(AlertPresenter.textInputValue(from: controller), "After")
        XCTAssertEqual(controller.actions.map(\.style), [.cancel, .default])
    }
}
