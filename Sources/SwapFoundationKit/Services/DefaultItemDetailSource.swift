import Foundation

/// A concrete, reusable implementation of `ItemDetailSource`.
/// Use this when you want a simple data-backed source without
/// creating a custom type in your app.
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


