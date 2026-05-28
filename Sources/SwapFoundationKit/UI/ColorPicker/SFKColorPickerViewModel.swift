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

    weak var delegate: SFKColorPickerDelegate?

    let promptTitle: String?
    let promptMessage: String?
    let presetColors: [Color]

    private let haptics = HapticsHelper()

    init(
        selectedColor: Color,
        promptTitle: String?,
        promptMessage: String?,
        presetColors: [Color],
        delegate: SFKColorPickerDelegate?
    ) {
        self.selectedColor = selectedColor
        self.promptTitle = promptTitle
        self.promptMessage = promptMessage
        self.presetColors = presetColors
        self.delegate = delegate
    }

    func selectPresetColor(_ color: Color) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            selectedColor = color
        }
        haptics.lightImpact()
    }

    func didAdjustCustomColor(oldValue: Color, newValue: Color) {
        guard oldValue != newValue, isUsingCustomColor else { return }
        haptics.lightImpact()
    }

    func applySelection() {
        delegate?.colorPickerDidSelectColor(selectedColor)
        haptics.mediumImpact()
    }

    private var isUsingCustomColor: Bool {
        !presetColors.contains(selectedColor)
    }
}
