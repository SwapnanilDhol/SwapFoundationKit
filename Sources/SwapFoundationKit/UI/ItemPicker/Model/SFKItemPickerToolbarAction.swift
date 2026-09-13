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

public struct SFKItemPickerToolbarAction: Identifiable {
    public enum Placement: Equatable, Sendable {
        case topBarLeading
        case topBarTrailing
    }

    public let id: String
    public let title: String?
    public let systemImage: String
    public let accessibilityLabel: String?
    public let placement: Placement
    public let action: () -> Void

    public init(
        id: String? = nil,
        title: String? = nil,
        systemImage: String,
        accessibilityLabel: String? = nil,
        placement: Placement = .topBarTrailing,
        action: @escaping () -> Void
    ) {
        self.id = id ?? "\(title ?? accessibilityLabel ?? "")-\(systemImage)-\(placement)"
        self.title = title
        self.systemImage = systemImage
        self.accessibilityLabel = accessibilityLabel
        self.placement = placement
        self.action = action
    }
}
