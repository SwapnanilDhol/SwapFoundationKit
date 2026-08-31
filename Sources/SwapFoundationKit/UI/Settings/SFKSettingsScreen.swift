//
//  SFKSettingsScreen.swift
//  SwapFoundationKit
//

import SwiftUI

/// A typed section in an ``SFKSettingsScreen``.
///
/// Sections are views instead of erased values. This keeps the result-builder
/// path fully generic, so a settings screen does not need ``AnyView`` or an
/// existential row dispatch table.
public struct SFKSettingsSection<Content: View>: View {
    @Environment(\.sfkTheme) private var theme
    private let title: String
    private let footer: String?
    private let content: () -> Content

    public init(
        _ title: String = "",
        footer: String? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.footer = footer
        self.content = content
    }

    public var body: some View {
        Section {
            content()
        } header: {
            if !title.isEmpty { Text(title) }
        } footer: {
            if let footer { Text(footer) }
        }
        .listRowBackground(theme.colors.surface)
    }
}

/// A reusable, type-safe settings screen.
///
/// The builder initializer is the v4 API. Rows are ordinary generic SwiftUI
/// views, which means bindings and action closures retain their concrete value
/// types all the way to the control that consumes them.
///
/// ## Usage
/// ```swift
/// SFKSettingsScreen {
///     SFKSettingsSection("Preferences") {
///         SFKSettingsToggle("Notifications", systemImage: "bell", isOn: $notifications)
///         SFKSettingsRow("About", systemImage: "info.circle") { showAbout() }
///     }
/// }
/// ```
public struct SFKSettingsScreen<Content: View>: View {
    @Environment(\.sfkTheme) private var theme
    private let navigationTitle: String
    private let content: () -> Content

    /// Creates a typed settings screen from a SwiftUI result-builder closure.
    public init(
        navigationTitle: String = "Settings",
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.navigationTitle = navigationTitle
        self.content = content
    }

    public var body: some View {
        Form { content() }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .scrollContentBackground(.hidden)
            .background(_SFKSettingsThemeSurface())
            .tint(theme.colors.accent)
    }
}

private struct _SFKSettingsThemeSurface: View {
    @Environment(\.sfkTheme) private var theme

    var body: some View {
        theme.colors.background
            .ignoresSafeArea()
    }
}
