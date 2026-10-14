/****************************************************************************
 * SFKOnboardingBrandMarkIcon.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI

/// An image drawn as a rounded app icon with a hairline highlight, used by
/// ``SFKOnboardingBrandMark/init(image:size:shadowTint:)``.
public struct SFKOnboardingBrandMarkIcon: View {
    private let image: Image
    private let size: CGFloat

    /// - Parameters:
    ///   - image: The brand image.
    ///   - size: The icon's side length.
    public init(image: Image, size: CGFloat) {
        self.image = image
        self.size = size
    }

    public var body: some View {
        image
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: size * 0.25, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: size * 0.25, style: .continuous)
                    .stroke(Color.white.opacity(0.22), lineWidth: 1)
            }
    }
}

#Preview {
    SFKOnboardingBrandMarkIcon(image: Image(systemName: "leaf.fill"), size: 132)
}
