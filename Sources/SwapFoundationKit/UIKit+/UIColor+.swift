/*****************************************************************************
 * UIColor+.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import UIKit
import SwiftUI

// MARK: - UIColor Construction

public extension UIColor {
    /// Returns a color with at least the given minimum saturation.
    func withMinimumSaturation(_ minSaturation: CGFloat) -> UIColor {
        var (hue, saturation, brightness, alpha): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        return saturation < minSaturation
        ? UIColor(hue: hue, saturation: minSaturation, brightness: brightness, alpha: alpha)
        : self
    }

    /// Returns a color with the given alpha.
    func withAlpha(_ value: CGFloat) -> UIColor {
        withAlphaComponent(value)
    }

    /// Returns a random color.
    static func random(
        hue: CGFloat = .random(in: 0...1),
        saturation: CGFloat = .random(in: 0.5...1),
        brightness: CGFloat = .random(in: 0.5...1),
        alpha: CGFloat = 1
    ) -> UIColor {
        UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
    }
}

// MARK: - UIColor Hex & RGB

public extension UIColor {
    /// Returns the hex string for the color.
    func hexString(hashPrefix: Bool = true) -> String {
        var (r, g, b, _): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        getRed(&r, green: &g, blue: &b, alpha: nil)
        let prefix = hashPrefix ? "#" : ""
        return String(format: "\(prefix)%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }

    fileprivate func rgbComponents() -> [CGFloat] {
        var (r, g, b, _): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        getRed(&r, green: &g, blue: &b, alpha: nil)
        return [r, g, b]
    }
}

// MARK: - UIColor Analysis

public extension UIColor {
    var isDark: Bool {
        let rgb = rgbComponents()
        return (0.2126 * rgb[0] + 0.7152 * rgb[1] + 0.0722 * rgb[2]) < 0.5
    }

    var isBlackOrWhite: Bool {
        let rgb = rgbComponents()
        return (rgb[0] > 0.91 && rgb[1] > 0.91 && rgb[2] > 0.91) ||
        (rgb[0] < 0.09 && rgb[1] < 0.09 && rgb[2] < 0.09)
    }

    var isBlack: Bool {
        let rgb = rgbComponents()
        return rgb.allSatisfy { $0 < 0.09 }
    }

    var isWhite: Bool {
        let rgb = rgbComponents()
        return rgb.allSatisfy { $0 > 0.91 }
    }

    func isDistinct(from color: UIColor) -> Bool {
        let bg = rgbComponents()
        let fg = color.rgbComponents()
        let threshold: CGFloat = 0.25

        if zip(bg, fg).contains(where: { abs($0 - $1) > threshold }) {
            if abs(bg[0] - bg[1]) < 0.03 && abs(bg[0] - bg[2]) < 0.03 &&
                abs(fg[0] - fg[1]) < 0.03 && abs(fg[0] - fg[2]) < 0.03 {
                return false
            }
            return true
        }
        return false
    }

    func isContrasting(with color: UIColor) -> Bool {
        let bg = rgbComponents()
        let fg = color.rgbComponents()
        let bgLum = 0.2126 * bg[0] + 0.7152 * bg[1] + 0.0722 * bg[2]
        let fgLum = 0.2126 * fg[0] + 0.7152 * fg[1] + 0.0722 * fg[2]
        let contrast = max((bgLum + 0.05) / (fgLum + 0.05), (fgLum + 0.05) / (bgLum + 0.05))
        return contrast > 1.6
    }

    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
}

// MARK: - Gradient

public extension Array where Element: UIColor {
    func gradient(_ transform: ((inout CAGradientLayer) -> CAGradientLayer)? = nil) -> CAGradientLayer {
        var gradient = CAGradientLayer()
        gradient.colors = self.map { $0.cgColor }
        if let transform = transform {
            gradient = transform(&gradient)
        }
        return gradient
    }
}

// MARK: - Components

public extension UIColor {
    var redComponent: CGFloat {
        var red: CGFloat = 0
        getRed(&red, green: nil, blue: nil, alpha: nil)
        return red
    }
    var greenComponent: CGFloat {
        var green: CGFloat = 0
        getRed(nil, green: &green, blue: nil, alpha: nil)
        return green
    }
    var blueComponent: CGFloat {
        var blue: CGFloat = 0
        getRed(nil, green: nil, blue: &blue, alpha: nil)
        return blue
    }
    var alphaComponent: CGFloat {
        var alpha: CGFloat = 0
        getRed(nil, green: nil, blue: nil, alpha: &alpha)
        return alpha
    }
    var hueComponent: CGFloat {
        var hue: CGFloat = 0
        getHue(&hue, saturation: nil, brightness: nil, alpha: nil)
        return hue
    }
    var saturationComponent: CGFloat {
        var saturation: CGFloat = 0
        getHue(nil, saturation: &saturation, brightness: nil, alpha: nil)
        return saturation
    }
    var brightnessComponent: CGFloat {
        var brightness: CGFloat = 0
        getHue(nil, saturation: nil, brightness: &brightness, alpha: nil)
        return brightness
    }
}

// MARK: - Blending

public extension UIColor {
    func add(hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat) -> UIColor {
        var (oldHue, oldSat, oldBright, oldAlpha): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        getHue(&oldHue, saturation: &oldSat, brightness: &oldBright, alpha: &oldAlpha)
        var newHue = oldHue + hue
        while newHue < 0.0 { newHue += 1.0 }
        while newHue > 1.0 { newHue -= 1.0 }
        let newBright = max(min(oldBright + brightness, 1.0), 0)
        let newSat = max(min(oldSat + saturation, 1.0), 0)
        let newAlpha = max(min(oldAlpha + alpha, 1.0), 0)
        return UIColor(hue: newHue, saturation: newSat, brightness: newBright, alpha: newAlpha)
    }

    func add(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIColor {
        var (oldRed, oldGreen, oldBlue, oldAlpha): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        getRed(&oldRed, green: &oldGreen, blue: &oldBlue, alpha: &oldAlpha)
        let newRed = max(min(oldRed + red, 1.0), 0)
        let newGreen = max(min(oldGreen + green, 1.0), 0)
        let newBlue = max(min(oldBlue + blue, 1.0), 0)
        let newAlpha = max(min(oldAlpha + alpha, 1.0), 0)
        return UIColor(red: newRed, green: newGreen, blue: newBlue, alpha: newAlpha)
    }

    func add(hsb color: UIColor) -> UIColor {
        var (h, s, b, _): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        color.getHue(&h, saturation: &s, brightness: &b, alpha: nil)
        return self.add(hue: h, saturation: s, brightness: b, alpha: 0)
    }

    func add(rgb color: UIColor) -> UIColor {
        self.add(red: color.redComponent, green: color.greenComponent, blue: color.blueComponent, alpha: 0)
    }

    func add(hsba color: UIColor) -> UIColor {
        var (h, s, b, a): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        color.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return self.add(hue: h, saturation: s, brightness: b, alpha: a)
    }

    func add(rgba color: UIColor) -> UIColor {
        self.add(red: color.redComponent, green: color.greenComponent, blue: color.blueComponent, alpha: color.alphaComponent)
    }

    static var random: UIColor {
        UIColor(red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1), alpha: 1.0)
    }

    var contrastingColor: UIColor {
        isDark ? .white : .black
    }

    var color: Color {
        Color(self)
    }
}

// MARK: - SwiftUI Color Interop

@available(iOS 14.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension Color {
    var contrastingColor: Color {
        UIColor(self).isDark ? .white : .black
    }

    var uiColor: UIColor {
        UIColor(self)
    }

    var hex: String {
        uiColor.hexString()
    }

    init(hex: String) {
        self.init(UIColor(hex: hex))
    }
}
