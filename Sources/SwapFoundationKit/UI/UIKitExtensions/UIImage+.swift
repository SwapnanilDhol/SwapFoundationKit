/*****************************************************************************
 * UIImage+.swift
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
import CoreImage
import UIKit

public extension UIImage {
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

    /// Returns the average color of the image using Core Image.
    var averageColor: UIColor? {
        guard let inputImage = CIImage(image: self) else { return nil }
        let extentVector = CIVector(
            x: inputImage.extent.origin.x,
            y: inputImage.extent.origin.y,
            z: inputImage.extent.size.width,
            w: inputImage.extent.size.height
        )
        guard let filter = CIFilter(
            name: "CIAreaAverage",
            parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]
        ) else {
            return nil
        }
        guard let outputImage = filter.outputImage else { return nil }

        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull as Any])
        context.render(
            outputImage,
            toBitmap: &bitmap,
            rowBytes: 4,
            bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
            format: .RGBA8,
            colorSpace: nil
        )

        return UIColor(
            red: CGFloat(bitmap[0]) / 255,
            green: CGFloat(bitmap[1]) / 255,
            blue: CGFloat(bitmap[2]) / 255,
            alpha: CGFloat(bitmap[3]) / 255
        )
    }

    /// Returns the pixel color at the given point in the image's coordinate space.
    func getPixelColor(pos: CGPoint) -> UIColor? {
        guard let cgImage,
              let dataProvider = cgImage.dataProvider,
              let data = dataProvider.data,
              let pixelData = CFDataGetBytePtr(data) else {
            return nil
        }

        let pixelInfo = (Int(pos.y) * cgImage.bytesPerRow) + (Int(pos.x) * 4)
        let red = CGFloat(pixelData[pixelInfo]) / 255.0
        let green = CGFloat(pixelData[pixelInfo + 1]) / 255.0
        let blue = CGFloat(pixelData[pixelInfo + 2]) / 255.0
        let alpha = CGFloat(pixelData[pixelInfo + 3]) / 255.0
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}
#endif
