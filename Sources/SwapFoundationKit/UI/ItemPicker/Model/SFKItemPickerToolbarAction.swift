/*****************************************************************************
 * SFKItemPickerToolbarAction.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import Foundation

public enum SFKItemPickerToolbarActionPlacement: Equatable, Sendable {
    case topBarLeading
    case topBarTrailing
}

public struct SFKItemPickerToolbarAction: Identifiable {
    public let id: String
    public let title: String?
    public let systemImage: String
    public let placement: SFKItemPickerToolbarActionPlacement
    public let action: () -> Void

    public init(
        id: String? = nil,
        title: String? = nil,
        systemImage: String,
        placement: SFKItemPickerToolbarActionPlacement = .topBarTrailing,
        action: @escaping () -> Void
    ) {
        self.id = id ?? "\(title ?? "")-\(systemImage)-\(placement)"
        self.title = title
        self.systemImage = systemImage
        self.placement = placement
        self.action = action
    }
}
