/****************************************************************************
 * SFKAppPromotionTests.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import XCTest
@testable import SwapFoundationKit

final class SFKAppPromotionTests: XCTestCase {
    private func promotion(providerToken: String? = nil) -> SFKAppPromotion {
        SFKAppPromotion(
            appStoreID: "6479275107",
            name: "Windfall",
            pitch: "Track every expense.",
            actionTitle: "Get",
            providerToken: providerToken
        )
    }

    func testAppStoreURLWithoutTokens() {
        XCTAssertEqual(promotion().appStoreURL().absoluteString, "https://apps.apple.com/app/id6479275107")
    }

    func testAppStoreURLCarriesCampaignAndProviderTokens() {
        let url = promotion(providerToken: "118").appStoreURL(campaignToken: "goaley_home")
        let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
        XCTAssertEqual(items.first { $0.name == "ct" }?.value, "goaley_home")
        XCTAssertEqual(items.first { $0.name == "pt" }?.value, "118")
    }

    @MainActor
    func testWithoutURLSchemeIsNeverInstalled() {
        XCTAssertFalse(promotion().isInstalled)
    }
}
