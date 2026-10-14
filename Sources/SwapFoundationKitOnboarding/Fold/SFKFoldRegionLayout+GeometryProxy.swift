/****************************************************************************
 * SFKFoldRegionLayout+GeometryProxy.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI

public extension SFKFoldRegionLayout {
    /// Reads the container size and the active fold from a geometry proxy.
    /// Use it from `onGeometryChange(for: SFKFoldRegionLayout.self)`.
    init(_ proxy: GeometryProxy) {
        self.init(containerSize: proxy.size, divisionFrame: Self.activeDivisionFrame(in: proxy))
    }

    /// The active fold in the proxy's coordinate space, or `nil` before iOS
    /// 27.1, on devices without a fold, and while the device is flat.
    static func activeDivisionFrame(in proxy: GeometryProxy) -> CGRect? {
        guard #available(iOS 27.1, *) else { return nil }
        return proxy.reservedRegions(kind: .division).first { $0.isActive }?.frame
    }
}
