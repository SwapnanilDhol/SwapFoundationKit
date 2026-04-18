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

/// Delegate protocol for item picker selection events.
public protocol SFKItemPickerDelegate: AnyObject {
    /// Called when the user selects an item in single-select mode.
    func itemPicker(_ picker: SFKItemPickerViewModel, didSelectItem item: any SFKPickableItem)
    /// Called when the user confirms a multi-select selection.
    func itemPicker(_ picker: SFKItemPickerViewModel, didConfirmSelection items: [any SFKPickableItem])
    /// Called when the picker is dismissed without making a selection.
    func itemPickerDidDismiss(_ picker: SFKItemPickerViewModel)
}