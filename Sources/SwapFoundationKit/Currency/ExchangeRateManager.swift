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

/// Codable struct for cache serialization
private struct RatePair: Codable {
    let code: String
    let rate: Double
}

/// An actor-based manager for currency exchange rates.
public actor ExchangeRateManager: NSObject, XMLParserDelegate {
    public static let shared = ExchangeRateManager()

    private let exchangeRateURL = URL(string: "https://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml")!
    private let cacheFileName = "exchangeRatesCache.json"
    private var cacheFileURL: URL {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return dir.appendingPathComponent(cacheFileName)
    }

    private(set) var exchangeRates = Currency.fallBackExchangeRates.rates

    private override init() { }

    /// Call this on app launch to load cached rates if available.
    public func start() async {
        if let cached = await loadRatesFromCache() {
            exchangeRates = cached
        } else {
            exchangeRates = Currency.fallBackExchangeRates.rates
        }
    }

    /// Fetches and updates exchange rates from the ECB, then caches them.
    public func cacheExchangeRates() async {
        do {
            let (data, _) = try await URLSession.shared.data(from: exchangeRateURL)
            let parser = XMLParser(data: data)
            parser.delegate = self
            parser.parse()
            await saveRatesToCache()
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

    // MARK: - Caching Helpers

    private func saveRatesToCache() async {
        do {
            let pairs = exchangeRates.map { RatePair(code: $0.key.rawValue, rate: $0.value) }
            let data = try JSONEncoder().encode(pairs)
            try data.write(to: cacheFileURL, options: .atomic)
        } catch {
            print("Failed to save exchange rates cache: \(error)")
        }
    }

    private func loadRatesFromCache() async -> [Currency: Double]? {
        do {
            let data = try Data(contentsOf: cacheFileURL)
            let pairs = try JSONDecoder().decode([RatePair].self, from: data)
            var dict: [Currency: Double] = [:]
            for pair in pairs {
                if let currency = Currency(rawValue: pair.code) {
                    dict[currency] = pair.rate
                }
            }
            return dict.isEmpty ? nil : dict
        } catch {
            return nil
        }
    }
}
