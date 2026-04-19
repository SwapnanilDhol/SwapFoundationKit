//
//  SFKPickableItem.swift
//  SwapFoundationKit
//
//  Created by Swapnanil Dhol  on 4/19/26.
//

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
}
