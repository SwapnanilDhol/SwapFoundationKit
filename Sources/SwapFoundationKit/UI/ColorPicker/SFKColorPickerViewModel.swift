/*****************************************************************************
 * SFKColorPickerViewModel.swift
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
final class SFKColorPickerViewModel: ObservableObject {
    @Published var selectedColor: Color

    let promptTitle: String?
    let promptMessage: String?
    let presetColors: [Color]

    private let haptics = HapticsHelper()

    init(
        selectedColor: Color,
        promptTitle: String?,
        promptMessage: String?,
        presetColors: [Color]
    ) {
        self.selectedColor = selectedColor
        self.promptTitle = promptTitle
        self.promptMessage = promptMessage
        self.presetColors = presetColors
    }

    func selectPresetColor(_ color: Color) {
        selectedColor = color
        haptics.lightImpact()
    }

    func didAdjustCustomColor(oldValue: Color, newValue: Color) {
        guard oldValue != newValue, isUsingCustomColor else { return }
        haptics.lightImpact()
    }

    func applySelection() {
        haptics.mediumImpact()
    }

    private var isUsingCustomColor: Bool {
        !presetColors.contains(selectedColor)
    }
}
