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

// MARK: - RGBA Components

/// Represents color components as a structured type instead of an array.
public struct RGBAColorComponents {
    public let red: CGFloat
    public let green: CGFloat
    public let blue: CGFloat
    public let alpha: CGFloat

    @inlinable public init(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat = 1.0) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

    public var luminance: CGFloat {
        0.2126 * red + 0.7152 * green + 0.0722 * blue
    }

    public var rgb: [CGFloat] { [red, green, blue] }
}

public extension UIColor {

    // MARK: - Hex Initialization

    public convenience init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        guard Scanner(string: hex).scanHexInt64(&int) else {
            return nil
        }

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
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }

    // MARK: - Hex Output

    func hexString(includeAlpha: Bool = false) -> String {
        let components = rgba
        if includeAlpha {
            return String(format: "#%02X%02X%02X%02X",
                Int(components.red * 255), Int(components.green * 255),
                Int(components.blue * 255), Int(components.alpha * 255))
        }
        return String(format: "#%02X%02X%02X",
            Int(components.red * 255), Int(components.green * 255), Int(components.blue * 255))
    }

    var hex: String { hexString() }

    // MARK: - Component Extraction

    /// Returns all RGBA components in a structured type.
    var rgba: RGBAColorComponents {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return RGBAColorComponents(red: red, green: green, blue: blue, alpha: alpha)
    }

    /// Returns RGB components as [red, green, blue] (legacy compatibility).
    func rgbComponents() -> [CGFloat] { rgba.rgb }

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

    // MARK: - Color Analysis

    var isDark: Bool { rgba.luminance < 0.5 }

    var isBlackOrWhite: Bool {
        let rgb = rgba.rgb
        return (rgb[0] > 0.91 && rgb[1] > 0.91 && rgb[2] > 0.91) ||
               (rgb[0] < 0.09 && rgb[1] < 0.09 && rgb[2] < 0.09)
    }

    var isBlack: Bool { rgba.rgb.allSatisfy { $0 < 0.09 } }
    var isWhite: Bool { rgba.rgb.allSatisfy { $0 > 0.91 } }

    var contrastingColor: UIColor { isDark ? .white : .black }

    func isDistinct(from color: UIColor) -> Bool {
        let bg = rgba.rgb
        let fg = color.rgba.rgb
        let threshold: CGFloat = 0.25

        guard zip(bg, fg).contains(where: { abs($0 - $1) > threshold }) else {
            return false
        }

        let bgFlat = abs(bg[0] - bg[1]) < 0.03 && abs(bg[0] - bg[2]) < 0.03
        let fgFlat = abs(fg[0] - fg[1]) < 0.03 && abs(fg[0] - fg[2]) < 0.03
        return !(bgFlat && fgFlat)
    }

    func isContrasting(with color: UIColor) -> Bool {
        let bgLum = rgba.luminance
        let fgLum = color.rgba.luminance
        let contrast = max((bgLum + 0.05) / (fgLum + 0.05), (fgLum + 0.05) / (bgLum + 0.05))
        return contrast > 1.6
    }

    // MARK: - Color Adjustment

    /// Adjustment type for color manipulation.
    enum Adjustment {
        case brightness(CGFloat)
        case saturation(CGFloat)
        case hue(CGFloat)
        case alpha(CGFloat)

        var clamped: (hue: CGFloat, sat: CGFloat, bright: CGFloat, alpha: CGFloat) {
            switch self {
            case .brightness(let v): return (0, 0, v, 0)
            case .saturation(let v): return (0, v, 0, 0)
            case .hue(let v): return (v, 0, 0, 0)
            case .alpha(let v): return (0, 0, 0, v)
            }
        }
    }

    func adjusted(by adjustment: Adjustment) -> UIColor {
        let hsba = (hueComponent, saturationComponent, brightnessComponent, alphaComponent)

        switch adjustment {
        case .brightness(let amount):
            let newBright = max(0, min(1, hsba.2 + amount))
            return UIColor(hue: hsba.0, saturation: hsba.1, brightness: newBright, alpha: hsba.3)
        case .saturation(let amount):
            let newSat = max(0, min(1, hsba.1 + amount))
            return UIColor(hue: hsba.0, saturation: newSat, brightness: hsba.2, alpha: hsba.3)
        case .hue(let amount):
            var newHue = hsba.0 + amount
            while newHue < 0 { newHue += 1 }
            while newHue > 1 { newHue -= 1 }
            return UIColor(hue: newHue, saturation: hsba.1, brightness: hsba.2, alpha: hsba.3)
        case .alpha(let amount):
            let newAlpha = max(0, min(1, hsba.3 + amount))
            return UIColor(red: rgba.red, green: rgba.green, blue: rgba.blue, alpha: newAlpha)
        }
    }

    // MARK: - RGB String

    public func toRGBString() -> String {
        let components = cgColor.components ?? [0.0, 0.0, 0.0]
        let red = Int(components[0] * 255.0)
        let green = Int(components[1] * 255.0)
        let blue = Int(components[2] * 255.0)
        return "rgb(\(red), \(green), \(blue))"
    }

    public static func extractRGB(from rgbString: String) -> (Int, Int, Int)? {
        let pattern = #"rgb\s*\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*\)"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
              let match = regex.firstMatch(in: rgbString, range: NSRange(rgbString.startIndex..., in: rgbString)),
              let rRange = Range(match.range(at: 1), in: rgbString),
              let gRange = Range(match.range(at: 2), in: rgbString),
              let bRange = Range(match.range(at: 3), in: rgbString),
              let r = Int(rgbString[rRange]),
              let g = Int(rgbString[gRange]),
              let b = Int(rgbString[bRange]) else {
            return nil
        }
        return (r, g, b)
    }

    static func brightness(from rgbString: String) -> Double {
        guard let (r, g, b) = extractRGB(from: rgbString) else { return 0.5 }
        return (0.299 * Double(r) + 0.587 * Double(g) + 0.114 * Double(b)) / 255.0
    }

    // MARK: - Gradient

    #if canImport(QuartzCore) && os(iOS)
    func gradient(
        to endColor: UIColor? = nil,
        _ transform: ((inout CAGradientLayer) -> CAGradientLayer)? = nil
    ) -> CAGradientLayer {
        var layer = CAGradientLayer()
        layer.colors = endColor.map { [cgColor, $0.cgColor] } ?? [cgColor, cgColor]
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1, y: 1)
        if let transform = transform {
            layer = transform(&layer)
        }
        return layer
    }
    #endif

    // MARK: - Blending

    func add(hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat) -> UIColor {
        var (h, s, b, a) = (hueComponent, saturationComponent, brightnessComponent, alphaComponent)
        var newHue = h + hue
        while newHue < 0 { newHue += 1 }
        while newHue > 1 { newHue -= 1 }
        return UIColor(
            hue: newHue,
            saturation: max(0, min(1, s + saturation)),
            brightness: max(0, min(1, b + brightness)),
            alpha: max(0, min(1, a + alpha))
        )
    }

    func add(rgba: RGBAColorComponents) -> UIColor {
        add(hue: 0, saturation: 0, brightness: 0, alpha: 0).add(
            hue: rgba.red,
            saturation: rgba.green,
            brightness: rgba.blue,
            alpha: rgba.alpha
        )
    }

    var random: UIColor {
        UIColor(red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1), alpha: 1.0)
    }

    #if canImport(SwiftUI)
    var color: Color { Color(self) }
    #endif
}
#endif

// MARK: - SwiftUI Color Interop

#if canImport(SwiftUI) && canImport(UIKit) && os(iOS)
@available(iOS 14.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension Color {

    public init?(hex: String) {
        guard let uiColor = UIColor(hex: hex) else { return nil }
        self.init(uiColor)
    }

    var contrastingColor: Color {
        UIColor(self).isDark ? .white : .black
    }

    var uiColor: UIColor { UIColor(self) }
    var hex: String { uiColor.hexString() }

    public func toRGBString() -> String {
        let components = uiColor.cgColor.components ?? [0.0, 0.0, 0.0]
        return "rgb(\(Int(components[0] * 255)), \(Int(components[1] * 255)), \(Int(components[2] * 255)))"
    }

    static func parse(_ rgbString: String) -> Color? {
        guard let (r, g, b) = UIColor.extractRGB(from: rgbString) else { return nil }
        return Color(red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255)
    }
}
#endif
