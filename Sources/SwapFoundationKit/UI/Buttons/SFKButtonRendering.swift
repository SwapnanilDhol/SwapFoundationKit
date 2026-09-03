/****************************************************************************
 * SFKButtonRendering.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

/// Pure mapping from the public semantic role to its platform rendering.
internal enum SFKButtonRendering {
    static func role(
        for style: SFKButtonStyle,
        supportsGlass: Bool
    ) -> SFKButtonRenderingRole {
        switch style {
        case .primary, .destructive:
            supportsGlass ? .glassProminent : .borderedProminent
        case .secondary:
            supportsGlass ? .glass : .bordered
        case .borderless:
            .plain
        }
    }
}
