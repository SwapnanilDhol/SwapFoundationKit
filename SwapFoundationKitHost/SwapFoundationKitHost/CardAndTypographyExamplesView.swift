/****************************************************************************
 * CardAndTypographyExamplesView.swift
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

struct CardAndTypographyExamplesView: View {
    @State private var isInspectorPresented = false
    @State private var component = CardAndTypographyComponent.card
    @State private var title = "A focused starting point"
    @State private var bodyText = "Cards and semantic typography keep reusable surfaces visually consistent."
    @State private var showsIcon = true
    @State private var icon = "sparkles"
    @State private var iconTint = Color.purple
    @State private var backgroundFill = Color(.secondarySystemBackground)
    @State private var cornerRadius = 12.0
    @State private var contentPadding = 16.0
    @State private var alignment = CardAlignment.leading
    @State private var typographyStyle = TypographyStyle.flowTitle

    var body: some View {
        CatalogControlPlayground(
            title: "Cards & Typography",
            isInspectorPresented: $isInspectorPresented
        ) {
            CatalogExampleGroup(
                title: "Live Preview",
                apiNames: [component.apiName]
            ) {
                preview
                    .frame(maxWidth: .infinity, minHeight: 120)
            }
        } configuration: {
            Form {
                Section("Component") {
                    Picker("Component", selection: $component) {
                        ForEach(CardAndTypographyComponent.allCases) { component in
                            Text(component.title).tag(component)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Content") {
                    TextField("Title", text: $title)

                    if component == .card {
                        TextField("Body", text: $bodyText, axis: .vertical)
                        Toggle("Icon", isOn: $showsIcon)

                        if showsIcon {
                            TextField("SF Symbol", text: $icon)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                        }
                    }
                }

                appearanceConfiguration
            }
        }
    }

    @ViewBuilder
    private var preview: some View {
        switch component {
        case .card:
            SFKCard(
                cornerRadius: cornerRadius,
                backgroundFill: backgroundFill,
                icon: showsIcon ? icon : nil,
                iconTint: iconTint,
                padding: contentPadding,
                alignment: alignment.value
            ) {
                VStack(alignment: alignment.horizontalAlignment, spacing: 6) {
                    Text(title)
                        .sfkFlowCardTitleStyle()
                    Text(bodyText)
                        .sfkFlowCardBodyStyle()
                }
            }

        case .typography:
            typographyStyle.apply(to: Text(title))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .background(.background, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
    }

    @ViewBuilder
    private var appearanceConfiguration: some View {
        switch component {
        case .card:
            Section("Appearance") {
                ColorPicker("Background", selection: $backgroundFill, supportsOpacity: true)
                ColorPicker("Icon tint", selection: $iconTint, supportsOpacity: true)
                valueSlider("Corner radius", value: $cornerRadius, range: 0...32)
                valueSlider("Content padding", value: $contentPadding, range: 0...32)

                Picker("Alignment", selection: $alignment) {
                    ForEach(CardAlignment.allCases) { alignment in
                        Text(alignment.title).tag(alignment)
                    }
                }
            }

        case .typography:
            Section("Style") {
                Picker("Typography", selection: $typographyStyle) {
                    ForEach(TypographyStyle.allCases) { style in
                        Text(style.title).tag(style)
                    }
                }
            }
        }
    }

    private func valueSlider(
        _ title: String,
        value: Binding<Double>,
        range: ClosedRange<Double>
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            LabeledContent(title, value: value.wrappedValue.formatted(.number.precision(.fractionLength(0))))
            Slider(value: value, in: range, step: 1)
        }
    }
}

private enum CardAndTypographyComponent: String, CaseIterable, Identifiable {
    case card
    case typography

    var id: Self { self }
    var title: String { rawValue.capitalized }

    var apiName: String {
        switch self {
        case .card: "SFKCard"
        case .typography: "SFKTypography"
        }
    }
}

private enum CardAlignment: String, CaseIterable, Identifiable {
    case leading
    case center
    case trailing

    var id: Self { self }
    var title: String { rawValue.capitalized }

    var value: Alignment {
        switch self {
        case .leading: .leading
        case .center: .center
        case .trailing: .trailing
        }
    }

    var horizontalAlignment: HorizontalAlignment {
        switch self {
        case .leading: .leading
        case .center: .center
        case .trailing: .trailing
        }
    }
}

private enum TypographyStyle: String, CaseIterable, Identifiable {
    case flowTitle
    case flowQuestion
    case flowSubtitle
    case cardTitle
    case cardBody
    case chip

    var id: Self { self }

    var title: String {
        switch self {
        case .flowTitle: "Flow Title"
        case .flowQuestion: "Flow Question"
        case .flowSubtitle: "Flow Subtitle"
        case .cardTitle: "Card Title"
        case .cardBody: "Card Body"
        case .chip: "Chip"
        }
    }

    @ViewBuilder
    func apply(to text: Text) -> some View {
        switch self {
        case .flowTitle: text.sfkFlowTitleStyle()
        case .flowQuestion: text.sfkFlowQuestionStyle()
        case .flowSubtitle: text.sfkFlowSubtitleStyle()
        case .cardTitle: text.sfkFlowCardTitleStyle()
        case .cardBody: text.sfkFlowCardBodyStyle()
        case .chip: text.sfkFlowChipStyle()
        }
    }
}

#Preview {
    NavigationStack {
        CardAndTypographyExamplesView()
    }
}
