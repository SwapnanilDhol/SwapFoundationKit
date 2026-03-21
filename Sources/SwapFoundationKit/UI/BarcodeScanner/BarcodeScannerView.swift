//
//  BarcodeScannerView.swift
//  SwapFoundationKit
//
//  Created by Swapnanil Dhol on 3/21/26.
//

import SwiftUI
import VisionKit

public struct BarcodeScannerView: UIViewControllerRepresentable {
    let configuration: BarcodeScannerConfiguration
    let onScan: (BarcodeScannerResult) -> Void
    let onFailure: (BarcodeScannerError) -> Void

    public static var isScanningAvailable: Bool {
        DataScannerViewController.isSupported && DataScannerViewController.isAvailable
    }

    public init(
        configuration: BarcodeScannerConfiguration,
        onScan: @escaping (BarcodeScannerResult) -> Void,
        onFailure: @escaping (BarcodeScannerError) -> Void
    ) {
        self.configuration = configuration
        self.onScan = onScan
        self.onFailure = onFailure
    }

    public func makeUIViewController(context: Context) -> DataScannerViewController {
        let controller = DataScannerViewController(
            recognizedDataTypes: [.barcode(symbologies: configuration.supportedSymbols)],
            qualityLevel: configuration.qualityLevel,
            recognizesMultipleItems: configuration.enablesMultipleItemRecognition,
            isHighFrameRateTrackingEnabled: configuration.enableHighFrameRateTracking,
            isHighlightingEnabled: configuration.enableHighlighting
        )
        controller.delegate = context.coordinator

        DispatchQueue.main.async {
            do {
                try controller.startScanning()
            } catch {
                context.coordinator.handleFailure(.failedToStartScanning(message: error.localizedDescription))
            }
        }

        return controller
    }

    public func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(onScan: onScan, onFailure: onFailure)
    }

    public final class Coordinator: NSObject, DataScannerViewControllerDelegate {
        let onScan: (BarcodeScannerResult) -> Void
        let onFailure: (BarcodeScannerError) -> Void
        private var hasDeliveredResult = false

        init(
            onScan: @escaping (BarcodeScannerResult) -> Void,
            onFailure: @escaping (BarcodeScannerError) -> Void
        ) {
            self.onScan = onScan
            self.onFailure = onFailure
        }

        public func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            handle(item)
        }

        public func dataScanner(
            _ dataScanner: DataScannerViewController,
            didAdd addedItems: [RecognizedItem],
            allItems: [RecognizedItem]
        ) {
            guard let firstItem = addedItems.first else { return }
            handle(firstItem)
        }

        func handleFailure(_ error: BarcodeScannerError) {
            onFailure(error)
        }

        private func handle(_ item: RecognizedItem) {
            guard !hasDeliveredResult,
                  case .barcode(let barcode) = item,
                  let payload = barcode.payloadStringValue,
                  !payload.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                return
            }

            hasDeliveredResult = true
            onScan(BarcodeScannerResult(payload: payload))
        }
    }
}
