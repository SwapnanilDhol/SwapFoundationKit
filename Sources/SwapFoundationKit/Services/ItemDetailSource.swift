/*****************************************************************************
 * ItemDetailSource.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025-2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import Foundation

#if canImport(LinkPresentation)
import LinkPresentation
#endif

#if canImport(UIKit) && os(iOS)
import UIKit
#endif

/// A protocol for providing detailed information about items that can be shared or displayed.
///
/// Prefer ``makeActivityItem()`` when presenting `UIActivityViewController`.
/// The protocol itself is not an `UIActivityItemSource` — UIKit requires an
/// `NSObject` adopter, which ``ActivityItemDetailSource`` provides.
public protocol ItemDetailSource {
    /// A short display title for the item (used in previews/metadata).
    var title: String { get }

    /// The subtitle or description of the item.
    var subtitle: String? { get }

    /// The URL associated with the item.
    var url: URL? { get }

    /// The image data associated with the item.
    var imageData: Data? { get }

    /// The primary textual payload that gets shared or copied.
    var text: String { get }
}

#if canImport(UIKit) && os(iOS)
public extension ItemDetailSource {
    /// Returns a UIKit-ready activity item for `UIActivityViewController`.
    func makeActivityItem() -> UIActivityItemSource {
        ActivityItemDetailSource(self)
    }
}

/// `NSObject` + `UIActivityItemSource` bridge for ``ItemDetailSource``.
///
/// Share sheets only recognize `UIActivityItemSource` (or known types like
/// `UIImage` / `String` / `URL`). Passing a plain Swift model struct yields an
/// empty or nearly empty sheet.
public final class ActivityItemDetailSource: NSObject, UIActivityItemSource {
    private let title: String
    private let text: String
    private let url: URL?
    private let imageData: Data?
    private let subtitle: String?

    public init(_ source: some ItemDetailSource) {
        self.title = source.title
        self.text = source.text
        self.url = source.url
        // Empty `Data()` is not a valid image payload and collapses the sheet.
        self.imageData = source.imageData.flatMap { $0.isEmpty ? nil : $0 }
        self.subtitle = source.subtitle
        super.init()
    }

    private var image: UIImage? {
        guard let imageData else { return nil }
        return UIImage(data: imageData)
    }

    public func activityViewControllerPlaceholderItem(
        _ activityViewController: UIActivityViewController
    ) -> Any {
        // Placeholder type drives which system activities appear.
        image ?? url ?? text
    }

    public func activityViewController(
        _ activityViewController: UIActivityViewController,
        itemForActivityType activityType: UIActivity.ActivityType?
    ) -> Any? {
        if activityType == .copyToPasteboard {
            return text
        }
        if let image {
            return image
        }
        return url ?? text
    }

    public func activityViewController(
        _ activityViewController: UIActivityViewController,
        subjectForActivityType activityType: UIActivity.ActivityType?
    ) -> String {
        title.isEmpty ? text : title
    }

    #if canImport(LinkPresentation)
    public func activityViewControllerLinkMetadata(
        _ activityViewController: UIActivityViewController
    ) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        metadata.title = title.isEmpty ? text : title
        metadata.originalURL = url
        metadata.url = url
        if let image {
            metadata.imageProvider = NSItemProvider(object: image)
        }
        return metadata
    }
    #endif
}
#endif
