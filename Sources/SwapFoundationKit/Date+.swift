/*****************************************************************************
 * Date+.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/
 
import Foundation

public extension Date {
    /// Shared ISO8601DateFormatter instance.
    nonisolated(unsafe) static let iso8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        return formatter
    }()
    /// Returns the ISO8601 string representation of the date.
    var iso8601String: String { Date.iso8601Formatter.string(from: self) }

    /// Returns the date as a short style string (e.g., 6/7/24).
    var shortDate: String { DateFormatter.cached(.short, .none).string(from: self) }

    /// Returns the date as a medium style string (e.g., Jun 7, 2024).
    var mediumDate: String { DateFormatter.cached(.medium, .none).string(from: self) }

    /// Returns the date as a long style string (e.g., June 7, 2024).
    var longDate: String { DateFormatter.cached(.long, .none).string(from: self) }

    /// Returns the time only (e.g., 3:45 PM).
    var timeOnly: String { DateFormatter.cached(.none, .short).string(from: self) }

    /// Returns the date and time in medium style (e.g., Jun 7, 2024 at 3:45 PM).
    var dateTime: String { DateFormatter.cached(.medium, .short).string(from: self) }

    /// Returns the date as yyyy-MM-dd (e.g., 2024-06-07).
    var yyyyMMdd: String {
        let f = DateFormatter.cached(format: "yyyy-MM-dd")
        return f.string(from: self)
    }

    /// Returns the date as MMM d, yyyy (e.g., Jun 7, 2024).
    var MMMdyyyy: String {
        let f = DateFormatter.cached(format: "MMM d, yyyy")
        return f.string(from: self)
    }

    /// Returns the date as a string using a custom format.
    func string(format: String) -> String {
        let f = DateFormatter.cached(format: format)
        return f.string(from: self)
    }

    /// Returns a relative time string (e.g., '2 hours ago').
    var relativeTime: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}

// MARK: - DateFormatter Cache Actor
actor DateFormatterCache {
    private var cache: [String: DateFormatter] = [:]
    func formatter(forKey key: String, builder: @Sendable @escaping () -> DateFormatter) -> DateFormatter {
        if let cached = cache[key] { return cached }
        let f = builder()
        cache[key] = f
        return f
    }
}

private extension DateFormatter {
    private static let cacheActor = DateFormatterCache()

    /// Returns a cached DateFormatter for the given date and time styles.
    static func cached(_ dateStyle: Style, _ timeStyle: Style) -> DateFormatter {
        let key = "\(dateStyle.rawValue)-\(timeStyle.rawValue)"
        return cached(forKey: key, builder: { @Sendable () -> DateFormatter in
            let f = DateFormatter()
            f.dateStyle = dateStyle
            f.timeStyle = timeStyle
            return f
        })
    }
    /// Returns a cached DateFormatter for a custom format.
    static func cached(format: String) -> DateFormatter {
        return cached(forKey: format, builder: { @Sendable () -> DateFormatter in
            let f = DateFormatter()
            f.dateFormat = format
            return f
        })
    }
    private static func cached(forKey key: String, builder: @Sendable @escaping () -> DateFormatter) -> DateFormatter {
        return withUnsafeContinuation { continuation in
            Task {
                let formatter = await cacheActor.formatter(forKey: key, builder: builder)
                continuation.resume(returning: formatter)
            }
        }
    }
} 
