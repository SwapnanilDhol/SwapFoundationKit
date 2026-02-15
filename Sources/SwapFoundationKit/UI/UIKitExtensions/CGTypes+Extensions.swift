import CoreGraphics
import UIKit

// MARK: - CGPoint+Extensions

extension CGPoint {
    /// Calculates the distance to another point
    /// - Parameter point: The other point
    /// - Returns: The distance in points
    func distance(to point: CGPoint) -> CGFloat {
        let dx = x - point.x
        let dy = y - point.y
        return sqrt(dx * dx + dy * dy)
    }

    /// Returns the midpoint between this point and another
    /// - Parameter point: The other point
    /// - Returns: The midpoint
    func midpoint(to point: CGPoint) -> CGPoint {
        CGPoint(x: (x + point.x) / 2, y: (y + point.y) / 2)
    }

    /// Returns a point offset by the given values
    /// - Parameters:
    ///   - dx: The x offset
    ///   - dy: The y offset
    /// - Returns: The offset point
    func offset(by dx: CGFloat, _ dy: CGFloat) -> CGPoint {
        CGPoint(x: x + dx, y: y + dy)
    }
}

// MARK: - CGSize+Extensions

extension CGSize {
    /// Returns the aspect ratio (width / height)
    var aspectRatio: CGFloat {
        guard height != 0 else { return 0 }
        return width / height
    }

    /// Returns a size scaled by the given factor
    /// - Parameter factor: The scale factor
    /// - Returns: The scaled size
    func scaled(by factor: CGFloat) -> CGSize {
        CGSize(width: width * factor, height: height * factor)
    }

    /// Returns a size that fits within the given size while maintaining aspect ratio
    /// - Parameter boundingSize: The bounding size
    /// - Returns: The fitted size
    func fitted(into boundingSize: CGSize) -> CGSize {
        let widthRatio = boundingSize.width / width
        let heightRatio = boundingSize.height / height
        let scale = min(widthRatio, heightRatio)
        return scaled(by: scale)
    }

    /// Returns a size that fills the given size while maintaining aspect ratio
    /// - Parameter boundingSize: The bounding size
    /// - Returns: The filled size
    func filled(into boundingSize: CGSize) -> CGSize {
        let widthRatio = boundingSize.width / width
        let heightRatio = boundingSize.height / height
        let scale = max(widthRatio, heightRatio)
        return scaled(by: scale)
    }
}

// MARK: - CGRect+Extensions

extension CGRect {
    /// Returns the center point of the rectangle
    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }

    /// Returns a rect centered in the given size
    /// - Parameter containerSize: The container size
    /// - Returns: The centered rect
    func centered(in containerSize: CGSize) -> CGRect {
        let x = (containerSize.width - width) / 2
        let y = (containerSize.height - height) / 2
        return CGRect(x: x, y: y, width: width, height: height)
    }

    /// Returns the bounding rect for multiple rects
    /// - Parameter rects: The rects to combine
    /// - Returns: The bounding rect
    static func boundingRect(of rects: [CGRect]) -> CGRect {
        guard let firstRect = rects.first else { return .zero }

        var minX = firstRect.minX
        var minY = firstRect.minY
        var maxX = firstRect.maxX
        var maxY = firstRect.maxY

        for rect in rects.dropFirst() {
            minX = min(minX, rect.minX)
            minY = min(minY, rect.minY)
            maxX = max(maxX, rect.maxX)
            maxY = max(maxY, rect.maxY)
        }

        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
}

// MARK: - CGVector+Extensions

extension CGVector {
    /// Returns the magnitude (length) of the vector
    var magnitude: CGFloat {
        sqrt(dx * dx + dy * dy)
    }

    /// Returns a normalized version of the vector (length of 1)
    var normalized: CGVector {
        let mag = magnitude
        guard mag != 0 else { return .zero }
        return CGVector(dx: dx / mag, dy: dy / mag)
    }

    /// Returns the distance to another vector
    /// - Parameter vector: The other vector
    /// - Returns: The distance
    func distance(to vector: CGVector) -> CGFloat {
        let dx = vector.dx - dx
        let dy = vector.dy - dy
        return sqrt(dx * dx + dy * dy)
    }

    /// Adds two vectors
    /// - Parameter vector: The vector to add
    /// - Returns: The resulting vector
    func adding(_ vector: CGVector) -> CGVector {
        CGVector(dx: dx + vector.dx, dy: dy + vector.dy)
    }

    /// Scales the vector
    /// - Parameter scalar: The scalar value
    /// - Returns: The scaled vector
    func scaled(by scalar: CGFloat) -> CGVector {
        CGVector(dx: dx * scalar, dy: dy * scalar)
    }
}

// MARK: - UIEdgeInsets+Extensions

extension UIEdgeInsets {
    /// Creates uniform insets
    /// - Parameter value: The value for all edges
    init(uniform value: CGFloat) {
        self.init(top: value, left: value, bottom: value, right: value)
    }

    /// Creates horizontal and vertical insets
    /// - Parameters:
    ///   - horizontal: The horizontal inset
    ///   - vertical: The vertical inset
    init(horizontal: CGFloat, vertical: CGFloat) {
        self.init(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
    }

    /// Returns the total horizontal inset
    var horizontalTotal: CGFloat {
        left + right
    }

    /// Returns the total vertical inset
    var verticalTotal: CGFloat {
        top + bottom
    }
}
