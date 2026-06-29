import Testing
@testable import SwapFoundationKit

struct StringHexColorTests {
    @Test
    func withHexRemovedStripsHashPrefix() {
        #expect("#FF00AA".withHexRemoved == "FF00AA")
        #expect("FF00AA".withHexRemoved == "FF00AA")
    }

    @Test
    func isValidHexColorAcceptsSixDigitValues() {
        #expect("#FF00AA".isValidHexColor())
        #expect("FF00AA".isValidHexColor())
    }

    @Test
    func isValidHexColorRejectsInvalidValues() {
        #expect("FF00".isValidHexColor() == false)
        #expect("not-a-color".isValidHexColor() == false)
    }
}
