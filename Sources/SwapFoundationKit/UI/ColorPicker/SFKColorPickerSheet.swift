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
    public static let defaultPresetColors: [Color] = [
        .red, .orange, .yellow, .green, .mint, .teal, .cyan,
        .blue, .indigo, .purple, .pink, .brown, .gray
    ]

    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: SFKColorPickerViewModel

    private let pageTitle: String
    private let applyButtonTitle: String
    private let supportsOpacity: Bool

    public init(
        selectedColor: Color,
        pageTitle: String = "Choose Color",
        promptTitle: String? = nil,
        promptMessage: String? = nil,
        applyButtonTitle: String = "Apply Color",
        presetColors: [Color] = SFKColorPickerSheet.defaultPresetColors,
        supportsOpacity: Bool = false,
        delegate: SFKColorPickerDelegate? = nil
    ) {
        _viewModel = StateObject(wrappedValue: SFKColorPickerViewModel(
            selectedColor: selectedColor,
            promptTitle: promptTitle,
            promptMessage: promptMessage,
            presetColors: presetColors,
            delegate: delegate
        ))
        self.pageTitle = pageTitle
        self.applyButtonTitle = applyButtonTitle
        self.supportsOpacity = supportsOpacity
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
                    
                    SFKButton(
                        applyButtonTitle,
                        titleColor: viewModel.selectedColor.isDark ? .white : .black,
                        color: viewModel.selectedColor,
                        verticalPadding: 8
                    ) {
                        applySelection()
                        dismiss()
                    }
                    .padding(.horizontal)
                }
                .background(Color(.systemGroupedBackground))
                .navigationTitle(pageTitle)
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(.hidden, for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        SFKButton(
                            "Close".localized,
                            leadingIconName: "xmark",
                            fullWidth: false,
                            titleColor: .primary,
                            subtitleColor: .secondary,
                            color: .white.opacity(0.12),
                            spacing: 8,
                            horizontalPadding: 12,
                            verticalPadding: 5,
                            titleFont: .footnote.weight(.semibold),
                            subtitleFont: .caption2,
                            iconFont: .footnote.weight(.bold)
                        ) {
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
                        color: viewModel.selectedColor,
                        isInteractive: true,
                        shape: .circle
                    )

                Circle()
                    .fill(viewModel.selectedColor)
                    .frame(width: innerCircleSize, height: innerCircleSize)
                    .sfkGlass(
                        color: viewModel.selectedColor,
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

    private func applySelection() {
        viewModel.applySelection()
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
                    .foregroundStyle(color.isDark ? Color.white : Color.black)
            }
        }
        .frame(width: 44, height: 44)
        .sfkGlass(
            color: color,
            isInteractive: true,
            shape: .circle
        )
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.selectedColor)
    }
}

#Preview {
    VStack { }
    .sheet(isPresented: .constant(true)) {
        SFKColorPickerSheet(
            selectedColor: .blue,
            promptTitle: "Choose an account color",
            promptMessage: "Pick a color that makes this account easy to spot."
        )
        .presentationDetents([.fraction(0.7)])
    }
}
