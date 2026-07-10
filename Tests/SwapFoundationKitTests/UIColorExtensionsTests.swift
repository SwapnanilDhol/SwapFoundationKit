import XCTest
#if canImport(UIKit) && os(iOS)
import UIKit
#endif

final class UIColorExtensionsTests: XCTestCase {

    #if canImport(UIKit) && os(iOS)

    // MARK: - Hex Initialization

    func testHexInit6Digits() {
        let color = UIColor(hex: "#FF5733")
        XCTAssertNotNil(color)
        if let color = color {
            XCTAssertEqual(color.redComponent, 1.0, accuracy: 0.01)
            XCTAssertEqual(color.greenComponent, 0.34, accuracy: 0.01)
            XCTAssertEqual(color.blueComponent, 0.2, accuracy: 0.01)
        }
    }

    func testHexInitWithoutHash() {
        let color = UIColor(hex: "FF5733")
        XCTAssertNotNil(color)
    }

    func testHexInit8Digits() {
        let color = UIColor(hex: "#FF573380")
        XCTAssertNotNil(color)
        if let color = color {
            // ARGB format: FF=alpha(255), 57=red(87), 33=green(51), 80=blue(128)
            XCTAssertEqual(color.alphaComponent, 1.0, accuracy: 0.01)
            XCTAssertEqual(color.redComponent, 0.34, accuracy: 0.01)
            XCTAssertEqual(color.greenComponent, 0.2, accuracy: 0.01)
            XCTAssertEqual(color.blueComponent, 0.5, accuracy: 0.01)
        }
    }

    func testHexInit3Digits() {
        let color = UIColor(hex: "F53")
        XCTAssertNotNil(color)
    }

    func testHexInitInvalid() {
        XCTAssertNil(UIColor(hex: "invalid"))
        XCTAssertNil(UIColor(hex: "GGGGGG"))
    }

    // MARK: - Hex Output

    func testHexString() {
        let color = UIColor(red: 1, green: 0.5, blue: 0.25, alpha: 1)
        let hex = color.hexString()
        XCTAssertTrue(hex.hasPrefix("#"))
        XCTAssertEqual(hex.count, 7) // #RRGGBB
    }

    func testHexStringWithAlpha() {
        let color = UIColor(red: 1, green: 0.5, blue: 0.25, alpha: 0.5)
        let hex = color.hexString(includeAlpha: true)
        XCTAssertEqual(hex.count, 9) // #RRGGBBAA
    }

    func testHexShortForm() {
        let color = UIColor(hex: "#FF5733")
        XCTAssertEqual(color?.hexString(), color?.hex)
    }

    // MARK: - Components

    func testRGBAComponents() {
        let color = UIColor(red: 0.25, green: 0.5, blue: 0.75, alpha: 0.9)
        let components = color.rgba

        XCTAssertEqual(components.red, 0.25, accuracy: 0.001)
        XCTAssertEqual(components.green, 0.5, accuracy: 0.001)
        XCTAssertEqual(components.blue, 0.75, accuracy: 0.001)
        XCTAssertEqual(components.alpha, 0.9, accuracy: 0.001)
    }

    func testRGBComponentsArray() {
        let color = UIColor(red: 0.25, green: 0.5, blue: 0.75, alpha: 1)
        let components = color.rgbComponents()

        XCTAssertEqual(components.count, 3)
        XCTAssertEqual(components[0], 0.25, accuracy: 0.001)
        XCTAssertEqual(components[1], 0.5, accuracy: 0.001)
        XCTAssertEqual(components[2], 0.75, accuracy: 0.001)
    }

    func testIndividualComponents() {
        let color = UIColor(red: 0.3, green: 0.6, blue: 0.9, alpha: 0.8)

        XCTAssertEqual(color.redComponent, 0.3, accuracy: 0.001)
        XCTAssertEqual(color.greenComponent, 0.6, accuracy: 0.001)
        XCTAssertEqual(color.blueComponent, 0.9, accuracy: 0.001)
        XCTAssertEqual(color.alphaComponent, 0.8, accuracy: 0.001)
    }

    // MARK: - Color Analysis

    func testIsDark() {
        let darkColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
        let lightColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)

        XCTAssertTrue(darkColor.isDark)
        XCTAssertFalse(lightColor.isDark)
    }

    func testIsBlack() {
        let black = UIColor.black
        let white = UIColor.white

        XCTAssertTrue(black.isBlack)
        XCTAssertFalse(white.isBlack)
    }

    func testIsWhite() {
        let white = UIColor.white
        let black = UIColor.black

        XCTAssertTrue(white.isWhite)
        XCTAssertFalse(black.isWhite)
    }

    func testIsBlackOrWhite() {
        XCTAssertTrue(UIColor.black.isBlackOrWhite)
        XCTAssertTrue(UIColor.white.isBlackOrWhite)
        XCTAssertFalse(UIColor.blue.isBlackOrWhite)
    }

    func testContrastingColor() {
        let darkColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
        let lightColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)

        XCTAssertEqual(darkColor.contrastingColor, .white)
        XCTAssertEqual(lightColor.contrastingColor, .black)
    }

    func testIsContrasting() {
        let black = UIColor.black
        let white = UIColor.white
        let darkGray = UIColor.darkGray

        XCTAssertTrue(black.isContrasting(with: white))
        // Dark gray is light enough to contrast with black
        XCTAssertTrue(black.isContrasting(with: darkGray))
        XCTAssertFalse(white.isContrasting(with: UIColor.lightGray))
    }

    // MARK: - Color Adjustment

    func testAdjustmentBrightness() {
        let color = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
        let lighter = color.adjusted(by: .brightness(0.2))
        let darker = color.adjusted(by: .brightness(-0.2))

        XCTAssertGreaterThan(lighter.brightnessComponent, color.brightnessComponent)
        XCTAssertLessThan(darker.brightnessComponent, color.brightnessComponent)
    }

    func testAdjustmentSaturation() {
        let color = UIColor(red: 1, green: 0.5, blue: 0.5, alpha: 1)
        let moreSaturated = color.adjusted(by: .saturation(0.2))
        let lessSaturated = color.adjusted(by: .saturation(-0.2))

        XCTAssertGreaterThan(moreSaturated.saturationComponent, color.saturationComponent)
        XCTAssertLessThan(lessSaturated.saturationComponent, color.saturationComponent)
    }

    func testAdjustmentHue() {
        let color = UIColor(red: 1, green: 0, blue: 0, alpha: 1) // Red
        let adjusted = color.adjusted(by: .hue(0.25))

        XCTAssertNotEqual(adjusted.hueComponent, color.hueComponent)
    }

    func testAdjustmentAlpha() {
        let color = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
        let moreOpaque = color.adjusted(by: .alpha(0.5))

        XCTAssertEqual(moreOpaque.alphaComponent, 1.0, accuracy: 0.001)
    }

    // MARK: - RGB String

    func testToRGBString() {
        let color = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
        let rgbString = color.toRGBString()

        XCTAssertTrue(rgbString.hasPrefix("rgb("))
        XCTAssertTrue(rgbString.contains("255"))
    }

    func testExtractRGB() {
        let result = UIColor.extractRGB(from: "rgb(255, 128, 64)")
        XCTAssertEqual(result?.0, 255)
        XCTAssertEqual(result?.1, 128)
        XCTAssertEqual(result?.2, 64)
    }

    func testExtractRGBInvalid() {
        XCTAssertNil(UIColor.extractRGB(from: "invalid"))
        XCTAssertNil(UIColor.extractRGB(from: "rgb(abc)"))
    }

    func testBrightnessFromRGBString() {
        let brightness = UIColor.brightness(from: "rgb(255, 255, 255)")
        XCTAssertEqual(brightness, 1.0, accuracy: 0.01)
    }

    // MARK: - Random

    func testRandom() {
        let color = UIColor()
        let random1 = color.random
        let random2 = color.random

        XCTAssertNotEqual(random1, random2)
        XCTAssertTrue(random1.alphaComponent > 0)
    }

    // MARK: - Blending

    func testAddHSBA() {
        let red = UIColor(red: 1, green: 0, blue: 0, alpha: 1)

        let result = red.add(hue: 0, saturation: 0, brightness: 0, alpha: 0)
        XCTAssertNotNil(result)
    }

    // MARK: - RGB Components via UIColor

    func testRGBAComponentsLuminance() {
        let white = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        let black = UIColor(red: 0, green: 0, blue: 0, alpha: 1)

        // Test via isDark which uses luminance internally
        XCTAssertFalse(white.isDark)
        XCTAssertTrue(black.isDark)
    }

    func testRGBComponentsArrayViaRGBA() {
        let color = UIColor(red: 0.1, green: 0.2, blue: 0.3, alpha: 1)
        let components = color.rgbComponents()

        XCTAssertEqual(components.count, 3)
        XCTAssertEqual(components[0], 0.1, accuracy: 0.001)
        XCTAssertEqual(components[1], 0.2, accuracy: 0.001)
        XCTAssertEqual(components[2], 0.3, accuracy: 0.001)
    }

    #endif
}
