//
//  SFKSettingsScreen.swift
//  SwapFoundationKit
//
//  Created by Swapnanil Dhol on 4/4/26.
//

import SwiftUI

/// Configuration for a custom section within the settings screen.
public struct SFKSettingsCustomSection: Identifiable {
    public let id = UUID()
    public let title: String
    public let footer: String?
    public let content: AnyView

    /// Creates a custom section with arbitrary SwiftUI content.
    /// - Parameters:
    ///   - title: The section header title. Empty string hides the header.
    ///   - footer: Optional footer text displayed below the section.
    ///   - content: Arbitrary SwiftUI content rendered inside the section.
    public init<Content: View>(
        title: String = "",
        footer: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.footer = footer
        self.content = AnyView(content())
    }
}

/// Configuration for an individual section within the settings screen.
public struct SFKSettingsSectionConfiguration: Identifiable {
    public let id = UUID()
    public let title: String
    public let items: [any SettingsItem]
    public let footer: String?

    /// Creates a section configuration.
    /// - Parameters:
    ///   - title: The section header title. Empty string hides the header.
    ///   - items: The settings items to display in this section.
    ///   - footer: Optional footer text displayed below the section.
    public init(
        title: String,
        items: [any SettingsItem],
        footer: String? = nil
    ) {
        self.title = title
        self.items = items
        self.footer = footer
    }
}

/// A closure type for handling settings item taps.
public typealias SFKSettingsItemAction = (any SettingsItem) -> Void

/// A closure type for building custom trailing content for a settings row.
public typealias SFKSettingsTrailingBuilder = (any SettingsItem) -> AnyView?

/// A closure type for deciding whether a specific settings row should show a chevron.
public typealias SFKSettingsChevronBuilder = (any SettingsItem) -> Bool

/// A reusable settings screen component with form-based sections.
///
/// Provides a standard iOS settings screen layout with:
/// - Optional header content (e.g., pro banner)
/// - Form-based sections with headers and optional footers
/// - Standard row rendering with icon, title, subtitle, and chevron
/// - Custom trailing content support
///
/// ## Basic Usage
/// ```swift
/// struct MySettingsView: View {
///     var body: some View {
///         SFKSettingsScreen(
///             sections: [
///                 SFKSettingsSectionConfiguration(
///                     title: "Information",
///                     items: SFKInformationSectionItem.allCases
///                 )
///             ],
///             onItemTap: { item in
///                 handleItem(item)
///             }
///         )
///     }
/// }
/// ```
public struct SFKSettingsScreen: View {

    private let headerContent: AnyView?
    private let customSections: [SFKSettingsCustomSection]
    private let sections: [SFKSettingsSectionConfiguration]
    private let theme: SFKSettingsTheme
    private let onItemTap: SFKSettingsItemAction?
    private let rowTrailingBuilder: SFKSettingsTrailingBuilder?
    private let rowChevronBuilder: SFKSettingsChevronBuilder?
    private let defaultShowChevron: Bool
    private let auraColor: Color?

    /// Creates a settings screen without a header.
    /// - Parameters:
    ///   - customSections: Arbitrary sections rendered before standard item sections.
    ///   - sections: Configuration for each section.
    ///   - theme: Theme for colors, typography, and sizing.
    ///   - showChevron: Default chevron visibility for rows. Default is `true`.
    ///   - rowTrailingBuilder: Optional builder for row trailing content.
    ///   - rowChevronBuilder: Optional builder for per-row chevron visibility.
    ///   - onItemTap: Handler called when a settings row is tapped.
    public init(
        customSections: [SFKSettingsCustomSection] = [],
        sections: [SFKSettingsSectionConfiguration],
        theme: SFKSettingsTheme = SFKSettingsTheme(),
        showChevron: Bool = true,
        auraColor: Color? = nil,
        rowTrailingBuilder: SFKSettingsTrailingBuilder? = nil,
        rowChevronBuilder: SFKSettingsChevronBuilder? = nil,
        onItemTap: @escaping SFKSettingsItemAction
    ) {
        self.headerContent = nil
        self.customSections = customSections
        self.sections = sections
        self.theme = theme
        self.defaultShowChevron = showChevron
        self.auraColor = auraColor
        self.onItemTap = onItemTap
        self.rowTrailingBuilder = rowTrailingBuilder
        self.rowChevronBuilder = rowChevronBuilder
    }

    /// Creates a settings screen with a header view.
    /// - Parameters:
    ///   - header: Any view to display as the header (e.g., ProBannerView).
    ///   - customSections: Arbitrary sections rendered before standard item sections.
    ///   - sections: Configuration for each section.
    ///   - theme: Theme for colors, typography, and sizing.
    ///   - showChevron: Default chevron visibility for rows. Default is `true`.
    ///   - rowTrailingBuilder: Optional builder for row trailing content.
    ///   - rowChevronBuilder: Optional builder for per-row chevron visibility.
    ///   - onItemTap: Handler called when a settings row is tapped.
    public init<H: View>(
        header: H,
        customSections: [SFKSettingsCustomSection] = [],
        sections: [SFKSettingsSectionConfiguration],
        theme: SFKSettingsTheme = SFKSettingsTheme(),
        showChevron: Bool = true,
        auraColor: Color? = nil,
        rowTrailingBuilder: SFKSettingsTrailingBuilder? = nil,
        rowChevronBuilder: SFKSettingsChevronBuilder? = nil,
        onItemTap: @escaping SFKSettingsItemAction
    ) {
        self.headerContent = AnyView(header)
        self.customSections = customSections
        self.sections = sections
        self.theme = theme
        self.defaultShowChevron = showChevron
        self.auraColor = auraColor
        self.onItemTap = onItemTap
        self.rowTrailingBuilder = rowTrailingBuilder
        self.rowChevronBuilder = rowChevronBuilder
    }

    public var body: some View {
        Group {
            if let auraColor {
                ZStack(alignment: .top) {
                    TopAuraBackground(
                        glowColor: auraColor,
                        opacity: 0.22,
                        blurRadius: 40,
                        bandHeight: 320
                    )
                    .allowsHitTesting(false)

                    formContent
                        .scrollContentBackground(.hidden)
                }
            } else {
                formContent
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .sfkSettingsTheme(theme)
    }

    private var formContent: some View {
        Form {
            if let header = headerContent {
                Section {
                    header
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }

            ForEach(customSections) { section in
                Section {
                    section.content
                } header: {
                    if !section.title.isEmpty {
                        Text(section.title)
                    }
                } footer: {
                    if let footer = section.footer {
                        Text(footer)
                    }
                }
                .listRowBackground(rowBackground)
            }

            ForEach(sections) { section in
                Section {
                    ForEach(0..<section.items.count, id: \.self) { index in
                        let item = section.items[index]
                        rowView(for: item)
                    }
                } header: {
                    if !section.title.isEmpty {
                        Text(section.title)
                    }
                } footer: {
                    if let footer = section.footer {
                        Text(footer)
                    }
                }
                .listRowBackground(rowBackground)
            }
        }
    }

    private var rowBackground: some View {
        if auraColor != nil {
            Color(.secondarySystemGroupedBackground)
        } else {
            Color(.systemGroupedBackground)
        }
    }

    @ViewBuilder
    private func rowView(for item: any SettingsItem) -> some View {
        let trailing = rowTrailingBuilder?(item)
        let showChevron = rowChevronBuilder?(item) ?? defaultShowChevron
        SFKSettingsRow(
            item: item,
            action: { onItemTap?(item) },
            showChevron: showChevron,
            trailingView: trailing
        )
    }
}

// MARK: - Preview

#Preview("Settings Screen - All Row Types") {
    @Previewable @State var notificationsEnabled = true
    @Previewable @State var darkModeEnabled = false
    @Previewable @State var selectedDate = Date.now
    @Previewable @State var selectedTime = Date.now
    @Previewable @State var units = "metric"
    @Previewable @State var navigationMode = "walking"
    @Previewable @State var alertCount = 3
    @Previewable @State var opacity = 0.75
    @Previewable @State var themeColor = Color.blue

    let unitOptions = [
        SFKSettingsPickerOption(id: "metric", label: "Metric"),
        SFKSettingsPickerOption(id: "imperial", label: "Imperial")
    ]

    let navigationOptions = [
        SFKSettingsPickerOption(id: "walking", label: "Walking"),
        SFKSettingsPickerOption(id: "cycling", label: "Cycling"),
        SFKSettingsPickerOption(id: "driving", label: "Driving")
    ]

    let previewTheme = SFKSettingsTheme(
        colors: .init(
            accent: .mint,
            itemTintBehavior: .useAccent,
            toggleOnTint: .mint,
            sliderTint: .mint
        )
    )

    NavigationStack {
        Form {
            // Header
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("MyApp Pro")
                        .font(.title2.bold())
                    Text("Upgrade for premium features")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 8)
            }

            // Toggles
            Section {
                SFKSettingsToggle(
                    title: "Push Notifications",
                    subtitle: "Receive notifications",
                    icon: "bell.badge.fill",
                    tint: .blue,
                    isOn: $notificationsEnabled
                )
                SFKSettingsToggle(
                    title: "Dark Mode",
                    subtitle: "Use dark appearance",
                    icon: "moon.fill",
                    tint: .purple,
                    isOn: $darkModeEnabled
                )
            } header: {
                Text("Toggles")
            }

            // Date/Time
            Section {
                SFKSettingsDatePickerRow(
                    title: "Reminder Date",
                    subtitle: "When to remind",
                    icon: "calendar",
                    tint: .orange,
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                SFKSettingsTimePickerRow(
                    title: "Alarm Time",
                    subtitle: "When to alarm",
                    icon: "clock.fill",
                    tint: .red,
                    selection: $selectedTime
                )
                SFKSettingsInlineDatePicker(
                    title: "Inline Date",
                    icon: "calendar.badge.plus",
                    tint: .green,
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
            } header: {
                Text("Date & Time")
            }

            // Pickers
            Section {
                SFKSettingsPickerRow(
                    title: "Units",
                    subtitle: "Choose the default measurement system.",
                    icon: "ruler.fill",
                    tint: .green,
                    options: unitOptions,
                    selection: $units,
                    displayName: { value in
                        unitOptions.first(where: { $0.id == value })?.label ?? value
                    },
                    pickerStyle: .actionSheet
                )
                SFKSettingsPickerSheetRow(
                    title: "Navigation Mode",
                    subtitle: "Use a sheet picker for longer lists of options.",
                    icon: "list.bullet.rectangle.portrait.fill",
                    tint: .blue,
                    options: navigationOptions,
                    selection: $navigationMode,
                    displayName: { value in
                        navigationOptions.first(where: { $0.id == value })?.label ?? value
                    }
                )
            } header: {
                Text("Pickers")
            }

            // Numeric
            Section {
                SFKSettingsStepperRow(
                    title: "Alert Count",
                    subtitle: "How many times",
                    icon: "bell.badge",
                    tint: .red,
                    value: $alertCount,
                    range: 1...10,
                    step: 1,
                    displayValue: { "\($0) times" }
                )
                SFKSettingsSliderRow(
                    title: "Opacity",
                    subtitle: "Adjust transparency",
                    icon: "circle.lefthalf.filled",
                    tint: .blue,
                    value: $opacity,
                    range: 0...1,
                    step: 0.01,
                    displayValue: { "\(Int($0 * 100))%" }
                )
            } header: {
                Text("Numeric Controls")
            }

            // Colors
            Section {
                SFKSettingsColorPickerRow(
                    title: "Theme Color",
                    subtitle: "Choose your color",
                    icon: "paintpalette.fill",
                    tint: .purple,
                    selection: $themeColor
                )
                SFKSettingsInlineColorPicker(
                    title: "Accent Color",
                    icon: "paintbrush.fill",
                    tint: themeColor,
                    selection: $themeColor
                )
            } header: {
                Text("Colors")
            }

            // Standard Items
            Section {
                ForEach(SFKInformationSectionItem.allCases, id: \.id) { item in
                    SFKSettingsRow(item: item) {
                        print("Tapped: \(item.title)")
                    }
                }
            } header: {
                Text("Standard Items")
            }

            // Developer
            Section {
                ForEach(SFKDeveloperSectionItem.allCases, id: \.id) { item in
                    SFKSettingsRow(item: item) {
                        print("Tapped: \(item.title)")
                    }
                }
            } header: {
                Text("Developer")
            }

            // Link
            Section {
                SFKSettingsLinkRow(
                    title: "Documentation",
                    subtitle: "Read the full docs",
                    icon: "book.fill",
                    tint: .green,
                    url: URL(string: "https://example.com")!
                )
            }

            // Destructive
            Section {
                SFKSettingsDestructiveRow(
                    title: "Delete Account",
                    subtitle: "Permanently delete",
                    icon: "trash.fill",
                    action: {}
                )
                SFKSettingsConfirmationRow(
                    title: "Reset Settings",
                    subtitle: "Return to defaults",
                    icon: "arrow.counterclockwise",
                    tint: .orange,
                    confirmationTitle: "Reset?",
                    confirmationMessage: "This cannot be undone.",
                    confirmTitle: "Reset",
                    confirmStyle: .destructive
                ) {}
            } header: {
                Text("Danger Zone")
            }
        }
        .navigationTitle("Settings Preview")
    }
    .sfkSettingsTheme(previewTheme)
}
