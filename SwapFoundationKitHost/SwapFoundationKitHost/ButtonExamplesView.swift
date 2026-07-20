/*****************************************************************************
 * ButtonExamplesView.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI

struct ButtonExamplesView: View {
    var body: some View {
        List {
            ForEach(ButtonCategory.allCases) { category in
                Section {
                    NavigationLink(value: category) {
                        ButtonCategoryRow(category: category)
                    }
                } footer: {
                    Text(category.guidance)
                }
            }
        }
        .navigationTitle("Buttons")
        .navigationDestination(for: ButtonCategory.self) { category in
            switch category {
            case .primary:
                PrimaryButtonExamplesView()
            case .secondary:
                SecondaryButtonExamplesView()
            case .toolbar:
                ToolbarButtonExamplesView()
            }
        }
    }
}

private enum ButtonCategory: String, CaseIterable, Identifiable, Hashable {
    case primary
    case secondary
    case toolbar

    var id: Self { self }

    var title: String {
        switch self {
        case .primary: "Primary"
        case .secondary: "Secondary"
        case .toolbar: "Toolbar"
        }
    }

    var summary: String {
        switch self {
        case .primary: "The single strongest action on a screen."
        case .secondary: "A supporting action with quieter emphasis."
        case .toolbar: "Compact navigation and dismissal actions."
        }
    }

    var guidance: String {
        switch self {
        case .primary: "Use once per screen for the action that completes the user’s task."
        case .secondary: "Use for optional or reversible actions that should not compete with the primary action."
        case .toolbar: "Use inside a navigation toolbar and let the system provide its surrounding chrome."
        }
    }

    var symbolName: String {
        switch self {
        case .primary: "capsule.fill"
        case .secondary: "capsule"
        case .toolbar: "rectangle.topthird.inset.filled"
        }
    }

    var tint: Color {
        switch self {
        case .primary: .blue
        case .secondary: .indigo
        case .toolbar: .gray
        }
    }
}

private struct ButtonCategoryRow: View {
    let category: ButtonCategory

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: category.symbolName)
                .font(.body.weight(.semibold))
                .foregroundStyle(category.tint)
                .frame(width: 36, height: 36)
                .background(category.tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(category.title)
                    .font(.body.weight(.semibold))
                Text(category.summary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 3)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    NavigationStack {
        ButtonExamplesView()
    }
}
