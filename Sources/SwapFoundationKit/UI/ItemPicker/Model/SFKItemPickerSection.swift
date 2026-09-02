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

/// A titled group of items rendered as a `Section` inside `SFKItemPickerView`.
public struct SFKItemPickerSection<Item: SFKPickableItem>: Identifiable {
    public let id: String
    public let title: String
    public let items: [Item]

    public init(id: String, title: String, items: [Item]) {
        self.id = id
        self.title = title
        self.items = items
    }
}
