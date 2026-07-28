import SwiftUI
import Testing
@testable import SwapFoundationKit

struct SFKSettingsScreenTests {
    @Test
    func customSection_preservesCallerProvidedIdentity() {
        let section = SFKSettingsCustomSection(id: "preferences") {
            EmptyView()
        }

        #expect(section.id == "preferences")
    }

    @Test
    func standardSection_preservesCallerProvidedIdentity() {
        let section = SFKSettingsSectionConfiguration(
            id: "information",
            title: "Information",
            items: []
        )

        #expect(section.id == "information")
    }
}
