//
//  SFKSettingsScreen.swift
//  SwapFoundationKit
//
//  Created by Swapnanil Dhol on 4/4/26.
//

import SwiftUI

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
    private let sections: [SFKSettingsSectionConfiguration]
    private let onItemTap: SFKSettingsItemAction?
    private let rowTrailingBuilder: SFKSettingsTrailingBuilder?
    private let showChevron: Bool

    /// Creates a settings screen without a header.
    /// - Parameters:
    ///   - sections: Configuration for each section.
    ///   - showChevron: Whether to show chevrons on rows. Default is `true`.
    ///   - onItemTap: Handler called when a settings row is tapped.
    public init(
        sections: [SFKSettingsSectionConfiguration],
        showChevron: Bool = true,
        onItemTap: @escaping SFKSettingsItemAction
    ) {
        self.headerContent = nil
        self.sections = sections
        self.showChevron = showChevron
        self.onItemTap = onItemTap
        self.rowTrailingBuilder = nil
    }

    /// Creates a settings screen with a header view.
    /// - Parameters:
    ///   - header: Any view to display as the header (e.g., ProBannerView).
    ///   - sections: Configuration for each section.
    ///   - showChevron: Whether to show chevrons on rows. Default is `true`.
    ///   - onItemTap: Handler called when a settings row is tapped.
    public init<H: View>(
        header: H,
        sections: [SFKSettingsSectionConfiguration],
        showChevron: Bool = true,
        onItemTap: @escaping SFKSettingsItemAction
    ) {
        self.headerContent = AnyView(header)
        self.sections = sections
        self.showChevron = showChevron
        self.onItemTap = onItemTap
        self.rowTrailingBuilder = nil
    }

    public var body: some View {
        Form {
            if let header = headerContent {
                Section {
                    header
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
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
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func rowView(for item: any SettingsItem) -> some View {
        let trailing = rowTrailingBuilder?(item)
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
                TogglePreview()
            } header: {
                Text("Toggles")
            }

            // Date/Time
            Section {
                DatePickerPreview()
            } header: {
                Text("Date & Time")
            }

            // Numeric
            Section {
                NumericPreview()
            } header: {
                Text("Numeric Controls")
            }

            // Colors
            Section {
                ColorPreview()
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
}

// MARK: - Preview Components

private struct TogglePreview: View {
    @State private var enabled1 = true
    @State private var enabled2 = false

    var body: some View {
        VStack(spacing: 16) {
            SFKSettingsToggle(
                title: "Push Notifications",
                subtitle: "Receive notifications",
                icon: "bell.badge.fill",
                tint: .blue,
                isOn: $enabled1
            )
            SFKSettingsToggle(
                title: "Dark Mode",
                subtitle: "Use dark appearance",
                icon: "moon.fill",
                tint: .purple,
                isOn: $enabled2
            )
        }
    }
}

private struct DatePickerPreview: View {
    @State private var date = Date()
    @State private var time = Date()

    var body: some View {
        VStack(spacing: 16) {
            SFKSettingsDatePickerRow(
                title: "Reminder Date",
                subtitle: "When to remind",
                icon: "calendar",
                tint: .orange,
                selection: $date,
                displayedComponents: [.date]
            )
            SFKSettingsTimePickerRow(
                title: "Alarm Time",
                subtitle: "When to alarm",
                icon: "clock.fill",
                tint: .red,
                selection: $time
            )
            SFKSettingsInlineDatePicker(
                title: "Inline Date",
                icon: "calendar.badge.plus",
                tint: .green,
                selection: $date,
                displayedComponents: [.date]
            )
        }
    }
}

private struct NumericPreview: View {
    @State private var count = 3
    @State private var opacity: Double = 0.75

    var body: some View {
        VStack(spacing: 16) {
            SFKSettingsStepperRow(
                title: "Alert Count",
                subtitle: "How many times",
                icon: "bell.badge",
                tint: .red,
                value: $count,
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
        }
    }
}

private struct ColorPreview: View {
    @State private var color = Color.blue

    var body: some View {
        VStack(spacing: 16) {
            SFKSettingsColorPickerRow(
                title: "Theme Color",
                subtitle: "Choose your color",
                icon: "paintpalette.fill",
                tint: .purple,
                selection: $color
            )
            SFKSettingsInlineColorPicker(
                title: "Accent Color",
                icon: "paintbrush.fill",
                tint: color,
                selection: $color
            )
        }
    }
}
