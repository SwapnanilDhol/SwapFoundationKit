/*****************************************************************************
 * TopAuraBackground.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI

public struct TopAuraBackground: View {
    public let baseColor: Color
    public let glowColor: Color
    public let secondaryGlowColor: Color
    public let primaryOpacity: Double
    public let secondaryOpacity: Double
    public let primaryHeight: CGFloat
    public let secondaryHeight: CGFloat
    public let startRadius: CGFloat
    public let endRadius: CGFloat
    public let primaryBlurRadius: CGFloat
    public let secondaryBlurRadius: CGFloat
    public let verticalOffset: CGFloat

    public init(
        baseColor: Color = Color(.systemGroupedBackground),
        glowColor: Color = Color(red: 0.24, green: 0.56, blue: 1.0),
        secondaryGlowColor: Color = Color.cyan.opacity(0.7),
        primaryOpacity: Double = 0.34,
        secondaryOpacity: Double = 0.18,
        primaryHeight: CGFloat = 380,
        secondaryHeight: CGFloat = 220,
        startRadius: CGFloat = 24,
        endRadius: CGFloat = 360,
        primaryBlurRadius: CGFloat = 18,
        secondaryBlurRadius: CGFloat = 12,
        verticalOffset: CGFloat = -92
    ) {
        self.baseColor = baseColor
        self.glowColor = glowColor
        self.secondaryGlowColor = secondaryGlowColor
        self.primaryOpacity = primaryOpacity
        self.secondaryOpacity = secondaryOpacity
        self.primaryHeight = primaryHeight
        self.secondaryHeight = secondaryHeight
        self.startRadius = startRadius
        self.endRadius = endRadius
        self.primaryBlurRadius = primaryBlurRadius
        self.secondaryBlurRadius = secondaryBlurRadius
        self.verticalOffset = verticalOffset
    }

    public var body: some View {
        ZStack(alignment: .top) {
            baseColor

            RadialGradient(
                colors: [
                    glowColor.opacity(primaryOpacity),
                    secondaryGlowColor.opacity(secondaryOpacity),
                    Color.clear
                ],
                center: .top,
                startRadius: startRadius,
                endRadius: endRadius
            )
            .frame(height: primaryHeight)
            .blur(radius: primaryBlurRadius)
            .offset(y: verticalOffset)

            LinearGradient(
                colors: [
                    glowColor.opacity(primaryOpacity * 0.35),
                    Color.clear
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: secondaryHeight)
            .blur(radius: secondaryBlurRadius)
        }
        .ignoresSafeArea()
    }
}
