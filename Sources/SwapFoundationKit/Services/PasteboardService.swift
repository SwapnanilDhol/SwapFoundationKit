import Foundation

#if canImport(UIKit) && os(iOS)
import UIKit
#endif

public enum PasteboardPayload {
    case text(String)
    #if canImport(UIKit) && os(iOS)
    case image(UIImage)
    #endif
}

@MainActor
public protocol PasteboardWriting {
    func copy(_ payload: PasteboardPayload)
    func copy(_ text: String)
    #if canImport(UIKit) && os(iOS)
    func copy(_ image: UIImage)
    #endif
}

@MainActor
public final class PasteboardService: PasteboardWriting {
    public static let shared = PasteboardService()

    private init() {}

    public func copy(_ payload: PasteboardPayload) {
        switch payload {
        case .text(let text):
            copy(text)
        #if canImport(UIKit) && os(iOS)
        case .image(let image):
            copy(image)
        #endif
        }
    }

    public func copy(_ text: String) {
        #if canImport(UIKit) && os(iOS)
        UIPasteboard.general.string = text
        #endif
    }

    #if canImport(UIKit) && os(iOS)
    public func copy(_ image: UIImage) {
        UIPasteboard.general.image = image
    }
    #endif
}
