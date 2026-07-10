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

/// Visual treatment for `SFKCloseButton`.
public enum SFKCloseButtonChrome: Sendable {
    /// Icon-only — for toolbar / nav-bar slots where Liquid Glass already
    /// wraps the control. A second circle reads as button-in-button.
    case toolbar

    /// Circular glass capsule — for freeform chrome over content
    /// (full-bleed previews, camera overlays, custom top bars).
    case glass
}

/// A reusable close button that renders an `xmark` glyph.
///
/// Use ``SFKCloseButtonChrome/toolbar`` (default) inside navigation toolbars,
/// and ``SFKCloseButtonChrome/glass`` when the control sits over content
/// without system toolbar chrome.
///
/// Mirrors the standard `Button(action:)` initializer so callers can use
/// either `SFKCloseButton { ... }` or `SFKCloseButton(action: onClose)`.
public struct SFKCloseButton: View {
    private let chrome: SFKCloseButtonChrome
    private let action: () -> Void

    public init(
        chrome: SFKCloseButtonChrome = .toolbar,
        action: @escaping () -> Void
    ) {
        self.chrome = chrome
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Image(systemName: "xmark")
                .font(iconFont)
                .foregroundStyle(.primary)
                .frame(width: hitSize, height: hitSize)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .modifier(CloseChromeModifier(chrome: chrome))
        .accessibilityLabel("Close")
    }

    private var hitSize: CGFloat {
        switch chrome {
        case .toolbar: return 30
        case .glass: return 40
        }
    }

    private var iconFont: Font {
        switch chrome {
        case .toolbar: return .footnote.weight(.bold)
        case .glass: return .body.weight(.semibold)
        }
    }
}

// MARK: - Chrome

private struct CloseChromeModifier: ViewModifier {
    let chrome: SFKCloseButtonChrome

    @ViewBuilder
    func body(content: Content) -> some View {
        switch chrome {
        case .toolbar:
            content
        case .glass:
            content
                .sfkGlass(
                    color: Color.primary.opacity(0.08),
                    style: .regular,
                    isInteractive: true,
                    shape: .circle
                )
        }
    }
}

// MARK: - Previews

#Preview("SFKCloseButton") {
    ZStack {
        LinearGradient(
            colors: [.orange, .pink, .purple],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        VStack(spacing: 24) {
            HStack(spacing: 16) {
                SFKCloseButton(chrome: .toolbar) { }
                Text("toolbar")
                    .foregroundStyle(.white)
            }
            HStack(spacing: 16) {
                SFKCloseButton(chrome: .glass) { }
                Text("glass")
                    .foregroundStyle(.white)
            }
        }
    }
}
