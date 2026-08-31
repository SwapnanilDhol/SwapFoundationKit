/*****************************************************************************
 * CaptureExamplesView.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI
import UIKit
import SwapFoundationKit

struct CaptureExamplesView: View {
    @State private var presentedCapture: PresentedCapture?
    @State private var lastPayload: String?
    @State private var selectedPhoto: UIImage?
    @State private var isShowingPhotoPicker = false

    var body: some View {
        List {
            Section {
                Button("Open Barcode Scanner") {
                    presentedCapture = .barcodeScanner
                }
                Button("Open Photo Picker") {
                    isShowingPhotoPicker = true
                }
            } footer: {
                Text("Live scanning requires a supported physical device. The Simulator shows SFK’s unavailable state.")
            }

            if let lastPayload {
                Section("Last Scan") {
                    Text(lastPayload)
                        .textSelection(.enabled)
                }
            }

            if let selectedPhoto {
                Section("Selected Photo") {
                    Image(uiImage: selectedPhoto)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 160)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }

            Section("Included APIs") {
                Text("BarcodeScannerScreen").font(.body.monospaced())
                Text("BarcodeScannerConfiguration").font(.body.monospaced())
                Text("PhotoPicker").font(.body.monospaced())
            }
        }
        .navigationTitle("Capture & Media")
        .sheet(item: $presentedCapture) { _ in
            NavigationStack {
                BarcodeScannerScreen(
                    configuration: BarcodeScannerConfiguration(),
                    onScan: { result in
                        lastPayload = result.payload
                        presentedCapture = nil
                    },
                    onClose: {
                        presentedCapture = nil
                    }
                )
            }
        }
        .sheet(isPresented: $isShowingPhotoPicker) {
            SFKPhotoPicker(selection: $selectedPhoto)
                .ignoresSafeArea()
        }
    }
}

private extension CaptureExamplesView {
    enum PresentedCapture: String, Identifiable {
        case barcodeScanner

        var id: Self { self }
    }
}

#Preview {
    NavigationStack {
        CaptureExamplesView()
    }
}
