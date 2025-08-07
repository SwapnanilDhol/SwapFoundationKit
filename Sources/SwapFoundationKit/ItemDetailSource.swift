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

import Foundation

#if canImport(LinkPresentation)
import LinkPresentation
#endif

#if canImport(UIKit) && os(iOS)
import UIKit
#endif

/// A protocol for providing detailed information about items that can be shared or displayed.
/// This is commonly used with UIActivityViewController for sharing content.
public protocol ItemDetailSource {
    /// The title to display for the item.
    var title: String { get }
    
    /// The subtitle or description of the item.
    var subtitle: String? { get }
    
    /// The URL associated with the item.
    var url: URL? { get }
    
    /// The image data associated with the item.
    var imageData: Data? { get }
    
    /// The text content to share.
    var text: String { get }
}

#if canImport(UIKit) && os(iOS)
extension ItemDetailSource: UIActivityItemSource {
    public func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return text
    }
    
    public func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return text
    }
    
    #if canImport(LinkPresentation)
    public func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        metadata.title = title
        metadata.originalURL = url
        
        if let imageData = imageData {
            metadata.imageProvider = NSItemProvider(object: UIImage(data: imageData) ?? UIImage())
        }
        
        return metadata
    }
    #endif
}
#endif
