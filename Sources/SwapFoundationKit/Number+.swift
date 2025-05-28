import Foundation
#if canImport(CoreGraphics)
import CoreGraphics
#endif

#if canImport(CoreGraphics)
public extension CGFloat {
    /// Returns a random CGFloat between 0 and 1.
    static var random: CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}
#endif

public extension Float {
    /// Returns a string representation without trailing .0 if the value is whole.
    var clean: String {
        truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}

public extension Double {
    /// Returns a string with up to 2 decimal places, no trailing .0 if whole.
    var clean: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.alwaysShowsDecimalSeparator = false
        numberFormatter.maximumFractionDigits = 2
        return numberFormatter.string(from: self as NSNumber) ?? ""
    }
} 
