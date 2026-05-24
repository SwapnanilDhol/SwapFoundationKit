/*****************************************************************************
 * SFKPickableItem.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import Foundation
import UIKit

public enum SFKPickableItemIconKind {
    case iconImage(uiImage: UIImage)
    case systemIcon(symbolName: String)
    case text(text: String)
    case none
}

/// Protocol for items that can be displayed and selected in the item picker.
public protocol SFKPickableItem: Identifiable, Hashable {
    var pickableItemId: String { get }
    var pickableItemIconKind: SFKPickableItemIconKind { get }
    var pickableItemTitle: String { get }
    var pickableItemSubtitle: String? { get }
    var pickableItemBadgeTitle: String? { get }
    var pickableItemIconTintColor: UIColor? { get }
}

public extension SFKPickableItem {
    var pickableItemBadgeTitle: String? { nil }
    var pickableItemIconTintColor: UIColor? { nil }
}
