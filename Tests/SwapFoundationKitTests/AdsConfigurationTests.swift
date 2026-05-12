/*****************************************************************************
 * AdsConfigurationTests.swift
 * SwapFoundationKitTests — core-only (no GoogleMobileAds product)
 *****************************************************************************/

import XCTest
@testable import SwapFoundationKit

final class AdsConfigurationTests: XCTestCase {
    func testAdUnitConfiguration_ResolvesPlacementIDs() {
        let units = AdUnitConfiguration(banner: "b", interstitial: "i", rewarded: "r")
        XCTAssertEqual(units.adUnitID(for: .banner), "b")
        XCTAssertEqual(units.adUnitID(for: .interstitial), "i")
        XCTAssertEqual(units.adUnitID(for: .rewarded), "r")
    }

    func testGoogleAdsConfiguration_IsEquatable() {
        XCTAssertEqual(GoogleAdsConfiguration(), GoogleAdsConfiguration())
    }

    func testAdsProviderConfiguration_Enum() {
        let cfg = AdsProviderConfiguration.google(GoogleAdsConfiguration())
        if case .google = cfg {
            XCTAssertTrue(true)
        } else {
            XCTFail("expected .google")
        }
    }
}
