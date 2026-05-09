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
    @State private var lastSyncDate = Date.now
    @State private var updateBannerVersion: String?

    private let sections: [SFKSettingsSectionConfiguration] = [
        SFKSettingsSectionConfiguration(
            title: "App Settings",
            items: AppSettingsItem.allCases
        ),
        SFKSettingsSectionConfiguration(
            title: "App Information",
            items: SFKInformationSectionItem.allCases + AppExtrasItem.allCases
        ),
        SFKSettingsSectionConfiguration(
            title: "Developer",
            items: SFKDeveloperSectionItem.allCases
        )
    ]

    var body: some View {
        SFKSettingsScreen(
            header: header,
            customSections: [
                SFKSettingsCustomSection(title: "Quick Controls") {
                    SFKSettingsToggle(
                        title: "Push Notifications",
                        subtitle: "Enable alerts for app updates.",
                        icon: "bell.badge.fill",
                        tint: .blue,
                        isOn: $notificationsEnabled
                    )
                }
            ],
            sections: sections,
            updateBannerVersion: $updateBannerVersion,
            updateBannerAppStoreID: "123456789",
            onUpdateBannerTap: {
                // Example hook for analytics side-effects.
                print("Update banner tapped")
            },
            rowTrailingBuilder: trailingView(for:),
            rowChevronBuilder: showChevron(for:),
            onItemTap: handleTap(_:)
        )
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("SwapFoundationKit Pro")
                .font(.title2.bold())
            Text("Header content is supplied by the app, while the settings screen layout stays shared.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
    }

    private func trailingView(for item: any SettingsItem) -> AnyView? {
        if let item = item as? AppSettingsItem {
            switch item {
            case .lastSync:
                return AnyView(
                    Text(lastSyncDate.formatted(date: .abbreviated, time: .shortened))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                )
            case .notifications, .onboarding:
                return nil
            }
        }

        if let item = item as? SFKInformationSectionItem, item == .version {
            return AnyView(
                Text("2.2.0 (1)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            )
        }

        return nil
    }

    private func showChevron(for item: any SettingsItem) -> Bool {
        if let item = item as? AppSettingsItem, item == .lastSync {
            return false
        }

        if let item = item as? SFKInformationSectionItem, item == .version {
            return false
        }

        return true
    }

    private func handleTap(_ item: any SettingsItem) {
        if let item = item as? AppSettingsItem {
            switch item {
            case .notifications:
                notificationsEnabled.toggle()
            case .lastSync:
                lastSyncDate = .now
            case .onboarding:
                break
            }
        }
    }
}
