//
//  SFKSettingsStepperRow.swift
//  SwapFoundationKit
//
//  Created by Swapnanil Dhol on 4/4/26.
//

import SwiftUI

/// A settings row with a Stepper for numeric value adjustment.
///
/// ## Usage
/// ```swift
/// @State private var numberOfAlerts = 3
///
/// SFKSettingsStepperRow(
///     title: "Number of Alerts",
///     subtitle: "How many times to remind",
///     icon: "bell.badge",
///     tint: .red,
///     value: $numberOfAlerts,
///     range: 1...10,
///     step: 1
/// )
/// ```
public struct SFKSettingsStepperRow: View {

    private let title: String
    private let subtitle: String
    private let icon: String
    private let tint: Color
    @Binding private var value: Int
    private let range: ClosedRange<Int>
    private let step: Int
    private let displayValue: ((Int) -> String)?

    /// Creates a stepper settings row.
    /// - Parameters:
    ///   - title: Primary text label.
    ///   - subtitle: Secondary text label.
    ///   - icon: SF Symbol name for the icon.
    ///   - tint: Tint color for the icon background and icon.
    ///   - value: Binding to the numeric value.
    ///   - range: The valid range for the value.
    ///   - step: The increment/decrement step size.
    ///   - displayValue: Optional closure to format the displayed value.
    public init(
        title: String,
        subtitle: String,
        icon: String,
        tint: Color,
        value: Binding<Int>,
        range: ClosedRange<Int>,
        step: Int = 1,
        displayValue: ((Int) -> String)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.tint = tint
        self._value = value
        self.range = range
        self.step = step
        self.displayValue = displayValue
    }

    public var body: some View {
        HStack(spacing: 14) {
            iconContainer

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.primary)

                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            HStack(spacing: 8) {
                if let displayValue = displayValue {
                    Text(displayValue(value))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }

                Stepper(
                    "",
                    value: $value,
                    in: range,
                    step: step
                )
                .labelsHidden()
            }
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
}

/// A settings row with a Slider for continuous value adjustment.
///
/// ## Usage
/// ```swift
/// @State private var opacity: Double = 0.5
///
/// SFKSettingsSliderRow(
///     title: "Image Opacity",
///     subtitle: "Adjust transparency",
///     icon: "circle.lefthalf.filled",
///     tint: .blue,
///     value: $opacity,
///     range: 0...1
/// )
/// ```
public struct SFKSettingsSliderRow: View {

    private let title: String
    private let subtitle: String
    private let icon: String
    private let tint: Color
    @Binding private var value: Double
    private let range: ClosedRange<Double>
    private let step: Double
    private let displayValue: ((Double) -> String)?

    /// Creates a slider settings row.
    /// - Parameters:
    ///   - title: Primary text label.
    ///   - subtitle: Secondary text label.
    ///   - icon: SF Symbol name for the icon.
    ///   - tint: Tint color for the icon background and icon.
    ///   - value: Binding to the slider value.
    ///   - range: The valid range for the value.
    ///   - step: Optional step size for discrete values.
    ///   - displayValue: Optional closure to format the displayed value.
    public init(
        title: String,
        subtitle: String,
        icon: String,
        tint: Color,
        value: Binding<Double>,
        range: ClosedRange<Double>,
        step: Double = 0.01,
        displayValue: ((Double) -> String)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.tint = tint
        self._value = value
        self.range = range
        self.step = step
        self.displayValue = displayValue
    }

    public var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 14) {
                iconContainer

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.primary)

                    Text(subtitle)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Spacer()

                if let displayValue = displayValue {
                    Text(displayValue(value))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
            }

            Slider(value: $value, in: range, step: step)
                .tint(tint)
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
}


// MARK: - Previews

#Preview("SFKSettingsStepperRow") {
    @Previewable @State var count = 5

    List {
        SFKSettingsStepperRow(
            title: "Alert Count",
            subtitle: "How many times to remind",
            icon: "bell.badge",
            tint: .red,
            value: $count,
            range: 1...10,
            step: 1,
            displayValue: { "\($0) times" }
        )
        SFKSettingsStepperRow(
            title: "Volume",
            subtitle: "Notification volume",
            icon: "speaker.wave.3.fill",
            tint: .blue,
            value: $count,
            range: 0...100,
            step: 5,
            displayValue: { "\($0)%" }
        )
    }
}

#Preview("SFKSettingsSliderRow") {
    @Previewable @State var opacity: Double = 0.75

    List {
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
