import Foundation
import UIKit
import UniformTypeIdentifiers

/// Delegate protocol for receiving imported file data.
public protocol FileImportDelegate: AnyObject {
    func fileImportDidPick(data: Data, url: URL)
    func fileImportDidCancel()
}

/// Service for importing files via UIDocumentPickerViewController.
public final class FileImportService: NSObject {
    public static let shared = FileImportService()

    /// Presents a document picker filtered to the specified types.
    /// - Parameters:
    ///   - contentTypes: Array of `UTType`s to allow (e.g., `[.json, .commaSeparatedText]`).
    ///   - presentingViewController: The view controller to present from.
    ///   - delegate: Callback receiver for picked or cancelled events.
    public func importFile(
        contentTypes: [UTType],
        from presentingViewController: UIViewController,
        delegate: FileImportDelegate
    ) {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: contentTypes)
        picker.allowsMultipleSelection = false
        picker.delegate = self
        self.delegate = delegate
        presentingViewController.present(picker, animated: true)
    }

    /// Registers a custom file extension with UTType.
    /// - Parameters:
    ///   - fileExtension: The extension string (e.g., "recur").
    ///   -conformingTo: The base `UTType` to conform to (default: `.data`).
    /// - Returns: The registered `UTType`, or the conformingTo type if registration fails.
    @discardableResult
    public func registerCustomType(
        fileExtension: String,
        conformingTo baseType: UTType = .data
    ) -> UTType {
        var registeredType: UTType?
        if #available(iOS 14, *) {
            registeredType = UTType.types(tag: fileExtension, tagClass: UTTagClass.filenameExtension, conformingTo: nil).first
        }
        return registeredType ?? baseType
    }

    private var delegate: FileImportDelegate?
}

// MARK: - UIDocumentPickerDelegate
extension FileImportService: UIDocumentPickerDelegate {
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else {
            delegate?.fileImportDidCancel()
            return
        }
        guard url.startAccessingSecurityScopedResource() else {
            delegate?.fileImportDidCancel()
            return
        }
        defer { url.stopAccessingSecurityScopedResource() }

        do {
            let data = try Data(contentsOf: url)
            delegate?.fileImportDidPick(data: data, url: url)
        } catch {
            delegate?.fileImportDidCancel()
        }
    }

    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        delegate?.fileImportDidCancel()
    }
}
