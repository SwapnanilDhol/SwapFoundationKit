/*****************************************************************************
 * SFKColorPickerSheet.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI

/// A reusable hosted color picker sheet with preset swatches, custom color support,
/// local draft state, and an explicit apply action.
///
/// `SFKColorPickerSheet` is designed for coordinator-owned presentations where the caller
/// wants a complete selection surface rather than a raw `Binding<Color>` control.
public struct SFKColorPickerSheet: View {
    /// Focused presentation options for the color picker.
    public struct Configuration {
        public var pageTitle: String
        public var promptTitle: String?
        public var promptMessage: String?
        public var applyButtonTitle: String
        public var presetColors: [Color]
        public var supportsOpacity: Bool

        public init(
            pageTitle: String = "Choose Color",
            promptTitle: String? = nil,
            promptMessage: String? = nil,
            applyButtonTitle: String = "Apply Color",
            presetColors: [Color] = SFKColorPickerSheet.defaultPresetColors,
            supportsOpacity: Bool = false
        ) {
            self.pageTitle = pageTitle
            self.promptTitle = promptTitle
            self.promptMessage = promptMessage
            self.applyButtonTitle = applyButtonTitle
            self.presetColors = presetColors
            self.supportsOpacity = supportsOpacity
        }
    }

    public static let defaultPresetColors: [Color] = [
        .red, .orange, .yellow, .green, .mint, .teal, .cyan,
        .blue, .indigo, .purple, .pink, .brown, .gray
    ]

    @Environment(\.dismiss) private var dismiss
    @Environment(\.sfkTheme) private var theme
    @StateObject private var viewModel: SFKColorPickerViewModel
    @Binding private var selection: Color
    private let onApply: ((Color) -> Void)?

    private let pageTitle: String
    private let applyButtonTitle: String
    private let supportsOpacity: Bool

    /// Creates a picker backed by a caller-owned color binding.
    public init(
        selection: Binding<Color>,
        configuration: Configuration = .init(),
        onApply: ((Color) -> Void)? = nil
    ) {
        self._selection = selection
        self.onApply = onApply
        self.pageTitle = configuration.pageTitle
        self.applyButtonTitle = configuration.applyButtonTitle
        self.supportsOpacity = configuration.supportsOpacity
        _viewModel = StateObject(wrappedValue: SFKColorPickerViewModel(
            selectedColor: selection.wrappedValue,
            promptTitle: configuration.promptTitle,
            promptMessage: configuration.promptMessage,
            presetColors: configuration.presetColors
        ))
    }

    public var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                VStack {
                    previewCard(in: proxy)
                    
                    Spacer()
                    
                    if let promptTitle = viewModel.promptTitle, !promptTitle.isEmpty {
                        Text(promptTitle)
                            .font(.headline)
                            .multilineTextAlignment(.center)
                    }

                    if let promptMessage = viewModel.promptMessage, !promptMessage.isEmpty {
                        Text(promptMessage)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 4)
                    }
                    
                    Spacer()

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 44), spacing: 14)], spacing: 14) {
                        ForEach(viewModel.presetColors, id: \.self) { color in
                            Button {
                                viewModel.selectPresetColor(color)
                            } label: {
                                swatchView(
                                    color: color,
                                    isSelected: viewModel.selectedColor == color
                                ) {
                                    Circle()
                                        .fill(color)
                                        .frame(width: 38, height: 38)
                                }
                            }
                            .buttonStyle(.plain)
                        }

                        ColorPicker(
                            selection: $viewModel.selectedColor,
                            supportsOpacity: supportsOpacity
                        ) {
                            swatchView(
                                color: viewModel.selectedColor,
                                isSelected: isUsingCustomColor
                            ) {
                                Image(systemName: "paintpalette.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(.primary)
                            }
                        }
                        .labelsHidden()
                        .onChange(of: viewModel.selectedColor) { oldValue, newValue in
                            viewModel.didAdjustCustomColor(oldValue: oldValue, newValue: newValue)
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    SFKButton(applyButtonTitle, role: .primary) {
                        applySelection()
                        dismiss()
                    }
                    .sfkTint(viewModel.selectedColor)
                    .sfkControlSize(.small)
                    .environment(\.sfkTheme, applyButtonTheme)
                    .padding(.horizontal)
                }
                .background(theme.colors.background)
                .navigationTitle(pageTitle)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        SFKCloseButton {
                            dismiss()
                        }
                    }
                }
            }
        }
        .fontDesign(.rounded)
    }

    private func previewCard(in proxy: GeometryProxy) -> some View {
        let heroHeight = min(proxy.size.height * 0.27, 160)
        let outerCircleSize = min(heroHeight * 0.68, 110)
        let innerCircleSize = outerCircleSize * 0.68

        return ZStack {
            viewModel.selectedColor.opacity(0.12)
                .frame(maxWidth: .infinity)
                .ignoresSafeArea(edges: .top)

            ZStack {
                Circle()
                    .fill(viewModel.selectedColor.opacity(0.2))
                    .frame(width: outerCircleSize, height: outerCircleSize)
                    .sfkGlass(
                        material: .regular,
                        tint: viewModel.selectedColor,
                        isInteractive: true,
                        shape: .circle
                    )

                Circle()
                    .fill(viewModel.selectedColor)
                    .frame(width: innerCircleSize, height: innerCircleSize)
                    .sfkGlass(
                        material: .regular,
                        tint: viewModel.selectedColor,
                        isInteractive: true,
                        shape: .circle
                    )
            }
            .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity)
        .frame(height: heroHeight) 
    }

    private var isUsingCustomColor: Bool {
        !viewModel.presetColors.contains(viewModel.selectedColor)
    }

    private var applyButtonTheme: SFKTheme {
        var themed = theme
        themed.colors.accent = viewModel.selectedColor
        themed.colors.onAccent = viewModel.selectedColor.contrastingColor
        return themed
    }

    private func applySelection() {
        viewModel.applySelection()
        selection = viewModel.selectedColor
        onApply?(viewModel.selectedColor)
    }

    private func swatchView<Content: View>(
        color: Color,
        isSelected: Bool,
        @ViewBuilder content: () -> Content
    ) -> some View {
        ZStack {
            content()

            if isSelected {
                Image(systemName: "checkmark")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(color.contrastingColor)
            }
        }
        .frame(width: 44, height: 44)
        .sfkGlass(
            material: .regular,
            tint: color,
            isInteractive: true,
            shape: .circle
        )
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(theme.motion.standard, value: viewModel.selectedColor)
    }
}

#Preview {
    @Previewable @State var color = Color.blue
    VStack { }
    .sheet(isPresented: .constant(true)) {
        SFKColorPickerSheet(
            selection: $color,
            configuration: .init(
                promptTitle: "Choose an account color",
                promptMessage: "Pick a color that makes this account easy to spot."
            )
        )
        .presentationDetents([.fraction(0.7)])
    }
}
