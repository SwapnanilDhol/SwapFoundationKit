import Foundation

/// A concrete, reusable implementation of `ItemDetailSource`.
///
/// - `title`: A concise display title for previews/metadata (e.g., link cards).
/// - `text`: The primary shareable text payload (non-optional to ensure a
///   guaranteed fallback body for share sheets or copy operations).
/// - `subtitle`: Optional longer description shown in rich contexts.
/// - `url`: Optional associated URL for metadata generation.
/// - `imageData`: Optional image bytes for visual previews.
public struct DefaultItemDetailSource: ItemDetailSource {
    public let title: String
    public let subtitle: String?
    public let url: URL?
    public let imageData: Data?
    public let text: String

    public init(
        title: String,
        subtitle: String? = nil,
        url: URL? = nil,
        imageData: Data? = nil,
        text: String
    ) {
        self.title = title
        self.subtitle = subtitle
        self.url = url
        self.imageData = imageData
        self.text = text
    }
}


