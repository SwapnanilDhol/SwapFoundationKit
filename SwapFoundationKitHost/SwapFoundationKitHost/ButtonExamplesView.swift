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

    @State private var closeChrome = CloseChrome.toolbar
    @State private var closeForeground = Color.primary
    @State private var tapCount = 0

    var body: some View {
        CatalogControlPlayground(
            title: "Buttons",
            isInspectorPresented: $isInspectorPresented,
            inspectorToolbarPlacement: .topBarLeading
        ) {
            VStack(spacing: 28) {
                livePreview
                allVariations
                closeButtonNavigationBar
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
            apiNames: [
                "SFKButton",
                "SFKCompactButton",
                "SFKCompactButtonChrome",
                "SFKCompactButtonType"
            ]
        ) {
            VStack(spacing: 12) {
                SFKButton("Primary", role: .primary) {}
                    .sfkIcon("sparkles")
                SFKButton("Secondary", role: .secondary) {}
                    .sfkIcon("doc.text")
                SFKButton("Skip", role: .borderless) {}
                    .sfkFullWidth(false)
                SFKButton("Delete", role: .destructive) {}
                    .sfkIcon("trash")

                HStack(spacing: 20) {
                    VStack(spacing: 6) {
                        SFKCompactButton(
                            systemImage: "ellipsis",
                            accessibilityLabel: "More",
                            chrome: .toolbar
                        ) {}
                        Text("Toolbar")
                    }

                    VStack(spacing: 6) {
                        SFKCompactButton(
                            systemImage: "ellipsis",
                            accessibilityLabel: "More"
                        ) {}
                        Text("Glass icon")
                    }

                    VStack(spacing: 6) {
                        SFKCompactButton("Edit") {}
                        Text("Text only")
                    }

                    VStack(spacing: 6) {
                        SFKCompactButton("Edit", systemImage: "pencil") {}
                        Text("Icon + text")
                    }
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)

                HStack(spacing: 20) {
                    VStack(spacing: 6) {
                        SFKCompactButton(type: .close, chrome: .toolbar) {}
                        Text("Close toolbar")
                    }

                    VStack(spacing: 6) {
                        SFKCompactButton(type: .close, chrome: .glass) {}
                        Text("Close glass")
                    }
                }
                .font(.caption2)
                .foregroundStyle(.secondary)

                Text("Use SFKCompactButton for lightweight toolbar or overlay actions. The .close type supplies the X symbol and Close accessibility label.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding(16)
            .background(.background, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
    }

    private var closeButtonNavigationBar: some View {
        CatalogExampleGroup(
            title: "Close Button in a Navigation Bar",
            apiNames: ["SFKCompactButton", "SFKCompactButtonType", "ToolbarItem"]
        ) {
            CloseButtonNavigationBarExample()
                .frame(height: 220)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
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
        SFKButton(resolvedTitle ?? "", role: style.value) {
            tapCount += 1
        }
        .sfkIcon(resolvedLeadingIcon)
        .sfkSubtitle(resolvedSubtitle)
        .sfkLoading(isLoading)
        .sfkFullWidth(fullWidth)
        .sfkTint(tint)
        .sfkControlSize(controlSize.value)
        .sfkAlignment(textAlignment.value)
        .disabled(!isEnabled)
    }

    @ViewBuilder
    private var closeButton: some View {
        SFKCompactButton(
            type: .close,
            chrome: closeChrome.value,
            foreground: closeForeground
        ) {
            tapCount += 1
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
        }
    }

    @ViewBuilder
    private var closeButtonConfiguration: some View {
        Section("Content") {
            Text("The close type uses the X symbol and Close accessibility label.")
                .font(.footnote)
                .foregroundStyle(.secondary)
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
        case .close: "SFKCompactButton (.close)"
        }
    }
}

private enum ButtonStyleOption: String, CaseIterable, Identifiable {
    case primary
    case secondary
    case borderless

    var id: Self { self }
    var title: String { rawValue.capitalized }

    var value: SFKButtonStyle {
        switch self {
        case .primary: .primary
        case .secondary: .secondary
        case .borderless: .borderless
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

private enum ButtonTextAlignment: String, CaseIterable, Identifiable {
    case leading
    case center
    case trailing

    var id: Self { self }
    var title: String { rawValue.capitalized }

    var value: SFKButtonAlignment {
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

    var value: SFKCompactButtonChrome {
        switch self {
        case .toolbar: .toolbar
        case .glass: .glass
        }
    }
}

private struct CloseButtonNavigationBarExample: View {
    @State private var closeTapCount = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Image(systemName: "doc.text")
                    .font(.title)
                    .foregroundStyle(.tint)

                Text("Details screen")
                    .font(.headline)

                Text(
                    closeTapCount == 0
                        ? "Tap the X in the navigation bar to close."
                        : "Close action fired \(closeTapCount)x."
                )
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            .navigationTitle("Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    SFKCompactButton(type: .close, chrome: .toolbar) {
                        closeTapCount += 1
                    }
                }
            }
        }
        .background(Color(.systemBackground))
    }
}

#Preview {
    NavigationStack {
        ButtonExamplesView()
    }
}
