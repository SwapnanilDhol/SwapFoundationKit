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
    private let title: String?
    private let chrome: SFKCloseButtonChrome
    private let foreground: Color
    private let action: () -> Void

    public init(
        chrome: SFKCloseButtonChrome = .toolbar,
        foreground: Color = .primary,
        action: @escaping () -> Void
    ) {
        self.title = nil
        self.chrome = chrome
        self.foreground = foreground
        self.action = action
    }

    /// Creates a close button with a visible text label.
    ///
    /// Use `.glass` for a self-contained capsule over custom or full-bleed
    /// content. The default `.toolbar` chrome lets the navigation bar own the
    /// surrounding treatment.
    public init(
        _ title: String,
        chrome: SFKCloseButtonChrome = .toolbar,
        foreground: Color = .primary,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.chrome = chrome
        self.foreground = foreground
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: "xmark")
                    .font(iconFont)

                if let title {
                    Text(title)
                        .font(.footnote.weight(.semibold))
                }
            }
                .foregroundStyle(foreground)
                .frame(width: title == nil ? hitSize : nil, height: hitSize)
                .padding(.horizontal, title == nil ? 0 : 12)
                .fixedSize(horizontal: title != nil, vertical: false)
                .contentShape(Capsule())
        }
        .modifier(CloseButtonStyleModifier(chrome: chrome))
        .modifier(CloseChromeModifier(chrome: chrome, isLabeled: title != nil))
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

private struct CloseButtonStyleModifier: ViewModifier {
    let chrome: SFKCloseButtonChrome

    @ViewBuilder
    func body(content: Content) -> some View {
        switch chrome {
        case .toolbar:
            // Preserve the navigation bar's native button style. On iOS 26+
            // this is what supplies the system Liquid Glass capsule.
            content
        case .glass:
            // Freeform glass owns its entire chrome and must not inherit a
            // surrounding container's button treatment.
            content.buttonStyle(.plain)
        }
    }
}

private struct CloseChromeModifier: ViewModifier {
    let chrome: SFKCloseButtonChrome
    let isLabeled: Bool

    @ViewBuilder
    func body(content: Content) -> some View {
        switch chrome {
        case .toolbar:
            content
        case .glass:
            if isLabeled {
                content
                    .background(Color.primary.opacity(0.10), in: Capsule())
                    .sfkGlass(
                        color: Color.primary.opacity(0.12),
                        style: .regular,
                        isInteractive: true,
                        shape: .capsule
                    )
                    .overlay {
                        Capsule()
                            .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
                    }
            } else {
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
                SFKCloseButton("Close", chrome: .glass, foreground: .white) { }
                Text("labeled glass")
                    .foregroundStyle(.white)
            }
            HStack(spacing: 16) {
                SFKCloseButton(chrome: .glass, foreground: .white) { }
                Text("glass")
                    .foregroundStyle(.white)
            }
        }
    }
}
