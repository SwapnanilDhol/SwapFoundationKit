/*****************************************************************************
 * SFKItemPickerSection.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import Foundation

public struct SFKItemPickerSection: Identifiable {
    public let id: String
    public let title: String?
    public let footer: String?
    public let items: [any SFKPickableItem]

    public init(
        id: String? = nil,
        title: String? = nil,
        footer: String? = nil,
        items: [any SFKPickableItem]
    ) {
        self.id = id ?? title ?? UUID().uuidString
        self.title = title
        self.footer = footer
        self.items = items
    }
}
