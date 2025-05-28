/*****************************************************************************
 * ExchangeRateManager.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/
 
import Foundation

/// An actor-based manager for currency exchange rates.
public actor ExchangeRateManager: NSObject, XMLParserDelegate {
    public static let shared = ExchangeRateManager()

    private let exchangeRateURL = URL(string: "https://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml")!

    private(set) var exchangeRates = Currency.fallBackExchangeRates.rates

    private override init() { }

    /// Fetches and updates exchange rates from the ECB.
    public func cacheExchangeRates() async {
        do {
            let (data, _) = try await URLSession.shared.data(from: exchangeRateURL)
            let parser = XMLParser(data: data)
            parser.delegate = self
            parser.parse()
        } catch {
            print("Failed to fetch exchange rates: \(error)")
        }
    }

    /// Converts a value from one currency to another.
    public func convert(
        value: Double,
        fromCurrency: Currency,
        toCurrency: Currency
    ) -> Double {
        guard let valueRate = exchangeRates[fromCurrency],
              let outputRate = exchangeRates[toCurrency] else { return value }
        let multiplier = outputRate / valueRate
        return value * multiplier
    }

    public func convertToBaseCurrency(amount: Double, from currency: Currency) -> Double {
        return convert(value: amount, fromCurrency: currency, toCurrency: .EUR)
    }

    // MARK: - XMLParserDelegate

    public nonisolated func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes attributeDict: [String : String] = [:]
    ) {
        if elementName == "Cube", let currency = attributeDict["currency"], let rate = attributeDict["rate"] {
            Task { [currency, rate] in
                await self.mergeExchangeRate(for: currency, with: rate)
            }
        }
    }

    private func mergeExchangeRate(for currency: String, with rate: String) async {
        guard let availableCurrency = Currency(rawValue: currency),
              let doubleRate = Double(rate) else {
            return
        }
        exchangeRates[availableCurrency] = doubleRate
    }
}
