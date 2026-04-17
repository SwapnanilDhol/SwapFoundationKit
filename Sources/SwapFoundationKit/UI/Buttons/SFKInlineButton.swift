/*****************************************************************************
 * SFKInlineButton.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI

/// An inline action button for compact UI contexts.
@available(*, unavailable, message: "Use SFKButton(kind: .inline, ...) instead")
public struct SFKInlineButton: View {
    public enum InlineStyle {
        case filled
        case plain
    }

    private let title: String
    private let systemImage: String?
    private let style: InlineStyle
    private let tint: Color
    private let isEnabled: Bool
    private let action: () -> Void

    public init(
        title: String,
        systemImage: String? = nil,
        style: InlineStyle = .filled,
        tint: Color = .accentColor,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.style = style
        self.tint = tint
        self.isEnabled = isEnabled
        self.action = action
    }

    public var body: some View {
        SFKButton(
            kind: style == .filled ? .inline : .inlinePlain,
            title: title,
            systemImage: systemImage,
            tint: tint,
            isEnabled: isEnabled,
            action: action
        )
    }
}
