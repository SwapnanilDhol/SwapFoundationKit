import Testing
@testable import SwapFoundationKit
import Foundation

@Test func testExchangeRateManager() async throws {
    let manager = await ExchangeRateManager.shared
    #expect(manager.exchangeRates.count > 0)
    #expect(manager.exchangeRates[.USD] == 1.08)
    #expect(manager.exchangeRates[.EUR] == 1.0)
    #expect(manager.exchangeRates[.GBP] == 0.85)
    #expect(manager.exchangeRates[.JPY] == 163.0)
    #expect(manager.exchangeRates[.INR] == 90.0)
}