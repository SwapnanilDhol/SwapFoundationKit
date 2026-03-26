/*****************************************************************************
 * DataCryptoTests.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import XCTest
@testable import SwapFoundationKit

final class DataCryptoTests: XCTestCase {
    func testHashesRemainStable() {
        let data = Data("hello".utf8)

        XCTAssertEqual(data.md5, "5d41402abc4b2a76b9719d911017c592")
        XCTAssertEqual(data.sha1, "aaf4c61ddcc5e8a2dabede0f3b482cd9aea9434d")
        XCTAssertEqual(data.sha256, "2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824")
    }
}
