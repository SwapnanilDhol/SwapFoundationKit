import Foundation

public protocol PasteboardCopyRepresentable {
    associatedtype PasteboardCopyOption

    func pasteboardPayload(for option: PasteboardCopyOption) -> PasteboardPayload
}
