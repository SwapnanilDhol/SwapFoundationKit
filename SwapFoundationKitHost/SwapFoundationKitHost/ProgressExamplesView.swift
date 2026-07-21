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
    @State private var currentStep = 1

    var body: some View {
        ScrollView {
            CatalogExampleGroup(
                title: "Segmented Progress",
                apiNames: ["SFKSegmentedProgress"]
            ) {
                SFKSegmentedProgress(
                    currentStep: currentStep,
                    totalSteps: 4,
                    activeColor: .blue
                )

                Stepper("Step \(currentStep + 1) of 4", value: $currentStep, in: 0...3)
            }
            .padding()
        }
        .navigationTitle("Progress")
    }
}

#Preview {
    NavigationStack {
        ProgressExamplesView()
    }
}
