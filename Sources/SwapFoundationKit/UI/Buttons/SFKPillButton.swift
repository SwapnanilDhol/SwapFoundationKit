/*****************************************************************************
 * SFKPillButton.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI

/// A pill/capsule style button with glass effect.
@available(*, unavailable, message: "Use SFKButton(kind: .pill, ...) instead")
public struct SFKPillButton: View {
    public enum PillStyle {
        case glass
        case toolbar
    }

    private let title: String
    private let systemImage: String?
    private let pillStyle: PillStyle
    private let tint: Color
    private let isEnabled: Bool
    private let action: () -> Void

    public init(
        title: String,
        systemImage: String? = nil,
        pillStyle: PillStyle = .glass,
        tint: Color = .secondary,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.pillStyle = pillStyle
        self.tint = tint
        self.isEnabled = isEnabled
        self.action = action
    }

    public var body: some View {
        SFKButton(
            kind: pillStyle == .glass ? .pill : .toolbar,
            title: title,
            systemImage: systemImage,
            tint: tint,
            isEnabled: isEnabled,
            action: action
        )
    }
}

/// A close/dismiss pill button.
@available(*, unavailable, message: "Use SFKButton(kind: .close, title: \"\", ...) instead")
public struct SFKClosePillButton: View {
    public enum CloseStyle {
        case glass
        case toolbar
    }

    private let style: CloseStyle
    private let action: () -> Void

    public init(
        style: CloseStyle = .glass,
        action: @escaping () -> Void
    ) {
        self.style = style
        self.action = action
    }

    public var body: some View {
        SFKButton(
            kind: style == .glass ? .close : .toolbar,
            title: "",
            systemImage: "xmark",
            tint: .secondary,
            action: action
        )
    }
}

#Preview("Pill Buttons") {
    VStack(spacing: 16) {
        SFKPillButton(title: "Close", systemImage: "xmark", action: {})
        SFKPillButton(title: "Approve", systemImage: "checkmark", tint: .green, action: {})
        SFKClosePillButton(action: {})
    }
    .padding()
    .background(Color.gray.opacity(0.2))
}

#Preview("Toolbar Pills In Navigation Bar") {
    NavigationStack {
        List {
            Text("Pill button variants in a toolbar context.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .navigationTitle("Pill Buttons")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                SFKClosePillButton(style: .toolbar, action: {})
            }
            ToolbarItem(placement: .topBarTrailing) {
                SFKPillButton(
                    title: "Filters",
                    systemImage: "line.3.horizontal.decrease.circle",
                    pillStyle: .toolbar,
                    tint: .blue,
                    action: {}
                )
            }
        }
    }
}
