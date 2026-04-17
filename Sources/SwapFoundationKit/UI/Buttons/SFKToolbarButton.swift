/*****************************************************************************
 * SFKToolbarButton.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI

/// A toolbar button with custom label support and haptic feedback.
@available(*, unavailable, message: "Use SFKButton(kind: .toolbar, ...) instead")
public struct SFKToolbarButton<Label: View>: View {
    private let isEnabled: Bool
    private let action: () -> Void
    private let chromeTint: Color
    @ViewBuilder private let label: () -> Label

    public init(
        isEnabled: Bool = true,
        tint: Color = .secondary,
        action: @escaping () -> Void,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.isEnabled = isEnabled
        self.action = action
        self.chromeTint = tint
        self.label = label
    }

    public var body: some View {
        SFKButton(
            kind: .toolbar,
            tint: chromeTint,
            isEnabled: isEnabled,
            action: action
        ) {
            label()
                .padding(.horizontal, 4)
                .padding(.vertical, 4)
        }
    }

    /// Convenience initializer for simple toolbar buttons with title/image.
    public init(
        title: String? = nil,
        systemImage: String? = nil,
        tint: Color = .primary,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) where Label == SFKToolbarButtonLabel {
        self.isEnabled = isEnabled
        self.action = action
        self.chromeTint = tint
        self.label = {
            SFKToolbarButtonLabel(
                title: title,
                systemImage: systemImage,
                tint: tint,
                isEnabled: isEnabled
            )
        }
    }
}

/// Label view for SFKToolbarButton.
@available(*, unavailable, message: "Internal — do not use")
public struct SFKToolbarButtonLabel: View {
    private let title: String?
    private let systemImage: String?
    private let isEnabled: Bool

    public init(
        title: String? = nil,
        systemImage: String? = nil,
        tint: Color = .primary,
        isEnabled: Bool = true
    ) {
        self.title = title
        self.systemImage = systemImage
        self.isEnabled = isEnabled
    }

    public var body: some View {
        Group {
            if let title, let systemImage {
                HStack(spacing: 6) {
                    Image(systemName: systemImage)
                        .font(.footnote.weight(.bold))
                    Text(title)
                        .font(.footnote.weight(.semibold))
                        .lineLimit(1)
                }
            } else if let title {
                Text(title)
                    .font(.footnote.weight(.semibold))
                    .lineLimit(1)
            } else if let systemImage {
                Image(systemName: systemImage)
                    .font(.headline.weight(.semibold))
            }
        }
        .foregroundStyle(isEnabled ? SFKButtonVisualTokens.current.toolbarForegroundColor : .secondary)
        .fixedSize(horizontal: true, vertical: false)
    }
}

#Preview("Toolbar Buttons In Navigation Bar") {
    NavigationStack {
        List {
            Text("Toolbar buttons should be previewed in a navigation bar context.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .navigationTitle("Button Demo")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                SFKToolbarButton(systemImage: "plus", tint: .orange, action: {})
            }
            ToolbarItem(placement: .topBarTrailing) {
                SFKToolbarButton(title: "Edit", tint: .blue, action: {})
            }
            ToolbarItem(placement: .topBarTrailing) {
                SFKToolbarButton(
                    title: "Done",
                    systemImage: "checkmark",
                    tint: .green,
                    isEnabled: false,
                    action: {}
                )
            }
        }
    }
}
