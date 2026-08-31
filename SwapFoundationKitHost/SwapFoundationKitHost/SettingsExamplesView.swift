import SwiftUI
import SwapFoundationKit

struct SettingsExamplesView: View {
    @State private var notificationsEnabled = true
    @State private var onboardingEnabled = false
    @State private var lastSyncDate = Date.now

    var body: some View {
        SFKSettingsScreen {
            SFKSettingsSection("Quick Controls") {
                SFKSettingsToggle(
                    "Push Notifications",
                    subtitle: "Enable alerts for app updates.",
                    systemImage: "bell.badge.fill",
                    isOn: $notificationsEnabled
                )
            }

            SFKSettingsSection("App Settings") {
                SFKSettingsRow("Last Sync",
                               subtitle: "Run a sync and inspect the latest completion time.",
                               systemImage: "arrow.triangle.2.circlepath",
                               tint: .blue) {
                    lastSyncDate = .now
                }.settingsRowChevron(false)
                SFKSettingsToggle(
                    "Show Onboarding",
                    subtitle: "Replay the first-run walkthrough.",
                    systemImage: "play.circle.fill",
                    tint: .blue,
                    isOn: $onboardingEnabled
                )
            }

            SFKSettingsSection("App Information") {
                SFKSettingsRow("Version", subtitle: "Current installed version.", systemImage: "info.circle.fill",
                               tint: .secondary) { }
                    .settingsRowChevron(false)
                    .settingsRowValue("2.2.0 (1)")
                SFKSettingsRow("Report a Bug", subtitle: "Email feedback directly to the developer.", systemImage: "ant.circle.fill", tint: .orange) { }
                SFKSettingsRow("Privacy Policy", subtitle: "Read how the app handles your data.", systemImage: "globe", tint: .blue) { }
                SFKSettingsRow("Release Notes", subtitle: "See what changed in the latest update.", systemImage: "sparkles", tint: .orange) { }
            }

            SFKSettingsSection("Developer") {
                SFKSettingsRow("Website", subtitle: "Visit the developer website.", systemImage: "globe", tint: .blue) { }
                SFKSettingsRow("Another App", subtitle: "See another app from the same developer.", systemImage: "heart.circle.fill", tint: .pink) {
                    lastSyncDate = .now
                }
            }
        }
        .sfkTheme(SFKTheme(colors: .init(accent: .mint)))
    }

}
