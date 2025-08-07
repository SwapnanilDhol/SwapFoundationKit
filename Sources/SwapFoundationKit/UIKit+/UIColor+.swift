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

import Foundation

#if canImport(UIKit) && os(iOS)
import UIKit
#endif

#if canImport(QuartzCore) && os(iOS)
import QuartzCore
#endif

#if canImport(SwiftUI)
import SwiftUI
#endif

#if canImport(UIKit) && os(iOS)
public extension UIColor {
    /// Creates a color from a hex string.
    /// - Parameter hex: The hex string (e.g., "#FF0000" or "FF0000").
    /// - Returns: A UIColor instance, or nil if the hex string is invalid.
    convenience init?(hex: String) {
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
            return nil
        }
        
        self.init(
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            alpha: Double(a) / 255
        )
    }
    
    /// Returns the hex string representation of the color.
    /// - Parameter includeAlpha: Whether to include the alpha component in the hex string.
    /// - Returns: The hex string representation.
    func hexString(includeAlpha: Bool = false) -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        if includeAlpha {
            return String(format: "#%02X%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255), Int(a * 255))
        } else {
            return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
        }
    }
    
    /// Creates a color with adjusted brightness.
    /// - Parameter amount: The amount to adjust the brightness by (-1.0 to 1.0).
    /// - Returns: A new UIColor with adjusted brightness.
    func adjusted(brightness amount: CGFloat) -> UIColor {
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        
        let newBrightness = max(0, min(1, b + amount))
        return UIColor(hue: h, saturation: s, brightness: newBrightness, alpha: a)
    }
    
    /// Creates a color with adjusted saturation.
    /// - Parameter amount: The amount to adjust the saturation by (-1.0 to 1.0).
    /// - Returns: A new UIColor with adjusted saturation.
    func adjusted(saturation amount: CGFloat) -> UIColor {
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        
        let newSaturation = max(0, min(1, s + amount))
        return UIColor(hue: h, saturation: newSaturation, brightness: b, alpha: a)
    }
    
    /// Creates a color with adjusted hue.
    /// - Parameter amount: The amount to adjust the hue by (-1.0 to 1.0).
    /// - Returns: A new UIColor with adjusted hue.
    func adjusted(hue amount: CGFloat) -> UIColor {
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        
        let newHue = (h + amount).truncatingRemainder(dividingBy: 1.0)
        return UIColor(hue: newHue, saturation: s, brightness: b, alpha: a)
    }
    
    /// Creates a color with adjusted alpha.
    /// - Parameter amount: The amount to adjust the alpha by (-1.0 to 1.0).
    /// - Returns: A new UIColor with adjusted alpha.
    func adjusted(alpha amount: CGFloat) -> UIColor {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let newAlpha = max(0, min(1, a + amount))
        return UIColor(red: r, green: g, blue: b, alpha: newAlpha)
    }
    
    /// Creates a gradient layer with the current color.
    /// - Parameter transform: An optional closure to transform the gradient layer.
    /// - Returns: A CAGradientLayer with the current color.
    #if canImport(QuartzCore) && os(iOS)
    func gradient(_ transform: ((inout CAGradientLayer) -> CAGradientLayer)? = nil) -> CAGradientLayer {
        var gradientLayer = CAGradientLayer()
        gradientLayer.colors = [self.cgColor, self.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        
        if let transform = transform {
            gradientLayer = transform(&gradientLayer)
        }
        
        return gradientLayer
    }
    #endif
    
    /// Creates a gradient layer between two colors.
    /// - Parameters:
    ///   - otherColor: The other color for the gradient.
    ///   - transform: An optional closure to transform the gradient layer.
    /// - Returns: A CAGradientLayer with the gradient between the two colors.
    #if canImport(QuartzCore) && os(iOS)
    func gradient(to otherColor: UIColor, _ transform: ((inout CAGradientLayer) -> CAGradientLayer)? = nil) -> CAGradientLayer {
        var gradientLayer = CAGradientLayer()
        gradientLayer.colors = [self.cgColor, otherColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        
        if let transform = transform {
            gradientLayer = transform(&gradientLayer)
        }
        
        return gradientLayer
    }
    #endif
}
#endif

// MARK: - UIColor Analysis

#if canImport(UIKit) && os(iOS)
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

    /// Returns the RGB components as an array [red, green, blue].
    /// - Returns: An array of CGFloat values representing red, green, and blue components.
    func rgbComponents() -> [CGFloat] {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return [red, green, blue]
    }
}
#endif

// MARK: - Components

#if canImport(UIKit) && os(iOS)
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
#endif

// MARK: - Blending

#if canImport(UIKit) && os(iOS)
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

    #if canImport(SwiftUI)
    var color: Color {
        Color(self)
    }
    #endif
}
#endif

// MARK: - SwiftUI Color Interop

#if canImport(SwiftUI) && canImport(UIKit) && os(iOS)
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
#endif
