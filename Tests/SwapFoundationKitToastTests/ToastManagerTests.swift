/*****************************************************************************
 * ToastManagerTests.swift
 * SwapFoundationKitToastTests
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import XCTest
@testable import SwapFoundationKitToast

final class ToastManagerTests: XCTestCase {
    func testDefaultConfigurationValues() {
        let configuration = SFKToastConfiguration()

        XCTAssertTrue(configuration.autoHide)
        XCTAssertEqual(configuration.displayTime, 2.5)
        XCTAssertEqual(configuration.animationTime, 0.2)
    }

    @MainActor
    func testSharedInstanceIsStable() {
        XCTAssertTrue(ToastManager.shared === ToastManager.shared)
    }
}
