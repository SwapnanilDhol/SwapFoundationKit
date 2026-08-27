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

    @Test
    func serbianDinarIsSupported() {
        #expect(Currency.allCases.contains(.RSD))
        #expect(Currency.RSD.description.key == "Serbian dinar")
        #expect(Currency.RSD.symbol == "🇷🇸")
        #expect(Currency.RSD.currencySymbol == "дин.")
    }

    @Test
    func serbianDinarUsesManualFallbackRate() async {
        let manager = ExchangeRateManager(exchangeRateURL: URL(string: "https://invalid.example")!)
        let rsdRate = await manager.exchangeRates[.RSD]
        let convertedValue = await manager.convert(value: 1, fromCurrency: .EUR, toCurrency: .RSD)

        #expect(rsdRate == 117.3717)
        #expect(convertedValue == 117.3717)
    }

    @Test
    func saudiRiyalIsSupported() {
        #expect(Currency.allCases.contains(.SAR))
        #expect(Currency.SAR.description.key == "Saudi Riyal")
        #expect(Currency.SAR.symbol == "🇸🇦")
        #expect(Currency.SAR.currencySymbol == "﷼")
    }

    @Test
    func saudiRiyalUsesManualFallbackRate() async {
        let manager = ExchangeRateManager(exchangeRateURL: URL(string: "https://invalid.example")!)
        let sarRate = await manager.exchangeRates[.SAR]
        let convertedValue = await manager.convert(value: 1, fromCurrency: .EUR, toCurrency: .SAR)

        #expect(sarRate == 4.05)
        #expect(convertedValue == 4.05)
    }

    @Test
    func additionalCurrenciesExposeExpectedMetadata() {
        let expected: [(Currency, String, String, String)] = [
            (.TWD, "New Taiwan dollar", "🇹🇼", "NT$"),
            (.VND, "Vietnamese dong", "🇻🇳", "₫"),
            (.PKR, "Pakistani rupee", "🇵🇰", "₨"),
            (.BDT, "Bangladeshi taka", "🇧🇩", "৳"),
            (.COP, "Colombian peso", "🇨🇴", "COL$"),
            (.CLP, "Chilean peso", "🇨🇱", "CLP$"),
            (.PEN, "Peruvian sol", "🇵🇪", "S/"),
            (.EGP, "Egyptian pound", "🇪🇬", "E£"),
            (.QAR, "Qatari riyal", "🇶🇦", "ر.ق"),
            (.KWD, "Kuwaiti dinar", "🇰🇼", "د.ك"),
            (.OMR, "Omani rial", "🇴🇲", "ر.ع."),
            (.BHD, "Bahraini dinar", "🇧🇭", ".د.ب"),
            (.JOD, "Jordanian dinar", "🇯🇴", "د.ا"),
            (.MAD, "Moroccan dirham", "🇲🇦", "د.م."),
            (.KES, "Kenyan shilling", "🇰🇪", "KSh"),
            (.GHS, "Ghanaian cedi", "🇬🇭", "GH₵"),
            (.UAH, "Ukrainian hryvnia", "🇺🇦", "₴")
        ]

        for (currency, description, symbol, currencySymbol) in expected {
            #expect(Currency.allCases.contains(currency))
            #expect(currency.description.key == description)
            #expect(currency.symbol == symbol)
            #expect(currency.currencySymbol == currencySymbol)
        }
    }

    @Test
    func additionalCurrenciesConvertFromEURUsingManualFallbackRates() async {
        let manager = ExchangeRateManager(exchangeRateURL: URL(string: "https://invalid.example")!)
        let expectedRates: [(Currency, Double)] = [
            (.TWD, 34.8), (.VND, 30000.0), (.PKR, 320.0), (.BDT, 140.0),
            (.COP, 4700.0), (.CLP, 1050.0), (.PEN, 3.75), (.EGP, 57.0),
            (.QAR, 3.93), (.KWD, 0.33), (.OMR, 0.42), (.BHD, 0.42),
            (.JOD, 0.77), (.MAD, 10.7), (.KES, 150.0), (.GHS, 12.5),
            (.UAH, 48.0)
        ]

        for (currency, expectedRate) in expectedRates {
            guard let rate = await manager.exchangeRates[currency] else {
                Issue.record("Missing fallback rate for \(currency.rawValue)")
                continue
            }
            let convertedValue = await manager.convert(value: 1, fromCurrency: .EUR, toCurrency: currency)

            #expect(rate == expectedRate)
            #expect(convertedValue == expectedRate)
            #expect(rate.isFinite)
            #expect(rate > 0)
        }
    }
}
