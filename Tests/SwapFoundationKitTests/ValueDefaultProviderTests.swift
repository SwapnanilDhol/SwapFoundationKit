import Testing
@testable import SwapFoundationKit

struct MockDefaultInt: ValueDefaultProvider {
    private static var _default: Int = 42
    static func defaultValue() -> Int { _default }
    static func setDefaultValue(_ value: Int) { _default = value }
}

struct ValueDefaultProviderTests {
    @Test static func testDefaultValue() async throws {
        #expect(MockDefaultInt.defaultValue() == 42)
        #expect(MockDefaultInt.default == 42)
    }

    @Test static func testSetDefaultValue() async throws {
        MockDefaultInt.setDefaultValue(100)
        #expect(MockDefaultInt.defaultValue() == 100)
        #expect(MockDefaultInt.default == 100)
        // Reset for other tests
        MockDefaultInt.setDefaultValue(42)
    }
} 