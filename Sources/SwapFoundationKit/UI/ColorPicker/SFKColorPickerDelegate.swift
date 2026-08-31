/*****************************************************************************
 * SFKColorPickerDelegate.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI

@MainActor
@available(*, deprecated, message: "Use SFKColorPickerSheet(selection:configuration:onApply:) instead.")
public protocol SFKColorPickerDelegate: AnyObject {
    func colorPickerDidSelectColor(_ color: Color)
}
