/*****************************************************************************
 * SFKItemPickerEmptyState.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import Foundation

/// Drives the `ContentUnavailableView` `SFKItemPickerView` renders when its
/// picker has no items at all (not to be confused with an empty *search*
/// result, which the picker handles on its own via `ContentUnavailableView.search`).
public struct SFKItemPickerEmptyState {
    public let title: String
    public let systemImage: String
    public let description: String?
    public let actionTitle: String?
    public let action: (() -> Void)?

    public init(
        title: String,
        systemImage: String = "tray",
        description: String? = nil,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.systemImage = systemImage
        self.description = description
        self.actionTitle = actionTitle
        self.action = action
    }
}
