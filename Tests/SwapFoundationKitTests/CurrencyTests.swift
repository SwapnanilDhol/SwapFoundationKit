/****************************************************************************
 * CurrencyTests.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import Foundation
import Testing

@testable import SwapFoundationKit

struct CurrencyTests {

    @Test
    func nigerianNairaIsSupported() {
        #expect(Currency.allCases.contains(.NGN))
        #expect(Currency.NGN.description.key == "Nigerian naira")
        #expect(Currency.NGN.symbol == "🇳🇬")
        #expect(Currency.NGN.currencySymbol == "₦")
    }

    @Test
    func nigerianNairaUsesManualFallbackRate() async {
        let manager = ExchangeRateManager(exchangeRateURL: URL(string: "https://invalid.example")!)
        let ngnRate = await manager.exchangeRates[.NGN]
        let convertedValue = await manager.convert(value: 1, fromCurrency: .EUR, toCurrency: .NGN)

        #expect(ngnRate == 1570.66)
        #expect(convertedValue == 1570.66)
    }
}
