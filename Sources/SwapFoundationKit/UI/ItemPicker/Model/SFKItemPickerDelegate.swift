/*****************************************************************************
 * SFKItemPickerDelegate.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import Foundation

/// Delegate for receiving selection callbacks from `SFKItemPickerView`.
///
/// `didSelectItem` fires on every tap (useful for haptics/analytics).
/// `didUpdateSelection` fires with the full updated array (for syncing caller state).
///
/// ## Usage
/// ```swift
/// class MyPickerDelegate: SFKItemPickerDelegate {
///     func itemPicker(_ picker: SFKItemPickerViewModel, didSelectItem item: any SFKPickableItem) {
///         hapticsHelper.mediumImpact()
///     }
///
///     func itemPicker(_ picker: SFKItemPickerViewModel, didUpdateSelection selectedItems: [any SFKPickableItem]) {
///         self.selectedCurrencies = selectedItems
///     }
/// }
/// ```
public protocol SFKItemPickerDelegate: AnyObject {
    /// Called when an item is selected or toggled.
    func itemPicker(_ picker: SFKItemPickerViewModel, didSelectItem item: any SFKPickableItem)
    /// Called when the selection array is updated.
    func itemPicker(_ picker: SFKItemPickerViewModel, didUpdateSelection selectedItems: [any SFKPickableItem])
}
