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
    var pickableItemTrailingAccessory: SFKPickableItemTrailingAccessory { get }
}

public enum SFKPickableItemTrailingAccessory: Equatable {
    case none
    case disclosureIndicator
    case checkmark
    case custom(iconName: String)
}

public extension SFKPickableItem {
    var pickableItemBadgeTitle: String? { nil }
    var pickableItemIconTintColor: UIColor? { nil }
    var pickableItemTrailingAccessory: SFKPickableItemTrailingAccessory { .none }
}
