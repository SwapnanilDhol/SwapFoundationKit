import Foundation
import UIKit

public enum PasteboardPayload {
    case text(String)
    case image(UIImage)
}

@MainActor
public protocol PasteboardWriting {
    func copy(_ payload: PasteboardPayload)
    func copy(_ text: String)
    func copy(_ image: UIImage)
}

@MainActor
public final class PasteboardService: PasteboardWriting {
    public static let shared = PasteboardService()

    private init() {}

    public func copy(_ payload: PasteboardPayload) {
        switch payload {
        case .text(let text):
            copy(text)
        case .image(let image):
            copy(image)
        }
    }

    public func copy(_ text: String) {
        UIPasteboard.general.string = text
    }

    public func copy(_ image: UIImage) {
        UIPasteboard.general.image = image
    }
}
