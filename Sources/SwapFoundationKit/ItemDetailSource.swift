/*****************************************************************************
 * ItemDetailSource.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import UIKit
#if canImport(LinkPresentation)
import LinkPresentation
#endif

public final class ItemDetailSource: NSObject {
    public let name: String
    public let image: Data

    public init(name: String, image: Data) {
        self.name = name
        self.image = image
    }
}

extension ItemDetailSource: UIActivityItemSource {

    public func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        image
    }
    public func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        image
    }

    public func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metaData = LPLinkMetadata()
        metaData.title = name
        metaData.imageProvider = NSItemProvider(object: UIImage(data: image) ?? UIImage())
        return metaData
    }
}
