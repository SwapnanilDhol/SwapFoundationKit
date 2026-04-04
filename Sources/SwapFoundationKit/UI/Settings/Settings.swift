//
//  Settings.swift
//  SwapFoundationKit
//
//  Created by Swapnanil Dhol on 4/4/26.
//

/// # Settings Module
///
/// SwapFoundationKit provides a comprehensive Settings UI module for building
/// iOS settings screens with minimal boilerplate.
///
/// ## Components
///
/// ### Protocol
/// - `SettingsItem` - Protocol defining a settings row contract
///
/// ### Row Components
/// - `SFKSettingsRow` - Tappable row with icon, title, subtitle, chevron
/// - `SFKSettingsLabel` - Display-only label row
/// - `SFKSettingsToggle` / `SFKSettingsToggleRow` - Toggle row
/// - `SFKSettingsDatePickerRow` - Date picker in sheet
/// - `SFKSettingsTimePickerRow` - Time picker in sheet
/// - `SFKSettingsInlineDatePicker` - Inline date picker
/// - `SFKSettingsStepperRow` - Numeric stepper row
/// - `SFKSettingsSliderRow` - Slider row
/// - `SFKSettingsColorPickerRow` - Color picker in sheet
/// - `SFKSettingsInlineColorPicker` - Inline color picker
/// - `SFKSettingsLinkRow` - Opens URL externally
/// - `SFKSettingsDestructiveRow` - Destructive action row (red styling)
/// - `SFKSettingsConfirmationRow` - Row with confirmation dialog
///
/// ### Screen Components
/// - `SFKSettingsScreen` - Full settings screen with sections
/// - `SFKSettingsSectionConfiguration` - Section configuration
///
/// ### Section Items
/// - `SFKInformationSectionItem` - Standard info items (version, report bug, rate, share, privacy, terms)
/// - `SFKDeveloperSectionItem` - Developer items (website, twitter, another app)
///
/// ### Action Handlers
/// - `SFKSettingsActionHandler` - Rate app, share, open URLs
/// - `SFKInformationSectionHandler` - Handle info item taps
/// - `SFKDeveloperSectionHandler` - Handle developer item taps
///
/// ## Usage Examples
///
/// ### Basic Tappable Row
/// ```swift
/// enum MyItem: String, SettingsItem {
///     case notifications
///     var id: String { rawValue }
///     var icon: String { "bell.circle.fill" }
///     var title: String { "Notifications" }
///     var subtitle: String { "Manage notifications" }
///     var tint: Color { .blue }
/// }
///
/// SFKSettingsRow(item: MyItem.notifications) {
///     // Handle tap
/// }
/// ```
///
/// ### Toggle Row
/// ```swift
/// @AppStorage("enabled") private var isEnabled = false
///
/// SFKSettingsToggle(
///     title: "Notifications",
///     subtitle: "Receive push notifications",
///     icon: "bell.circle.fill",
///     tint: .blue,
///     isOn: $isEnabled
/// )
/// ```
///
/// ### Date Picker Row
/// ```swift
/// @State private var reminderDate = Date()
///
/// SFKSettingsDatePickerRow(
///     title: "Reminder",
///     subtitle: "When to remind",
///     icon: "calendar",
///     tint: .orange,
///     selection: $reminderDate,
///     displayedComponents: [.date]
/// )
/// ```
///
/// ### Picker Row (Options)
/// ```swift
/// @State private var selectedUnit = "metric"
///
/// // Use with SFKSettingsPickerSheetRow or confirmationDialog-based picker
/// ```
///
/// ### Stepper Row
/// ```swift
/// @State private var count = 5
///
/// SFKSettingsStepperRow(
///     title: "Alert Count",
///     subtitle: "Number of reminders",
///     icon: "bell.badge",
///     tint: .red,
///     value: $count,
///     range: 1...10,
///     step: 1
/// )
/// ```
///
/// ### Slider Row
/// ```swift
/// @State private var opacity: Double = 0.5
///
/// SFKSettingsSliderRow(
///     title: "Opacity",
///     subtitle: "Adjust transparency",
///     icon: "circle.lefthalf.filled",
///     tint: .blue,
///     value: $opacity,
///     range: 0...1,
///     step: 0.01,
///     displayValue: { "\(Int($0 * 100))%" }
/// )
/// ```
///
/// ### Color Picker Row
/// ```swift
/// @State private var themeColor = Color.blue
///
/// SFKSettingsColorPickerRow(
///     title: "Theme Color",
///     subtitle: "Choose app color",
///     icon: "paintpalette",
///     tint: .purple,
///     selection: $themeColor
/// )
/// ```
///
/// ### Destructive Action
/// ```swift
/// SFKSettingsDestructiveRow(
///     title: "Delete Account",
///     subtitle: "This cannot be undone",
///     icon: "trash"
/// ) {
///     // Delete account
/// }
/// ```
///
/// ### Confirmation Row
/// ```swift
/// SFKSettingsConfirmationRow(
///     title: "Reset All Data",
///     subtitle: "Clear all app settings",
///     icon: "exclamationmark.triangle",
///     tint: .orange,
///     confirmationTitle: "Reset Data?",
///     confirmationMessage: "All data will be lost.",
///     confirmTitle: "Reset",
///     confirmStyle: .destructive
/// ) {
///     // Reset data
/// }
/// ```
///
/// ### Full Settings Screen
/// ```swift
/// SFKSettingsScreen(
///     header: {
///         ProBannerView()
///     },
///     sections: [
///         SFKSettingsSectionConfiguration(
///             title: "Preferences",
///             items: []
///         ),
///         SFKSettingsSectionConfiguration(
///             title: "Information",
///             items: SFKInformationSectionItem.allCases
///         ),
///         SFKSettingsSectionConfiguration(
///             title: "Developer",
///             items: SFKDeveloperSectionItem.allCases
///         )
///     ],
///     onItemTap: { item in
///         handleItemTap(item)
///     }
/// )
/// ```
