/*****************************************************************************
 * PhotoPicker.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI
import PhotosUI

@available(*, deprecated, message: "Use PhotoPicker(onPick:) or SFKPhotoPicker(selection:onPick:) instead.")
public protocol PhotoPickerDelegate: AnyObject {
    func didPickImage(_ image: UIImage)
}

final public class PhotoPicker: NSObject, ObservableObject, PHPickerViewControllerDelegate {
    let configuration: PHPickerConfiguration?
    weak var delegate: PhotoPickerDelegate?
    private let onPick: ((UIImage) -> Void)?

    /// Creates a picker that reports the selected image through a closure.
    public init(
        configuration: PHPickerConfiguration? = nil,
        onPick: ((UIImage) -> Void)?
    ) {
        self.configuration = configuration
        self.delegate = nil
        self.onPick = onPick
    }
    
    @available(*, deprecated, message: "Use the closure initializer or SFKPhotoPicker(selection:onPick:) instead.")
    public init(
        configuration: PHPickerConfiguration? = nil,
        delegate: PhotoPickerDelegate? = nil
    ) {
        self.configuration = configuration
        self.delegate = delegate
        self.onPick = nil
    }

    /// Presents the system photo picker from a UIKit view controller.
    public func presentPicker(from viewController: UIViewController) {
        
        var temporaryConfiguration: PHPickerConfiguration
        if let configuration {
            temporaryConfiguration = configuration
        } else {
            temporaryConfiguration = PHPickerConfiguration()
            temporaryConfiguration.filter = .images // Only images
            temporaryConfiguration.selectionLimit = 1 // Single selection
        }

        let picker = PHPickerViewController(configuration: temporaryConfiguration)
        picker.delegate = self
        viewController.present(picker, animated: true)
    }

    // PHPickerViewControllerDelegate method
    public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        guard
            let provider = results.first?.itemProvider,
            provider.canLoadObject(ofClass: UIImage.self)
        else { return }

        // Keep the callback values alive after the picker is dismissed. UIKit's
        // delegate is weak and the presenting controller may tear down the
        // picker owner before PhotosUI finishes loading the object.
        let onPick = self.onPick
        let delegate = self.delegate
        provider.loadObject(ofClass: UIImage.self) { image, error in
            if let image = image as? UIImage {
                Task { @MainActor in
                    onPick?(image)
                    delegate?.didPickImage(image)
                }
            } else {
                print("Error loading image: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
}

#if canImport(UIKit) && os(iOS)
/// A SwiftUI photo picker that writes the selected image to a binding.
///
/// The representable owns the PHPicker delegate and keeps presentation details
/// out of host view models. The optional closure is useful for analytics or a
/// side effect that should happen alongside the binding update.
public struct SFKPhotoPicker: UIViewControllerRepresentable {
    @Binding private var selection: UIImage?
    private let configuration: PHPickerConfiguration?
    private let onPick: ((UIImage) -> Void)?

    public init(
        selection: Binding<UIImage?>,
        configuration: PHPickerConfiguration? = nil,
        onPick: ((UIImage) -> Void)? = nil
    ) {
        self._selection = selection
        self.configuration = configuration
        self.onPick = onPick
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(selection: $selection, onPick: onPick)
    }

    public func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = self.configuration ?? PHPickerConfiguration()
        if self.configuration == nil {
            configuration.filter = .images
            configuration.selectionLimit = 1
        }
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }

    public func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        context.coordinator.update(selection: $selection, onPick: onPick)
    }

    public final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        private var selection: Binding<UIImage?>
        private var onPick: ((UIImage) -> Void)?

        fileprivate init(selection: Binding<UIImage?>, onPick: ((UIImage) -> Void)?) {
            self.selection = selection
            self.onPick = onPick
        }

        fileprivate func update(selection: Binding<UIImage?>, onPick: ((UIImage) -> Void)?) {
            self.selection = selection
            self.onPick = onPick
        }

        public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            guard let provider = results.first?.itemProvider,
                  provider.canLoadObject(ofClass: UIImage.self) else { return }
            // Capture the current binding and callback strongly. Dismissing the
            // picker can release the representable's coordinator before the
            // asynchronous PhotosUI load completes.
            let selection = self.selection
            let onPick = self.onPick
            provider.loadObject(ofClass: UIImage.self) { image, _ in
                guard let image = image as? UIImage else { return }
                Task { @MainActor in
                    selection.wrappedValue = image
                    onPick?(image)
                }
            }
        }
    }
}
#endif
