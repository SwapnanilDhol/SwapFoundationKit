//
//  BarcodeScannerScreen.swift
//  SwapFoundationKit
//
//  Created by Swapnanil Dhol on 3/22/26.
//

import SwiftUI
import VisionKit

public struct BarcodeScannerResult: Equatable, Sendable {
    public let payload: String

    public init(payload: String) {
        self.payload = payload
    }
}

public enum BarcodeScannerError: LocalizedError, Equatable, Sendable {
    case scanningUnavailable
    case failedToStartScanning(message: String)

    public var errorDescription: String? {
        switch self {
        case .scanningUnavailable:
            return "Live barcode scanning is not available on this device."
        case .failedToStartScanning(let message):
            return message
        }
    }
}

public struct BarcodeScannerScreen: View {
    let configuration: BarcodeScannerConfiguration
    let onScan: (BarcodeScannerResult) -> Void
    var onClose: (() -> Void)?
    var onError: ((BarcodeScannerError) -> Void)?
    @State private var runtimeError: BarcodeScannerError?

    public init(
        configuration: BarcodeScannerConfiguration,
        onScan: @escaping (BarcodeScannerResult) -> Void,
        onClose: (() -> Void)? = nil,
        onError: ((BarcodeScannerError) -> Void)? = nil
    ) {
        self.configuration = configuration
        self.onScan = onScan
        self.onClose = onClose
        self.onError = onError
    }

    public var body: some View {
        Group {
            if let runtimeError {
                ContentUnavailableView(
                    configuration.errorTitle,
                    systemImage: "exclamationmark.triangle",
                    description: Text(runtimeError.errorDescription ?? configuration.unavailableMessage)
                )
            } else if BarcodeScannerView.isScanningAvailable {
                BarcodeScannerView(
                    configuration: configuration,
                    onScan: { result in
                        onScan(result)
                        onClose?()
                    },
                    onFailure: { error in
                        runtimeError = error
                        onError?(error)
                    }
                )
            } else {
                ContentUnavailableView(
                    configuration.unavailableTitle,
                    systemImage: "camera.viewfinder",
                    description: Text(configuration.unavailableMessage)
                )
            }
        }
        .navigationTitle(configuration.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if let onClose {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(configuration.dismissButtonTitle) {
                        onClose()
                    }
                }
            }
        }
    }
}
