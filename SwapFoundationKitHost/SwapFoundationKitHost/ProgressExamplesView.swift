/****************************************************************************
 * ProgressExamplesView.swift
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

struct ProgressExamplesView: View {
    @State private var isInspectorPresented = false
    @State private var currentStep = 1
    @State private var totalSteps = 4
    @State private var activeColor = Color.blue
    @State private var inactiveColor = Color.gray.opacity(0.25)
    @State private var height = 6.0
    @State private var spacing = 6.0

    var body: some View {
        CatalogControlPlayground(
            title: "Progress",
            isInspectorPresented: $isInspectorPresented
        ) {
            CatalogExampleGroup(
                title: "Live Preview",
                apiNames: ["SFKSegmentedProgress"]
            ) {
                VStack(spacing: 20) {
                    SFKSegmentedProgress(
                        currentStep: currentStep,
                        totalSteps: totalSteps,
                        activeColor: activeColor,
                        inactiveColor: inactiveColor,
                        height: height,
                        spacing: spacing
                    )

                    Text("Step \(currentStep + 1) of \(totalSteps)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                .padding(20)
                .background(.background, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
        } configuration: {
            Form {
                Section("Progress") {
                    Stepper("Total steps: \(totalSteps)", value: $totalSteps, in: 1...12)
                    Stepper("Current step: \(currentStep + 1)", value: $currentStep, in: 0...max(0, totalSteps - 1))
                }

                Section("Appearance") {
                    ColorPicker("Active color", selection: $activeColor, supportsOpacity: true)
                    ColorPicker("Inactive color", selection: $inactiveColor, supportsOpacity: true)
                    valueSlider("Height", value: $height, range: 2...16)
                    valueSlider("Spacing", value: $spacing, range: 0...20)
                }
            }
        }
        .onChange(of: totalSteps) { _, newValue in
            currentStep = min(currentStep, newValue - 1)
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

#Preview {
    NavigationStack {
        ProgressExamplesView()
    }
}
