/*****************************************************************************
 * SFKSecondaryButton.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI

/// A secondary action button with card-like surface styling.
public struct SFKSecondaryButton: View {
    private let title: String
    private let systemImage: String?
    private let tint: Color
    private let isEnabled: Bool
    private let action: () -> Void

    public init(
        title: String,
        systemImage: String? = nil,
        tint: Color = .primary,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.tint = tint
        self.isEnabled = isEnabled
        self.action = action
    }

    public var body: some View {
        SFKButton(
            kind: .secondary,
            title: title,
            systemImage: systemImage,
            tint: tint,
            isEnabled: isEnabled,
            action: action
        )
    }
}

#Preview("Secondary Buttons") {
    VStack(spacing: 16) {
        SFKSecondaryButton(title: "Cancel", action: {})
        SFKSecondaryButton(title: "Disabled", isEnabled: false, action: {})
    }
    .padding()
    .background(Color.gray.opacity(0.2))
}
