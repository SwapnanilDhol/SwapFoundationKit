import SwiftUI
import SwapFoundationKit

private enum AppSettingsItem: String, CaseIterable, SettingsItem {
    case notifications
    case lastSync
    case onboarding

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .notifications: return "bell.badge.fill"
        case .lastSync: return "arrow.triangle.2.circlepath"
        case .onboarding: return "play.circle.fill"
        }
    }

    var title: String {
        switch self {
        case .notifications: return "Notifications"
        case .lastSync: return "Last Sync"
        case .onboarding: return "Show Onboarding"
        }
    }

    var subtitle: String {
        switch self {
        case .notifications: return "Enable update and release alerts."
        case .lastSync: return "Run a sync and inspect the latest completion time."
        case .onboarding: return "Replay the first-run walkthrough."
        }
    }

    var tint: Color { .blue }
}

private enum AppExtrasItem: String, CaseIterable, SettingsItem {
    case changelog

    var id: String { rawValue }
    var icon: String { "sparkles" }
    var title: String { "Release Notes" }
    var subtitle: String { "See what changed in the latest update." }
    var tint: Color { .orange }
}

struct SettingsExamplesView: View {
    @State private var notificationsEnabled = true
    @State private var onboardingEnabled = false
    @State private var lastSyncDate = Date.now

    private let theme = SFKSettingsTheme(
        colors: .init(
            accent: .mint,
            itemTintBehavior: .useAccent,
            toggleOnTint: .mint,
            sliderTint: .mint
        )
    )

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
                SFKSettingsRow(AppSettingsItem.lastSync.title,
                               subtitle: AppSettingsItem.lastSync.subtitle,
                               systemImage: AppSettingsItem.lastSync.icon,
                               tint: AppSettingsItem.lastSync.tint,
                               showChevron: false) {
                    lastSyncDate = .now
                }
                SFKSettingsToggleRow(item: AppSettingsItem.onboarding, isOn: $onboardingEnabled)
            }

            SFKSettingsSection("App Information") {
                SFKSettingsRow(item: SFKInformationSectionItem.version,
                               action: {},
                               showChevron: false,
                               trailingView: .value("2.2.0 (1)"))
                ForEach(SFKInformationSectionItem.allCases.filter { $0 != .version }, id: \.id) { item in
                    SFKSettingsRow(item: item) { handleInformation(item) }
                }
                SFKSettingsRow(item: AppExtrasItem.changelog) { }
            }

            SFKSettingsSection("Developer") {
                ForEach(SFKDeveloperSectionItem.allCases, id: \.id) { item in
                    SFKSettingsRow(item: item) { handleDeveloper(item) }
                }
            }
        }
        .sfkSettingsTheme(theme)
    }

    private func handleInformation(_ item: SFKInformationSectionItem) {
        if item == .referToFriends { notificationsEnabled.toggle() }
    }

    private func handleDeveloper(_ item: SFKDeveloperSectionItem) {
        if item == .anotherApp { lastSyncDate = .now }
    }
}
