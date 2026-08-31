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
    private let navigationTitle: String
    private let content: () -> Content
    private let legacyTheme: SFKSettingsTheme?
    private let legacyContent: (() -> _SFKLegacySettingsContent)?

    /// Creates a typed settings screen from a SwiftUI result-builder closure.
    public init(
        navigationTitle: String = "Settings",
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(navigationTitle: navigationTitle, legacyTheme: nil, content: content, legacyContent: nil)
    }

    private init(
        navigationTitle: String,
        legacyTheme: SFKSettingsTheme?,
        @ViewBuilder content: @escaping () -> Content,
        legacyContent: (() -> _SFKLegacySettingsContent)?
    ) {
        self.navigationTitle = navigationTitle
        self.content = content
        self.legacyTheme = legacyTheme
        self.legacyContent = legacyContent
    }

    @ViewBuilder
    public var body: some View {
        if let legacyContent {
            legacyContent()
                .navigationTitle(navigationTitle)
                .navigationBarTitleDisplayMode(.inline)
                .modifier(_SFKLegacyThemeModifier(theme: legacyTheme))
        } else {
            Form { content() }
                .navigationTitle(navigationTitle)
                .navigationBarTitleDisplayMode(.inline)
                .scrollContentBackground(.hidden)
                .background(_SFKSettingsThemeSurface())
        }
    }
}

private struct _SFKSettingsThemeSurface: View {
    @Environment(\.sfkTheme) private var theme

    var body: some View {
        theme.colors.background
            .ignoresSafeArea()
    }
}

// MARK: - v3 compatibility

/// Configuration for a custom section within the legacy array-based settings API.
@available(*, deprecated, message: "Use SFKSettingsScreen's typed result-builder API.")
public struct SFKSettingsCustomSection: Identifiable {
    public let id: String
    public let title: String
    public let footer: String?
    public let content: AnyView

    public init<SectionContent: View>(
        id: String = UUID().uuidString,
        title: String = "",
        footer: String? = nil,
        @ViewBuilder content: () -> SectionContent
    ) {
        self.id = id
        self.title = title
        self.footer = footer
        self.content = AnyView(content())
    }
}

/// Configuration for an individual section in the legacy array-based API.
@available(*, deprecated, message: "Use SFKSettingsSection inside SFKSettingsScreen's builder.")
public struct SFKSettingsSectionConfiguration: Identifiable {
    public let id: String
    public let title: String
    public let items: [any SettingsItem]
    public let footer: String?
    let rows: [SFKAnySettingsItem]

    public init(
        id: String = UUID().uuidString,
        title: String,
        items: [any SettingsItem],
        footer: String? = nil
    ) {
        self.id = id
        self.title = title
        self.items = items
        self.footer = footer
        self.rows = items.map(SFKAnySettingsItem.init)
    }
}

struct SFKAnySettingsItem: Identifiable {
    let id: String
    let base: any SettingsItem

    init(_ base: any SettingsItem) {
        id = base.id
        self.base = base
    }
}

public typealias SFKSettingsItemAction = (any SettingsItem) -> Void
public typealias SFKSettingsTrailingBuilder = (any SettingsItem) -> SFKSettingsTrailing?
public typealias SFKSettingsChevronBuilder = (any SettingsItem) -> Bool

@available(*, deprecated, message: "Use SFKSettingsScreen's typed result-builder API.")
public extension SFKSettingsScreen where Content == EmptyView {
    /// Legacy array-based settings initializer retained for source compatibility.
    init(
        customSections: [SFKSettingsCustomSection] = [],
        sections: [SFKSettingsSectionConfiguration],
        theme: SFKSettingsTheme = SFKSettingsTheme(),
        showChevron: Bool = true,
        auraColor: Color? = nil,
        rowTrailingBuilder: SFKSettingsTrailingBuilder? = nil,
        rowChevronBuilder: SFKSettingsChevronBuilder? = nil,
        onItemTap: @escaping SFKSettingsItemAction
    ) {
        self.init(navigationTitle: "Settings", legacyTheme: theme, content: { EmptyView() }, legacyContent: {
            _SFKLegacySettingsContent(
                header: nil,
                customSections: customSections,
                sections: sections,
                showChevron: showChevron,
                auraColor: auraColor,
                rowTrailingBuilder: rowTrailingBuilder,
                rowChevronBuilder: rowChevronBuilder,
                onItemTap: onItemTap
            )
        })
    }

    /// Legacy array-based initializer with arbitrary header content.
    init<Header: View>(
        header: Header,
        customSections: [SFKSettingsCustomSection] = [],
        sections: [SFKSettingsSectionConfiguration],
        theme: SFKSettingsTheme = SFKSettingsTheme(),
        showChevron: Bool = true,
        auraColor: Color? = nil,
        rowTrailingBuilder: SFKSettingsTrailingBuilder? = nil,
        rowChevronBuilder: SFKSettingsChevronBuilder? = nil,
        onItemTap: @escaping SFKSettingsItemAction
    ) {
        self.init(navigationTitle: "Settings", legacyTheme: theme, content: { EmptyView() }, legacyContent: {
            _SFKLegacySettingsContent(
                header: AnyView(header),
                customSections: customSections,
                sections: sections,
                showChevron: showChevron,
                auraColor: auraColor,
                rowTrailingBuilder: rowTrailingBuilder,
                rowChevronBuilder: rowChevronBuilder,
                onItemTap: onItemTap
            )
        })
    }
}

private struct _SFKLegacyThemeModifier: ViewModifier {
    let theme: SFKSettingsTheme?

    func body(content: Content) -> some View {
        if let theme { content.sfkSettingsTheme(theme) } else { content }
    }
}

private struct _SFKLegacySettingsContent: View {
    let header: AnyView?
    let customSections: [SFKSettingsCustomSection]
    let sections: [SFKSettingsSectionConfiguration]
    let showChevron: Bool
    let auraColor: Color?
    let rowTrailingBuilder: SFKSettingsTrailingBuilder?
    let rowChevronBuilder: SFKSettingsChevronBuilder?
    let onItemTap: SFKSettingsItemAction

    var body: some View {
        Group {
            if let auraColor {
                ZStack(alignment: .top) {
                    TopAuraBackground(glowColor: auraColor, opacity: 0.22, blurRadius: 40, bandHeight: 320)
                        .allowsHitTesting(false)
                    form
                }
            } else { form }
        }
    }

    private var form: some View {
        Form {
            if let header {
                Section { header }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            }
            ForEach(customSections) { section in
                Section {
                    section.content
                } header: {
                    if !section.title.isEmpty { Text(section.title) }
                } footer: {
                    if let footer = section.footer { Text(footer) }
                }
            }
            ForEach(sections) { section in
                Section {
                    ForEach(section.rows) { row in
                        let item = row.base
                        SFKSettingsRow(
                            item: item,
                            action: { onItemTap(item) },
                            showChevron: rowChevronBuilder?(item) ?? showChevron,
                            trailingView: rowTrailingBuilder?(item)
                        )
                    }
                } header: {
                    if !section.title.isEmpty { Text(section.title) }
                } footer: {
                    if let footer = section.footer { Text(footer) }
                }
            }
        }
    }
}
