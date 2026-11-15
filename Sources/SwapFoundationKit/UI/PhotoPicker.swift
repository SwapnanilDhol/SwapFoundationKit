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

final public class PhotoPicker: NSObject, ObservableObject, PHPickerViewControllerDelegate {
    let configuration: PHPickerConfiguration?
    private let onPick: ((UIImage) -> Void)?

    /// Creates a picker that reports the selected image through a closure.
    public init(
        configuration: PHPickerConfiguration? = nil,
        onPick: ((UIImage) -> Void)?
    ) {
        self.configuration = configuration
        self.onPick = onPick
    }

    /// Presents the system photo picker from a UIKit view controller.
    public func presentPicker(from viewController: UIViewController) {
        
        let picker = PHPickerViewController(configuration: configuration ?? .sfkSingleImage)
        picker.delegate = self
        viewController.present(picker, animated: true)
    }

    // PHPickerViewControllerDelegate method
    public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        // Keep the callback values alive after the picker is dismissed. UIKit's
        // delegate is weak and the presenting controller may tear down the
        // picker owner before PhotosUI finishes loading the object.
        let onPick = self.onPick
        loadFirstImage(
            from: results,
            onFailure: { error in
                Logger.error("Error loading image: \(error?.localizedDescription ?? "Unknown error")", context: "PhotoPicker")
            },
            deliver: { image in onPick?(image) }
        )
    }
}

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
        let picker = PHPickerViewController(configuration: configuration ?? .sfkSingleImage)
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
            // Capture the current binding and callback strongly. Dismissing the
            // picker can release the representable's coordinator before the
            // asynchronous PhotosUI load completes.
            let selection = self.selection
            let onPick = self.onPick
            loadFirstImage(from: results) { image in
                selection.wrappedValue = image
                onPick?(image)
            }
        }
    }
}

private extension PHPickerConfiguration {
    /// Single image selection, used when the caller passes no configuration.
    static var sfkSingleImage: PHPickerConfiguration {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        return configuration
    }
}

/// Loads the first picked item as a `UIImage` and delivers it on the main actor.
/// `onFailure` runs (off the main actor) when the item cannot be loaded as an image.
private func loadFirstImage(
    from results: [PHPickerResult],
    onFailure: ((Error?) -> Void)? = nil,
    deliver: @escaping @MainActor (UIImage) -> Void
) {
    guard let provider = results.first?.itemProvider,
          provider.canLoadObject(ofClass: UIImage.self) else { return }
    provider.loadObject(ofClass: UIImage.self) { image, error in
        guard let image = image as? UIImage else {
            onFailure?(error)
            return
        }
        Task { @MainActor in
            deliver(image)
        }
    }
}
