import Foundation

#if canImport(UIKit) && os(iOS)
import UIKit

extension UIImage {
    /// Resizes the image to a target size while maintaining aspect ratio
    /// - Parameter targetSize: The desired size of the output image
    /// - Returns: A resized UIImage, or nil if resizing fails
    func resized(targetSize: CGSize) -> UIImage? {
        let size = self.size

        // Calculate the scaling factor to fit the target size while maintaining the aspect ratio
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        let scaleFactor = min(widthRatio, heightRatio)

        // Calculate the new size based on the scaling factor
        let scaledSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )

        // Create a bitmap context
        UIGraphicsBeginImageContextWithOptions(scaledSize, false, 0.0)
        defer { UIGraphicsEndImageContext() }

        // Draw the image into the context
        self.draw(in: CGRect(origin: .zero, size: scaledSize))

        // Get the resized image from the context
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
#endif
