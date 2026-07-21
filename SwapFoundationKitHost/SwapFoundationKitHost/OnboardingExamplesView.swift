/*****************************************************************************
 * OnboardingExamplesView.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI
import SwapFoundationKit

struct OnboardingExamplesView: View {
    @State private var selectedGoals: Set<Goal> = [.save]
    @State private var currentStep = 1

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                CatalogExampleGroup(
                    title: "Progress",
                    apiNames: ["SFKSegmentedProgress"]
                ) {
                    SFKSegmentedProgress(currentStep: currentStep, totalSteps: 4, activeColor: .blue)

                    Stepper("Step \(currentStep + 1) of 4", value: $currentStep, in: 0...3)
                }

                CatalogExampleGroup(
                    title: "Compact Selectable Chips",
                    apiNames: ["SFKChipFlowLayout", "SFKSelectableChip", "SFKChipItem"]
                ) {
                    SFKChipFlowLayout(spacing: 8) {
                        ForEach(Goal.allCases) { goal in
                            SFKSelectableChip(
                                item: goal,
                                isSelected: selectedGoals.contains(goal),
                                tintColor: .blue,
                                controlSize: .small
                            ) {
                                toggle(goal)
                            }
                        }
                    }
                }

                CatalogExampleGroup(
                    title: "Cards & Typography",
                    apiNames: ["SFKCard", "SFKTypography"]
                ) {
                    SFKCard(icon: "sparkles", iconTint: .purple) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("A focused starting point")
                                .sfkFlowCardTitleStyle()
                            Text("Cards and semantic typography keep onboarding screens visually consistent.")
                                .sfkFlowCardBodyStyle()
                        }
                    }
                }

                CatalogExampleGroup(
                    title: "Secondary Action",
                    apiNames: ["SFKButton"]
                ) {
                    SFKButton(
                        "Skip for now",
                        fullWidth: false,
                        titleColor: .secondary,
                        color: .clear,
                        style: .toolbar
                    ) {}
                }
            }
            .padding()
        }
        .navigationTitle("Onboarding")
    }

    private func toggle(_ goal: Goal) {
        if selectedGoals.contains(goal) {
            selectedGoals.remove(goal)
        } else {
            selectedGoals.insert(goal)
        }
    }
}

private enum Goal: String, CaseIterable, Identifiable, SFKChipItem {
    case track = "Track spending"
    case save = "Save more"
    case plan = "Plan ahead"
    case simplify = "Simplify finances"

    var id: Self { self }
    var chipLabel: String { rawValue }
    var chipIcon: String? {
        switch self {
        case .track: "chart.bar.fill"
        case .save: "banknote.fill"
        case .plan: "calendar"
        case .simplify: "wand.and.stars"
        }
    }
}

#Preview {
    NavigationStack {
        OnboardingExamplesView()
    }
}
