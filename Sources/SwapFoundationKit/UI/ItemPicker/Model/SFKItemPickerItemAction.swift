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

public enum SFKItemPickerItemActionPresentation: Equatable, Sendable {
    case contextMenu
    case swipe
}

public struct SFKItemPickerItemAction: Identifiable {
    public let id: String
    public let title: String
    public let systemImage: String
    public let role: ButtonRole?
    public let presentation: SFKItemPickerItemActionPresentation
    public let action: () -> Void

    public init(
        id: String? = nil,
        title: String,
        systemImage: String,
        role: ButtonRole? = nil,
        presentation: SFKItemPickerItemActionPresentation,
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
