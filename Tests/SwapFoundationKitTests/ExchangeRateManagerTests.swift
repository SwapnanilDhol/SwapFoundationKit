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
}