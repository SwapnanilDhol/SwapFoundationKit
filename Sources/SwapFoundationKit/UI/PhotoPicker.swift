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

public protocol PhotoPickerDelegate: AnyObject {
    func didPickImage(_ image: UIImage)
}

final public class PhotoPicker: NSObject, ObservableObject, PHPickerViewControllerDelegate {
    let configuration: PHPickerConfiguration?
    weak var delegate: PhotoPickerDelegate?
    
    public init(
        configuration: PHPickerConfiguration? = nil,
        delegate: PhotoPickerDelegate? = nil
    ) {
        self.configuration = configuration
        self.delegate = delegate
    }

    func presentPicker(from viewController: UIViewController) {
        
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

        provider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
            if let image = image as? UIImage {
                self?.delegate?.didPickImage(image)
            } else {
                print("Error loading image: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
}
