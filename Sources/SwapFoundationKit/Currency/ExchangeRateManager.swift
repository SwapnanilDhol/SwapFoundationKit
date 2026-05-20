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

/// An actor-based manager for currency exchange rates fetched from the European Central Bank.
public actor ExchangeRateManager: NSObject, XMLParserDelegate {
    public static let shared = ExchangeRateManager()

    public static let defaultExchangeRateURL = URL(
        string: "https://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml"
    )!

    /// Maximum number of retry attempts when fetching rates fails.
    private static let maxRetries = 3
    /// Base delay for exponential backoff between retries.
    private static let retryBaseDelay: TimeInterval = 1.0

    private let exchangeRateURL: URL
    private let cacheFileName = "exchangeRatesCache.json"

    /// Duration for which cached rates are considered valid before re-fetching.
    /// Defaults to 5 minutes. Set to 0 or less to always re-fetch.
    public var cacheValidityInterval: TimeInterval = 300

    private var cacheFileURL: URL {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return dir.appendingPathComponent(cacheFileName)
    }

    private var lastFetchTime: Date?
    private(set) var exchangeRates = Currency.fallBackExchangeRates.rates

    private override init() {
        self.exchangeRateURL = Self.defaultExchangeRateURL
    }

    /// Creates a manager that fetches from a custom URL.
    /// - Parameter exchangeRateURL: URL returning ECB-style XML.
    public init(exchangeRateURL: URL) {
        self.exchangeRateURL = exchangeRateURL
    }

    /// Loads cached rates if available and fresh, then fetches if stale.
    public func start() async {
        if let cached = await loadRatesFromCache() {
            Logger.info("Loaded exchange rates from cache")
            exchangeRates = cached
        } else {
            Logger.info("No cached exchange rates found, using fallback rates")
            exchangeRates = Currency.fallBackExchangeRates.rates
        }
        await fetchAndCacheExchangeRates()
    }

    /// Fetches and updates exchange rates from the ECB, then caches them.
    /// Respects `cacheValidityInterval` — skips fetch if cache is still fresh.
    public func fetchAndCacheExchangeRates() async {
        if let lastFetch = lastFetchTime, cacheValidityInterval > 0 {
            let elapsed = Date().timeIntervalSince(lastFetch)
            if elapsed < cacheValidityInterval {
                Logger.debug("Exchange rates cache still valid (fetched \(String(format: "%.0f", elapsed))s ago)")
                return
            }
        }

        await performFetchWithRetry()
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

    // MARK: - Fetch with Retry

    private func performFetchWithRetry() async {
        for attempt in 1...Self.maxRetries {
            do {
                try await fetchAndParse()
                lastFetchTime = Date()
                await saveRatesToCache()
                Logger.info("Exchange rates fetched and cached successfully")
                return
            } catch {
                Logger.warning("Exchange rate fetch attempt \(attempt)/\(Self.maxRetries) failed: \(error)")
                if attempt < Self.maxRetries {
                    let delay = Self.retryBaseDelay * pow(2.0, Double(attempt - 1))
                    try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                }
            }
        }
        Logger.error("All exchange rate fetch attempts failed")
    }

    private func fetchAndParse() async throws {
        let (data, response) = try await URLSession.shared.data(from: exchangeRateURL)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        let parser = XMLParser(data: data)
        parser.delegate = self
        guard parser.parse() else {
            throw URLError(.cannotParseResponse)
        }
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
            Task { [weak self, currency, rate] in
                guard let self = self else { return }
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
            Logger.error("Failed to save exchange rates cache: \(error)")
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
