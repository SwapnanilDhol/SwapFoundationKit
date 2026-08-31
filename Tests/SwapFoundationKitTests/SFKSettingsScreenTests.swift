import SwiftUI
import Testing
@testable import SwapFoundationKit

struct SFKSettingsScreenTests {
    @Test
    @MainActor
    func typedToggleBindingWritesCurrentValue() {
        var value = false
        let binding = Binding(get: { value }, set: { value = $0 })
        _ = SFKSettingsToggle("Notifications", isOn: binding)
        binding.wrappedValue = true
        #expect(value)
    }
}
