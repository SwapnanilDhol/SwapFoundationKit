/*****************************************************************************
 * SFKCloseButton.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI

/// A reusable close button that renders an `xmark` glyph in a compact,
/// tinted glass-style capsule — designed for navigation bar leading slots
/// inside sheets and full-screen covers.
///
/// Mirrors the standard `Button(action:)` initializer so callers can use
/// either `SFKCloseButton { ... }` or `SFKCloseButton(action: onClose)`.
public struct SFKCloseButton: View {
    private let action: () -> Void

    public init(action: @escaping () -> Void) {
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Image(systemName: "xmark")
                .font(.footnote.weight(.bold))
                .foregroundStyle(.primary)
                .padding(8)
                .background(
                    Circle().fill(Color.white.opacity(0.12))
                )
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Close")
    }
}

// MARK: - Previews

#Preview("SFKCloseButton") {
    VStack(spacing: 16) {
        SFKCloseButton { }
        SFKCloseButton(action: { })
    }
}
