import Foundation
import UIKit
import UniformTypeIdentifiers

/// Service for exporting data and presenting a share sheet.
public final class FileExportService {
    public static let shared = FileExportService()
    private init() {}

    /// Exports data as a file and presents the system share sheet.
    /// - Parameters:
    ///   - data: The raw data to export.
    ///   - filename: The filename including extension (e.g., "export.json").
    ///   - utType: Optional `UTType` for platform-specific suggestions.
    ///   - presentingViewController: The view controller to present from.
    public func export(
        data: Data,
        filename: String,
        utType: UTType? = nil,
        from presentingViewController: UIViewController
    ) {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        try? data.write(at: tempURL)

        var activityItems: [Any] = [tempURL]

        let activityVC = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        activityVC.popoverPresentationController?.sourceView = presentingViewController.view
        activityVC.popoverPresentationController?.sourceRect = CGRect(x: 0, y: 0, width: 100, height: 100)

        presentingViewController.present(activityVC, animated: true)
    }

    /// Exports an `Encodable` object as a JSON file and presents the share sheet.
    /// - Parameters:
    ///   - object: The object to export (must be `Encodable`).
    ///   - filename: The filename including extension (e.g., "export.json").
    ///   - encoder: Optional encoder configuration.
    ///   - presentingViewController: The view controller to present from.
    public func export<T: Encodable>(
        _ object: T,
        filename: String,
        encoder: JSONEncoder = .init(),
        from presentingViewController: UIViewController
    ) throws {
        let data = try encoder.encode(object)
        export(data: data, filename: filename, from: presentingViewController)
    }
}
