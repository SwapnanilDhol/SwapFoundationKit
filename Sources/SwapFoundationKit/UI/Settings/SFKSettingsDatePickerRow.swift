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

    private let title: String
    private let subtitle: String
    private let icon: String
    private let tint: Color
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
        tint: Color,
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
        Button {
            isPresented = true
        } label: {
            HStack(spacing: 14) {
                iconContainer

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.primary)

                    Text(subtitle)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                Text(formattedDate)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
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
            .presentationDetents([.medium])
        }
    }

    private var iconContainer: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(tint.opacity(0.14))

            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(tint)
        }
        .frame(width: 36, height: 36)
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

    private let title: String
    private let subtitle: String
    private let icon: String
    private let tint: Color
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
        tint: Color,
        selection: Binding<Date>
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.tint = tint
        self._selection = selection
    }

    public var body: some View {
        Button {
            isPresented = true
        } label: {
            HStack(spacing: 14) {
                iconContainer

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.primary)

                    Text(subtitle)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                Text(formattedTime)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
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
            .presentationDetents([.medium])
        }
    }

    private var iconContainer: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(tint.opacity(0.14))

            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(tint)
        }
        .frame(width: 36, height: 36)
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

    private let title: String
    private let icon: String
    private let tint: Color
    @Binding private var selection: Date
    private let displayedComponents: DatePickerComponents

    /// Creates an inline date picker settings row.
    public init(
        title: String,
        icon: String,
        tint: Color,
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
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(tint.opacity(0.14))

                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(tint)
            }
            .frame(width: 36, height: 36)

            DatePicker(
                title,
                selection: $selection,
                displayedComponents: displayedComponents
            )
        }
    }
}
