/*****************************************************************************
 * SFKPrimaryButton.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI

/// A primary action button with glassmorphism effect, loading state, and haptic feedback.
@available(*, unavailable, message: "Use SFKButton(kind: .primary, ...) instead")
public struct SFKPrimaryButton: View {
    private let title: String
    private let systemImage: String?
    private let tint: Color
    private let isEnabled: Bool
    private let isLoading: Bool
    private let action: () -> Void

    public init(
        title: String,
        systemImage: String? = nil,
        tint: Color = .accentColor,
        isEnabled: Bool = true,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.tint = tint
        self.isEnabled = isEnabled
        self.isLoading = isLoading
        self.action = action
    }

    public var body: some View {
        SFKButton(
            kind: .primary,
            title: title,
            systemImage: systemImage,
            tint: tint,
            isEnabled: isEnabled,
            isLoading: isLoading,
            action: action
        )
    }
}

#Preview("Primary Buttons") {
    VStack(spacing: 16) {
        SFKPrimaryButton(
            title: "Add Transaction",
            systemImage: "wand.and.stars",
            tint: .red,
            action: {}
        )

        SFKPrimaryButton(
            title: "Record Transaction",
            tint: .green,
            action: {}
        )

        SFKPrimaryButton(
            title: "Loading...",
            tint: .blue,
            isLoading: true,
            action: {}
        )
    }
    .padding()
    .background(Color.gray.opacity(0.2))
}
