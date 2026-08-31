/****************************************************************************
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

/// Source-compatible alias for the compact button's visual treatment.
///
/// New generic controls should use ``SFKCompactButtonChrome``. This alias
/// remains available so existing close-button call sites keep compiling.
public typealias SFKCloseButtonChrome = SFKCompactButtonChrome

/// A close-specific convenience wrapper around ``SFKCompactButton``.
///
/// The wrapper keeps the familiar X and Close accessibility defaults. Use
/// ``SFKCompactButton`` when the action is back, edit, more, or another
/// lightweight toolbar or overlay action.
public struct SFKCloseButton: View {
    private let title: String?
    private let systemImage: String
    private let accessibilityLabel: LocalizedStringKey
    private let chrome: SFKCompactButtonChrome
    private let foreground: Color?
    private let action: () -> Void

    /// Creates an icon-only close button.
    ///
    /// Custom symbols and accessibility labels are preserved for existing
    /// back, dismiss, and other navigation uses.
    public init(
        systemImage: String = "xmark",
        accessibilityLabel: LocalizedStringKey = "Close",
        chrome: SFKCloseButtonChrome = .toolbar,
        foreground: Color? = nil,
        action: @escaping () -> Void
    ) {
        self.title = nil
        self.systemImage = systemImage
        self.accessibilityLabel = accessibilityLabel
        self.chrome = chrome
        self.foreground = foreground
        self.action = action
    }

    /// Creates a labeled close button with an X icon.
    public init(
        _ title: String,
        chrome: SFKCloseButtonChrome = .toolbar,
        foreground: Color? = nil,
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
        if let title {
            SFKCompactButton(
                title,
                systemImage: systemImage,
                chrome: chrome,
                foreground: foreground,
                action: action
            )
            .accessibilityLabel(accessibilityLabel)
        } else {
            SFKCompactButton(
                systemImage: systemImage,
                accessibilityLabel: accessibilityLabel,
                chrome: chrome,
                foreground: foreground,
                action: action
            )
        }
    }
}

// MARK: - Previews

#Preview("SFKCloseButton") {
    NavigationStack {
        Text("Content")
            .navigationTitle("Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    SFKCloseButton { }
                }
            }
    }
}
