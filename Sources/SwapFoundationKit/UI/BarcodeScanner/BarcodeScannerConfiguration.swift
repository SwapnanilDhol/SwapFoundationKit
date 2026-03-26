/*****************************************************************************
 * BarcodeScannerConfiguration.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import Foundation
import Vision
import VisionKit

public struct BarcodeScannerConfiguration {
    public let title: String
    public let dismissButtonTitle: String
    public let errorTitle: String
    public let supportedSymbols: [VNBarcodeSymbology]
    public let qualityLevel: DataScannerViewController.QualityLevel
    public let enablesMultipleItemRecognition: Bool
    public let enableHighFrameRateTracking: Bool
    public let enableHighlighting: Bool
    public let unavailableTitle: String
    public let unavailableMessage: String

    public init(
        title: String = "Scan Barcode",
        dismissButtonTitle: String = "Done",
        errorTitle: String = "Scanner Error",
        supportedSymbols: [VNBarcodeSymbology] = [.qr, .pdf417, .aztec, .code128],
        qualityLevel: DataScannerViewController.QualityLevel = .balanced,
        enablesMultipleItemRecognition: Bool = false,
        enableHighFrameRateTracking: Bool = false,
        enableHighlighting: Bool = true,
        unavailableTitle: String = "Camera Scanning Unavailable",
        unavailableMessage: String = "Live barcode scanning is not available on this device."
    ) {
        self.title = title
        self.dismissButtonTitle = dismissButtonTitle
        self.errorTitle = errorTitle
        self.supportedSymbols = supportedSymbols
        self.qualityLevel = qualityLevel
        self.enablesMultipleItemRecognition = enablesMultipleItemRecognition
        self.enableHighFrameRateTracking = enableHighFrameRateTracking
        self.enableHighlighting = enableHighlighting
        self.unavailableTitle = unavailableTitle
        self.unavailableMessage = unavailableMessage
    }
}
