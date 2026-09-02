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
public struct SFKSettingsScreen<Content: View, Background: View>: View {
    @Environment(\.sfkTheme) private var theme
    private let navigationTitle: String
    private let content: () -> Content
    private let background: () -> Background

    /// Creates a typed settings screen from a SwiftUI result-builder closure.
    public init(
        navigationTitle: String = "Settings",
        @ViewBuilder content: @escaping () -> Content
    ) where Background == _SFKSettingsThemeSurface {
        self.navigationTitle = navigationTitle
        self.content = content
        self.background = { _SFKSettingsThemeSurface() }
    }

    /// Creates a typed settings screen with a custom background layer (e.g. a
    /// ``TabRootAuraLayer``-style glow over a flat fill) instead of the plain
    /// themed surface. The caller owns the full background — including its
    /// own base fill — so the Form is never stacked over more than one
    /// painted layer, which is what keeps `.listRowBackground` reliable once
    /// `.scrollContentBackground(.hidden)` is applied.
    public init(
        navigationTitle: String = "Settings",
        @ViewBuilder background: @escaping () -> Background,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.navigationTitle = navigationTitle
        self.content = content
        self.background = background
    }

    public var body: some View {
        // A ZStack pairing the List with its background is unreliable once
        // `.scrollContentBackground(.hidden)` is applied — `.listRowBackground`
        // silently stops painting. Chaining `.background()` directly onto the
        // Form (the same pattern HomeView's List uses for its aura) keeps the
        // Form as the sole top-level view and avoids that failure mode.
        Form { content() }
            .scrollContentBackground(.hidden)
            .background(alignment: .top) {
                background()
                    .allowsHitTesting(false)
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .tint(theme.colors.accent)
    }
}

public struct _SFKSettingsThemeSurface: View {
    @Environment(\.sfkTheme) private var theme

    public init() {}

    public var body: some View {
        theme.colors.background
            .ignoresSafeArea()
    }
}
