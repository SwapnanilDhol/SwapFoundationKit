/****************************************************************************
 * ButtonExamplesView.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwapFoundationKit
import SwiftUI

struct ButtonExamplesView: View {
    @State private var isInspectorPresented = false
    @State private var component = ButtonComponent.standard

    @State private var title = "Continue"
    @State private var showsTitle = true
    @State private var subtitle = "Review your details"
    @State private var showsSubtitle = false
    @State private var leadingIconName = "arrow.right"
    @State private var showsLeadingIcon = true
    @State private var isEnabled = true
    @State private var isLoading = false
    @State private var fullWidth = true
    @State private var style = ButtonStyleOption.primary
    @State private var tint = Color.blue
    @State private var usesCustomTitleColor = false
    @State private var titleColor = Color.white
    @State private var usesCustomSubtitleColor = false
    @State private var subtitleColor = Color.white.opacity(0.8)
    @State private var spacing = 8.0
    @State private var horizontalPadding = 16.0
    @State private var verticalPadding = 9.0
    @State private var titleFont = FontOption.bodySemibold
    @State private var subtitleFont = FontOption.subheadline
    @State private var iconFont = FontOption.bodySemibold
    @State private var textAlignment = ButtonTextAlignment.center
    @State private var titleLineLimit = 1
    @State private var subtitleLineLimit = 1
    @State private var controlSize = ButtonControlSize.regular
    @State private var hapticStyle = ButtonHaptic.medium

    @State private var closeShowsTitle = false
    @State private var closeTitle = "Close"
    @State private var closeChrome = CloseChrome.toolbar
    @State private var closeForeground = Color.primary
    @State private var tapCount = 0

    var body: some View {
        CatalogControlPlayground(
            title: "Buttons",
            isInspectorPresented: $isInspectorPresented
        ) {
            VStack(spacing: 28) {
                livePreview
                allVariations
            }
        } configuration: {
            Form {
                componentPicker

                switch component {
                case .standard:
                    standardButtonConfiguration
                case .close:
                    closeButtonConfiguration
                }
            }
        }
    }

    private var allVariations: some View {
        CatalogExampleGroup(
            title: "All Variations",
            apiNames: ["SFKButton", "SFKCloseButton"]
        ) {
            VStack(spacing: 12) {
                SFKButton("Primary", leadingIconName: "sparkles", style: .primary) {}
                SFKButton("Secondary", leadingIconName: "doc.text", style: .secondary) {}

                HStack(spacing: 20) {
                    SFKButton(leadingIconName: "ellipsis", fullWidth: false, style: .toolbar) {}
                        .accessibilityLabel("Toolbar button")
                    SFKCloseButton {}
                    SFKCloseButton(chrome: .glass) {}
                    SFKCloseButton("Close", chrome: .glass) {}
                }
                .frame(maxWidth: .infinity)
            }
            .padding(16)
            .background(.background, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
    }

    private var componentPicker: some View {
        Section("Playground") {
            Picker("Component", selection: $component) {
                ForEach(ButtonComponent.allCases) { component in
                    Text(component.title).tag(component)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    private var livePreview: some View {
        CatalogExampleGroup(
            title: "Live Preview",
            apiNames: [component.title]
        ) {
            VStack(spacing: 18) {
                Group {
                    switch component {
                    case .standard:
                        standardButton
                    case .close:
                        closeButton
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 56)

                Divider()
                LabeledContent("Taps", value: tapCount.formatted())
            }
            .padding(16)
            .background(.background, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
    }

    private var standardButton: some View {
        SFKButton(
            resolvedTitle,
            leadingIconName: resolvedLeadingIcon,
            subtitle: resolvedSubtitle,
            isLoading: isLoading,
            fullWidth: fullWidth,
            titleColor: usesCustomTitleColor ? titleColor : nil,
            subtitleColor: usesCustomSubtitleColor ? subtitleColor : nil,
            color: tint,
            spacing: spacing,
            horizontalPadding: horizontalPadding,
            verticalPadding: verticalPadding,
            titleFont: titleFont.value,
            subtitleFont: subtitleFont.value,
            iconFont: iconFont.value,
            textAlignment: textAlignment.value,
            titleLineLimit: titleLineLimit,
            subtitleLineLimit: subtitleLineLimit,
            controlSize: controlSize.value,
            style: style.value,
            hapticStyle: hapticStyle.value
        ) {
            tapCount += 1
        }
        .disabled(!isEnabled)
    }

    @ViewBuilder
    private var closeButton: some View {
        if closeShowsTitle {
            SFKCloseButton(
                closeTitle,
                chrome: closeChrome.value,
                foreground: closeForeground
            ) {
                tapCount += 1
            }
        } else {
            SFKCloseButton(
                chrome: closeChrome.value,
                foreground: closeForeground
            ) {
                tapCount += 1
            }
        }
    }

    @ViewBuilder
    private var standardButtonConfiguration: some View {
        Section("Content") {
            Toggle("Title", isOn: $showsTitle)
            if showsTitle {
                TextField("Title", text: $title)
            }

            Toggle("Subtitle", isOn: $showsSubtitle)
            if showsSubtitle {
                TextField("Subtitle", text: $subtitle)
            }

            Toggle("Leading icon", isOn: $showsLeadingIcon)
            if showsLeadingIcon {
                TextField("SF Symbol", text: $leadingIconName)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }
        }

        Section("Style") {
            Picker("Variation", selection: $style) {
                ForEach(ButtonStyleOption.allCases) { style in
                    Text(style.title).tag(style)
                }
            }
            .pickerStyle(.segmented)

            Picker("Control size", selection: $controlSize) {
                ForEach(ButtonControlSize.allCases) { size in
                    Text(size.title).tag(size)
                }
            }

            Toggle("Full width", isOn: $fullWidth)
            ColorPicker("Tint", selection: $tint, supportsOpacity: true)

            Toggle("Custom title color", isOn: $usesCustomTitleColor)
            if usesCustomTitleColor {
                ColorPicker("Title color", selection: $titleColor, supportsOpacity: true)
            }

            Toggle("Custom subtitle color", isOn: $usesCustomSubtitleColor)
            if usesCustomSubtitleColor {
                ColorPicker("Subtitle color", selection: $subtitleColor, supportsOpacity: true)
            }
        }

        Section("Layout") {
            numericSlider("Content spacing", value: $spacing, range: 0...24)
            numericSlider("Horizontal padding", value: $horizontalPadding, range: 0...32)
            numericSlider("Vertical padding", value: $verticalPadding, range: 0...24)

            Picker("Text alignment", selection: $textAlignment) {
                ForEach(ButtonTextAlignment.allCases) { alignment in
                    Text(alignment.title).tag(alignment)
                }
            }

            Stepper("Title line limit: \(titleLineLimit)", value: $titleLineLimit, in: 1...5)
            Stepper("Subtitle line limit: \(subtitleLineLimit)", value: $subtitleLineLimit, in: 1...5)
        }

        Section("Typography") {
            fontPicker("Title font", selection: $titleFont)
            fontPicker("Subtitle font", selection: $subtitleFont)
            fontPicker("Icon font", selection: $iconFont)
        }

        Section("Interaction") {
            Toggle("Enabled", isOn: $isEnabled)
            Toggle("Loading", isOn: $isLoading)

            Picker("Haptic", selection: $hapticStyle) {
                ForEach(ButtonHaptic.allCases) { haptic in
                    Text(haptic.title).tag(haptic)
                }
            }
        }
    }

    @ViewBuilder
    private var closeButtonConfiguration: some View {
        Section("Content") {
            Toggle("Text label", isOn: $closeShowsTitle)
            if closeShowsTitle {
                TextField("Title", text: $closeTitle)
            }
        }

        Section("Style") {
            Picker("Chrome", selection: $closeChrome) {
                ForEach(CloseChrome.allCases) { chrome in
                    Text(chrome.title).tag(chrome)
                }
            }
            .pickerStyle(.segmented)

            ColorPicker("Foreground", selection: $closeForeground, supportsOpacity: true)
        }
    }

    private func numericSlider(
        _ title: String,
        value: Binding<Double>,
        range: ClosedRange<Double>
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            LabeledContent(title, value: value.wrappedValue.formatted(.number.precision(.fractionLength(0))))
            Slider(value: value, in: range, step: 1)
        }
    }

    private func fontPicker(_ title: String, selection: Binding<FontOption>) -> some View {
        Picker(title, selection: selection) {
            ForEach(FontOption.allCases) { font in
                Text(font.title).tag(font)
            }
        }
    }

    private var resolvedTitle: String? {
        showsTitle ? nonempty(title) : nil
    }

    private var resolvedSubtitle: String? {
        showsSubtitle ? nonempty(subtitle) : nil
    }

    private var resolvedLeadingIcon: String? {
        showsLeadingIcon ? nonempty(leadingIconName) : nil
    }

    private func nonempty(_ value: String) -> String? {
        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedValue.isEmpty ? nil : trimmedValue
    }
}

private enum ButtonComponent: String, CaseIterable, Identifiable {
    case standard
    case close

    var id: Self { self }

    var title: String {
        switch self {
        case .standard: "SFKButton"
        case .close: "Close"
        }
    }
}

private enum ButtonStyleOption: String, CaseIterable, Identifiable {
    case primary
    case secondary
    case toolbar

    var id: Self { self }
    var title: String { rawValue.capitalized }

    var value: SFKButtonStyle {
        switch self {
        case .primary: .primary
        case .secondary: .secondary
        case .toolbar: .toolbar
        }
    }
}

private enum ButtonControlSize: String, CaseIterable, Identifiable {
    case mini
    case small
    case regular
    case large
    case extraLarge

    var id: Self { self }

    var title: String {
        switch self {
        case .mini: "Mini"
        case .small: "Small"
        case .regular: "Regular"
        case .large: "Large"
        case .extraLarge: "Extra Large"
        }
    }

    var value: ControlSize {
        switch self {
        case .mini: .mini
        case .small: .small
        case .regular: .regular
        case .large: .large
        case .extraLarge: .extraLarge
        }
    }
}

private enum ButtonHaptic: String, CaseIterable, Identifiable {
    case none
    case light
    case medium
    case heavy

    var id: Self { self }
    var title: String { rawValue.capitalized }

    var value: SFKButtonHapticStyle? {
        switch self {
        case .none: nil
        case .light: .light
        case .medium: .medium
        case .heavy: .heavy
        }
    }
}

private enum ButtonTextAlignment: String, CaseIterable, Identifiable {
    case leading
    case center
    case trailing

    var id: Self { self }
    var title: String { rawValue.capitalized }

    var value: HorizontalAlignment {
        switch self {
        case .leading: .leading
        case .center: .center
        case .trailing: .trailing
        }
    }
}

private enum FontOption: String, CaseIterable, Identifiable {
    case caption
    case footnote
    case subheadline
    case body
    case bodySemibold
    case headline
    case title3

    var id: Self { self }

    var title: String {
        switch self {
        case .caption: "Caption"
        case .footnote: "Footnote"
        case .subheadline: "Subheadline"
        case .body: "Body"
        case .bodySemibold: "Body Semibold"
        case .headline: "Headline"
        case .title3: "Title 3"
        }
    }

    var value: Font {
        switch self {
        case .caption: .caption
        case .footnote: .footnote
        case .subheadline: .subheadline
        case .body: .body
        case .bodySemibold: .body.weight(.semibold)
        case .headline: .headline
        case .title3: .title3
        }
    }
}

private enum CloseChrome: String, CaseIterable, Identifiable {
    case toolbar
    case glass

    var id: Self { self }
    var title: String { rawValue.capitalized }

    var value: SFKCloseButtonChrome {
        switch self {
        case .toolbar: .toolbar
        case .glass: .glass
        }
    }
}

#Preview {
    NavigationStack {
        ButtonExamplesView()
    }
}
