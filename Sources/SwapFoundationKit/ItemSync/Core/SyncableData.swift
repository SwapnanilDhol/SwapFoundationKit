//
//  SyncableData.swift
//  SwapFoundationKit
//
//  Created by Swapnanil Dhol on 1/11/25.
//

import Foundation

/// Protocol that any data type must conform to in order to be syncable
/// across different parts of your app ecosystem (Widgets, Watch, etc.)
///
/// ## Usage Example
/// ```swift
/// struct UserProfile: SyncableData {
///     let id: String
///     let name: String
///     let email: String
///     
///     // Required: Unique identifier for this data type
///     static let syncIdentifier = "user_profile"
///     
///     // Optional: Custom file extension (defaults to .json)
///     static let fileExtension = "json"
/// }
/// ```
public protocol SyncableData: Codable {
    /// Unique identifier for this data type used for file naming and organization
    /// This should be a short, descriptive string that identifies your data type
    static var syncIdentifier: String { get }
    
    /// File extension for storing this data (defaults to .json)
    /// Override this if you need a different file format
    static var fileExtension: String { get }
    
    /// Full filename including extension for this data type
    var fullFileName: String { get }
}

// MARK: - Default Implementation

public extension SyncableData {
    /// Default file extension is .json
    static var fileExtension: String { "json" }
    
    /// Full filename is constructed as: syncIdentifier.fileExtension
    var fullFileName: String { "\(Self.syncIdentifier).\(Self.fileExtension)" }
}

// MARK: - Array Support

/// Extension to make arrays of SyncableData also syncable
extension Array: SyncableData where Element: SyncableData {
    public static var syncIdentifier: String { Element.syncIdentifier }
    public static var fileExtension: String { Element.fileExtension }
} 