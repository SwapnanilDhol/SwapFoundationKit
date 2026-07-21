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

/// A reusable toolbar control that renders an `xmark` glyph by default.
///
/// Use ``SFKCloseButtonChrome/toolbar`` (default) inside navigation toolbars,
/// and ``SFKCloseButtonChrome/glass`` when the control sits over content
/// without system toolbar chrome.
/// Override `systemImage` and `accessibilityLabel` when the same standardized
/// icon-only treatment represents navigation, such as a back button.
///
/// Mirrors the standard `Button(action:)` initializer so callers can use
/// either `SFKCloseButton { ... }` or `SFKCloseButton(action: onClose)`.
public struct SFKCloseButton: View {
    private let title: String?
    private let systemImage: String
    private let accessibilityLabel: LocalizedStringKey
    private let chrome: SFKCloseButtonChrome
    private let foreground: Color
    private let action: () -> Void

    public init(
        systemImage: String = "xmark",
        accessibilityLabel: LocalizedStringKey = "Close",
        chrome: SFKCloseButtonChrome = .toolbar,
        foreground: Color = .primary,
        action: @escaping () -> Void
    ) {
        self.title = nil
        self.systemImage = systemImage
        self.accessibilityLabel = accessibilityLabel
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
        self.systemImage = "xmark"
        self.accessibilityLabel = "Close"
        self.chrome = chrome
        self.foreground = foreground
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            buttonLabel
        }
        .modifier(CloseButtonStyleModifier(chrome: chrome))
        .modifier(CloseChromeModifier(chrome: chrome, isLabeled: title != nil))
        .accessibilityLabel(accessibilityLabel)
    }

    @ViewBuilder
    private var buttonLabel: some View {
        if let title {
            if #available(iOS 26, *) {
                labeledContent(title)
            } else {
                labeledContent(title)
                    .frame(height: hitSize)
                    .padding(.horizontal, 12)
                    .fixedSize(horizontal: true, vertical: false)
                    .contentShape(Capsule())
            }
        } else {
            switch chrome {
            case .toolbar:
                Image(systemName: systemImage)
                    .font(iconFont)
                    .foregroundStyle(foreground)
            case .glass:
                if #available(iOS 26, *) {
                    Image(systemName: systemImage)
                        .font(iconFont)
                        .foregroundStyle(foreground)
                } else {
                    Image(systemName: systemImage)
                        .font(iconFont)
                        .foregroundStyle(foreground)
                        .frame(width: hitSize, height: hitSize)
                        .contentShape(Circle())
                }
            }
        }
    }

    private func labeledContent(_ title: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "xmark")
                .font(iconFont)

            Text(title)
                .font(.footnote.weight(.semibold))
        }
        .foregroundStyle(foreground)
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
            if #available(iOS 26, *) {
                content.buttonStyle(.glass)
            } else {
                content.buttonStyle(.plain)
            }
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
            if #available(iOS 26, *) {
                if isLabeled {
                    content
                        .buttonBorderShape(.capsule)
                } else {
                    content
                        .buttonBorderShape(.circle)
                }
            } else {
                if isLabeled {
                    content
                        .background(Color.primary.opacity(0.10), in: Capsule())
                        .overlay {
                            Capsule()
                                .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
                        }
                } else {
                    content
                        .background(Color.primary.opacity(0.10), in: Circle())
                }
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
                SFKCloseButton(
                    systemImage: "chevron.left",
                    accessibilityLabel: "Back",
                    chrome: .toolbar
                ) { }
                Text("back")
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

#Preview("SFKCloseButton in Toolbar") {
    NavigationStack {
        Text("Content")
            .navigationTitle("Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    SFKCloseButton {}
                }
            }
    }
}
