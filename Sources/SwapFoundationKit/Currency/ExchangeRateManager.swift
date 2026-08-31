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
    private let transport: ExchangeRateTransport
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
        self.transport = HTTPClientExchangeRateTransport(client: .shared)
    }

    /// Creates a manager that fetches from a custom URL.
    /// - Parameter exchangeRateURL: URL returning ECB-style XML.
    public init(exchangeRateURL: URL) {
        self.exchangeRateURL = exchangeRateURL
        self.transport = HTTPClientExchangeRateTransport(client: .shared)
    }

    /// Test-only initializer that injects a fake transport instead of the real `HTTPClient`.
    /// Not part of the public API.
    /// - Parameters:
    ///   - exchangeRateURL: URL returning ECB-style XML.
    ///   - transport: Fake transport for unit tests.
    init(exchangeRateURL: URL, transport: ExchangeRateTransport) {
        self.exchangeRateURL = exchangeRateURL
        self.transport = transport
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
        let data: Data
        do {
            let (fetchedData, httpResponse) = try await transport.data(from: exchangeRateURL)
            guard (200...299).contains(httpResponse.statusCode) else {
                throw URLError(.badServerResponse)
            }
            data = fetchedData
        } catch {
            throw Self.mapTransportError(error)
        }

        let parser = XMLParser(data: data)
        parser.delegate = self
        guard parser.parse() else {
            throw URLError(.cannotParseResponse)
        }
    }

    /// Test-only: exposes `fetchAndParse()`'s thrown error type directly, so unit tests can assert
    /// on the `URLError`s it throws without waiting through `performFetchWithRetry`'s backoff.
    /// Not part of the public API.
    func fetchAndParseForTesting() async throws {
        try await fetchAndParse()
    }

    /// Routing through `HTTPClient` means transport failures surface as `NetworkError`, not the
    /// `URLError`s `performFetchWithRetry`'s callers previously observed directly from
    /// `URLSession`. Map back so `fetchAndParse` keeps throwing the same `URLError` family
    /// (`.badServerResponse` for a non-2xx/non-HTTP response, `.cannotParseResponse` for
    /// unparseable XML, and the closest equivalent for other transport failures).
    private static func mapTransportError(_ error: Error) -> Error {
        if let urlError = error as? URLError {
            return urlError
        }

        guard let networkError = error as? NetworkError else {
            return error
        }

        switch networkError {
        case .httpError, .invalidResponse, .invalidURL, .decodingError:
            return URLError(.badServerResponse)
        case .timeout:
            return URLError(.timedOut)
        case .noInternetConnection:
            return URLError(.notConnectedToInternet)
        case .cancelled:
            return URLError(.cancelled)
        case .requestFailed(let underlying):
            return (underlying as? URLError) ?? URLError(.unknown)
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

// MARK: - Exchange Rate Transport

/// Abstraction over the transport used to fetch the ECB exchange rate XML feed, so `fetchAndParse`
/// can be unit-tested with a fake and production code routes through the package's canonical
/// `HTTPClient` instead of `URLSession.shared` (feature code must not call `URLSession.shared`
/// directly; see `SFKNetworkInstrumentation`, which lets opt-in products like
/// `SwapFoundationKitPulse` observe `HTTPClient` traffic).
protocol ExchangeRateTransport: Sendable {
    func data(from url: URL) async throws -> (Data, HTTPURLResponse)
}

/// Default `ExchangeRateTransport` backed by the package's canonical `HTTPClient`.
struct HTTPClientExchangeRateTransport: ExchangeRateTransport {
    let client: HTTPClient

    func data(from url: URL) async throws -> (Data, HTTPURLResponse) {
        let response = try await client.execute(ExchangeRateFetchRequest(url: url))
        return (response.data, response.response)
    }
}

/// Builds a GET `NetworkRequest` from the configured exchange rate URL.
private struct ExchangeRateFetchRequest: NetworkRequest {
    let scheme: String
    let baseURL: String
    let path: String
    let method: HTTPMethod = .get
    let parameters: [String: String]?
    let headers: [String: String]? = nil
    let body: Data? = nil

    init(url: URL) {
        self.scheme = url.scheme ?? "https"
        let host = url.host ?? ""
        if let port = url.port {
            self.baseURL = "\(host):\(port)"
        } else {
            self.baseURL = host
        }
        self.path = url.path.isEmpty ? "/" : url.path
        self.parameters = url.queryParameters
    }
}
