import Testing
@testable import SwapFoundationKit
import Foundation

struct ExchangeRateManagerTests {

    @Test func testFallbackConversion() async throws {
        let manager = await ExchangeRateManager.shared
        // Test fallback conversion: 1 EUR to USD
        let result = await manager.convert(value: 1.0, fromCurrency: .EUR, toCurrency: .USD)
        #expect(result > 1.0 && result < 1.2) // Should be close to 1.08
    }

    @Test func testConversionInverse() async throws {
        let manager = await ExchangeRateManager.shared
        // Test that converting from EUR to USD and back yields original value (within tolerance)
        let eurToUsd = await manager.convert(value: 100.0, fromCurrency: .EUR, toCurrency: .USD)
        let usdToEur = await manager.convert(value: eurToUsd, fromCurrency: .USD, toCurrency: .EUR)
        #expect(abs(usdToEur - 100.0) < 0.01)
    }

    @Test func testConvertToBaseCurrency() async throws {
        let manager = await ExchangeRateManager.shared
        let amount = 100.0
        let base = await manager.convertToBaseCurrency(amount: amount, from: .USD)
        #expect(base > 90 && base < 100) // Should be close to 92.5
    }

    private struct RatePair: Codable { let code: String; let rate: Double }

    @Test func testCachePersistence() async throws {
        let manager = await ExchangeRateManager.shared
        // Save a custom rate to the cache
        var customRates = Currency.fallBackExchangeRates.rates
        customRates[.USD] = 2.0 // Deliberately set a wrong rate
        // Save to cache file
        let pairs = customRates.map { RatePair(code: $0.key.rawValue, rate: $0.value) }
        let data = try JSONEncoder().encode(pairs)
        let cacheURL = try XCTUnwrap(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("exchangeRatesCache.json"))
        try data.write(to: cacheURL, options: .atomic)
        // Start manager, should load from cache
        await manager.start()
        let loaded = await manager.convert(value: 1.0, fromCurrency: .EUR, toCurrency: .USD)
        #expect(abs(loaded - 2.0) < 0.0001)
        // Clean up
        try? FileManager.default.removeItem(at: cacheURL)
    }

    @Test func testCacheFallbackOnCorruptFile() async throws {
        let manager = await ExchangeRateManager.shared
        // Write corrupt data
        let cacheURL = try XCTUnwrap(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("exchangeRatesCache.json"))
        try Data([0x00, 0x01, 0x02]).write(to: cacheURL, options: .atomic)
        // Start manager, should fallback to static rates
        await manager.start()
        let loaded = await manager.convert(value: 1.0, fromCurrency: .EUR, toCurrency: .USD)
        #expect(loaded > 1.0 && loaded < 1.2) // Should fallback to static
        // Clean up
        try? FileManager.default.removeItem(at: cacheURL)
    }
}