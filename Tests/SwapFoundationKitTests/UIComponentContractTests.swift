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
    @MainActor
    func typedSettingsPickerWritesSelection() {
        var priority = 1
        let binding = Binding(get: { priority }, set: { priority = $0 })
        _ = SFKSettingsPicker("Priority", selection: binding, options: [1, 2, 3])
        binding.wrappedValue = 2
        XCTAssertEqual(priority, 2)
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
