import CoreImage
import UIKit

/// Pure image transformation seam used by the compatibility `ImageProcessor` facade.
@MainActor
public protocol SFKImageTransforming: AnyObject {
    func resize(_ image: UIImage, to size: CGSize, quality: CGFloat) -> UIImage?
    func roundCorners(_ image: UIImage, radius: CGFloat) -> UIImage?
    func toGrayscale(_ image: UIImage) -> UIImage?
    func applyBlur(_ image: UIImage, style: UIBlurEffect.Style) -> UIImage?
}

/// Default Core Graphics/Core Image implementation of the media transforms.
@MainActor
public final class SFKDefaultImageTransformer: SFKImageTransforming {
    public init() {}

    public func resize(_ image: UIImage, to size: CGSize, quality _: CGFloat) -> UIImage? {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { _ in image.draw(in: CGRect(origin: .zero, size: size)) }
    }

    public func roundCorners(_ image: UIImage, radius: CGFloat) -> UIImage? {
        let format = UIGraphicsImageRendererFormat()
        format.scale = image.scale
        let renderer = UIGraphicsImageRenderer(size: image.size, format: format)
        return renderer.image { _ in
            let rect = CGRect(origin: .zero, size: image.size)
            UIBezierPath(roundedRect: rect, cornerRadius: radius).addClip()
            image.draw(in: rect)
        }
    }

    public func toGrayscale(_ image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let context = CGContext(
            data: nil,
            width: cgImage.width,
            height: cgImage.height,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.none.rawValue
        )
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: cgImage.width, height: cgImage.height))
        guard let grayscaleImage = context?.makeImage() else { return nil }
        return UIImage(cgImage: grayscaleImage)
    }

    public func applyBlur(_ image: UIImage, style _: UIBlurEffect.Style) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        let ciImage = CIImage(cgImage: cgImage)
        let filter = CIFilter(name: "CIGaussianBlur")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        filter?.setValue(10.0, forKey: kCIInputRadiusKey)
        guard let outputImage = filter?.outputImage else { return nil }
        let context = CIContext(options: nil)
        guard let blurred = context.createCGImage(outputImage, from: outputImage.extent) else { return nil }
        return UIImage(cgImage: blurred)
    }
}
