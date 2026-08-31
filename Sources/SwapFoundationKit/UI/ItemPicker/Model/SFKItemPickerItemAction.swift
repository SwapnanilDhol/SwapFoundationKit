/*****************************************************************************
 * SFKItemPickerItemAction.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI

public struct SFKItemPickerItemAction: Identifiable {
    public enum Presentation: Equatable, Sendable {
        case contextMenu
        case swipe
    }

    public let id: String
    public let title: String
    public let systemImage: String
    public let role: ButtonRole?
    public let presentation: Presentation
    public let action: () -> Void

    public init(
        id: String? = nil,
        title: String,
        systemImage: String,
        role: ButtonRole? = nil,
        presentation: Presentation,
        action: @escaping () -> Void
    ) {
        self.id = id ?? "\(title)-\(systemImage)-\(presentation)"
        self.title = title
        self.systemImage = systemImage
        self.role = role
        self.presentation = presentation
        self.action = action
    }
}
