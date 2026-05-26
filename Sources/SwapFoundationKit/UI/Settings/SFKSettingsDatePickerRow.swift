//
//  SFKSettingsDatePickerRow.swift
//  SwapFoundationKit
//
//  Created by Swapnanil Dhol on 4/4/26.
//

import SwiftUI

/// A settings row that presents a DatePicker in a sheet when tapped.
///
/// ## Usage
/// ```swift
/// @State private var selectedDate = Date()
///
/// SFKSettingsDatePickerRow(
///     title: "Reminder Date",
///     subtitle: "When to send the reminder",
///     icon: "calendar",
///     tint: .blue,
///     selection: $selectedDate,
///     displayedComponents: [.date]
/// )
/// ```
public struct SFKSettingsDatePickerRow: View {
    @Environment(\.sfkSettingsTheme) private var theme

    private let title: String
    private let subtitle: String
    private let icon: String
    private let tint: Color?
    @Binding private var selection: Date
    private let displayedComponents: DatePickerComponents

    @State private var isPresented = false

    /// Creates a date picker settings row.
    /// - Parameters:
    ///   - title: Primary text label.
    ///   - subtitle: Secondary text label.
    ///   - icon: SF Symbol name for the icon.
    ///   - tint: Tint color for the icon background and icon.
    ///   - selection: Binding to the selected date.
    ///   - displayedComponents: Which components to show (date, time, or both).
    public init(
        title: String,
        subtitle: String,
        icon: String,
        tint: Color? = nil,
        selection: Binding<Date>,
        displayedComponents: DatePickerComponents = [.date]
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.tint = tint
        self._selection = selection
        self.displayedComponents = displayedComponents
    }

    public var body: some View {
        let resolvedTint = theme.resolvedTint(tint)
        Button {
            isPresented = true
        } label: {
            _SFKSettingsRowContent(
                title: title,
                subtitle: subtitle,
                icon: icon,
                tint: resolvedTint
            ) {
                Text(formattedDate)
                    .font(theme.typography.valueFont)
                    .foregroundStyle(theme.colors.valueColor)
                    .multilineTextAlignment(.trailing)

                Image(systemName: "chevron.right")
                    .font(theme.typography.accessoryFont)
                    .foregroundStyle(theme.colors.accessoryColor)
            }
            .padding(.vertical, theme.metrics.rowVerticalPadding)
            .contentShape(Rectangle())
        }
        .buttonStyle(SFKSettingsFormRowButtonStyle())
        .sheet(isPresented: $isPresented) {
            NavigationStack {
                VStack(spacing: 20) {
                    DatePicker(
                        "Select Date",
                        selection: $selection,
                        displayedComponents: displayedComponents
                    )
                    .datePickerStyle(.graphical)
                    .labelsHidden()
                    .tint(resolvedTint)

                    Spacer()
                }
                .padding()
                .navigationTitle(title)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            isPresented = false
                        }
                    }
                }
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        if displayedComponents.contains(.date) && displayedComponents.contains(.hourAndMinute) {
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
        } else if displayedComponents.contains(.date) {
            formatter.dateStyle = .medium
        } else {
            formatter.timeStyle = .short
        }
        return formatter.string(from: selection)
    }
}

/// A settings row that presents a TimePicker (hours and minutes only) in a sheet.
///
/// ## Usage
/// ```swift
/// @State private var selectedTime = Date()
///
/// SFKSettingsTimePickerRow(
///     title: "Alarm Time",
///     subtitle: "When to trigger the alarm",
///     icon: "clock.fill",
///     tint: .orange,
///     selection: $selectedTime
/// )
/// ```
public struct SFKSettingsTimePickerRow: View {
    @Environment(\.sfkSettingsTheme) private var theme

    private let title: String
    private let subtitle: String
    private let icon: String
    private let tint: Color?
    @Binding private var selection: Date

    @State private var isPresented = false

    /// Creates a time picker settings row.
    /// - Parameters:
    ///   - title: Primary text label.
    ///   - subtitle: Secondary text label.
    ///   - icon: SF Symbol name for the icon.
    ///   - tint: Tint color for the icon background and icon.
    ///   - selection: Binding to the selected time.
    public init(
        title: String,
        subtitle: String,
        icon: String,
        tint: Color? = nil,
        selection: Binding<Date>
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.tint = tint
        self._selection = selection
    }

    public var body: some View {
        let resolvedTint = theme.resolvedTint(tint)
        Button {
            isPresented = true
        } label: {
            _SFKSettingsRowContent(
                title: title,
                subtitle: subtitle,
                icon: icon,
                tint: resolvedTint
            ) {
                Text(formattedTime)
                    .font(theme.typography.valueFont)
                    .foregroundStyle(theme.colors.valueColor)
                    .multilineTextAlignment(.trailing)

                Image(systemName: "chevron.right")
                    .font(theme.typography.accessoryFont)
                    .foregroundStyle(theme.colors.accessoryColor)
            }
            .padding(.vertical, theme.metrics.rowVerticalPadding)
            .contentShape(Rectangle())
        }
        .buttonStyle(SFKSettingsFormRowButtonStyle())
        .sheet(isPresented: $isPresented) {
            NavigationStack {
                VStack(spacing: 20) {
                    DatePicker(
                        "Select Time",
                        selection: $selection,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .tint(resolvedTint)

                    Spacer()
                }
                .padding()
                .navigationTitle(title)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            isPresented = false
                        }
                    }
                }
            }
            // Wheel pickers need vertical room; `.medium` alone is often too cramped or blank.
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
    }

    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: selection)
    }
}

/// A settings row that presents a DatePicker inline within the settings form.
///
/// ## Usage
/// ```swift
/// @State private var selectedDate = Date()
///
/// SFKSettingsInlineDatePicker(
///     title: "Reminder Date",
///     icon: "calendar",
///     tint: .blue,
///     selection: $selectedDate
/// )
/// ```
public struct SFKSettingsInlineDatePicker: View {
    @Environment(\.sfkSettingsTheme) private var theme

    private let title: String
    private let icon: String
    private let tint: Color?
    @Binding private var selection: Date
    private let displayedComponents: DatePickerComponents

    /// Creates an inline date picker settings row.
    public init(
        title: String,
        icon: String,
        tint: Color? = nil,
        selection: Binding<Date>,
        displayedComponents: DatePickerComponents = [.date]
    ) {
        self.title = title
        self.icon = icon
        self.tint = tint
        self._selection = selection
        self.displayedComponents = displayedComponents
    }

    public var body: some View {
        let resolvedTint = theme.resolvedTint(tint)
        _SFKSettingsRowContent(
            title: title,
            subtitle: "",
            icon: icon,
            tint: resolvedTint
        ) {
            DatePicker(
                title,
                selection: $selection,
                displayedComponents: displayedComponents
            )
            .labelsHidden()
            .font(theme.typography.subtitleFont)
            .tint(resolvedTint)
        }
        .padding(.vertical, theme.metrics.rowVerticalPadding)
    }
}

// MARK: - Previews

#Preview("SFKSettingsDatePickerRow") {
    @Previewable @State var selectedDate = Date.now

    List {
        SFKSettingsDatePickerRow(
            title: "Reminder Date",
            subtitle: "Choose when the next reminder should be scheduled.",
            icon: "calendar.badge.clock",
            tint: .blue,
            selection: $selectedDate,
            displayedComponents: [.date]
        )
        SFKSettingsDatePickerRow(
            title: "Delivery Window",
            subtitle: "Pick both the date and time for the scheduled action.",
            icon: "calendar.and.clock",
            tint: .indigo,
            selection: $selectedDate,
            displayedComponents: [.date, .hourAndMinute]
        )
    }
}

#Preview("SFKSettingsTimePickerRow") {
    @Previewable @State var selectedTime = Date.now

    List {
        SFKSettingsTimePickerRow(
            title: "Daily Reminder",
            subtitle: "Select the time used for recurring reminders.",
            icon: "clock.fill",
            tint: .orange,
            selection: $selectedTime
        )
    }
}

#Preview("SFKSettingsInlineDatePicker") {
    @Previewable @State var selectedDate = Date.now

    List {
        SFKSettingsInlineDatePicker(
            title: "Start Date",
            icon: "calendar",
            tint: .green,
            selection: $selectedDate,
            displayedComponents: [.date]
        )
        SFKSettingsInlineDatePicker(
            title: "Quiet Hours",
            icon: "moon.stars.fill",
            tint: .purple,
            selection: $selectedDate,
            displayedComponents: [.hourAndMinute]
        )
    }
}
