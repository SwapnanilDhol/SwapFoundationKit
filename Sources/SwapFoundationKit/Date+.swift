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
    /// Returns the ISO8601 string representation of the date.
    var iso8601String: String {
        ISO8601DateFormatter().string(from: self)
    }

    /// Returns the date as a short style string (e.g., 6/7/24).
    var shortDate: String {
        let f = DateFormatter()
        f.dateStyle = .short
        f.timeStyle = .none
        return f.string(from: self)
    }

    /// Returns the date as a medium style string (e.g., Jun 7, 2024).
    var mediumDate: String {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f.string(from: self)
    }

    /// Returns the date as a long style string (e.g., June 7, 2024).
    var longDate: String {
        let f = DateFormatter()
        f.dateStyle = .long
        f.timeStyle = .none
        return f.string(from: self)
    }

    /// Returns the time only (e.g., 3:45 PM).
    var timeOnly: String {
        let f = DateFormatter()
        f.dateStyle = .none
        f.timeStyle = .short
        return f.string(from: self)
    }

    /// Returns the date and time in medium style (e.g., Jun 7, 2024 at 3:45 PM).
    var dateTime: String {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f.string(from: self)
    }

    /// Returns the date as yyyy-MM-dd (e.g., 2024-06-07).
    var yyyyMMdd: String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: self)
    }

    /// Returns the date as MMM d, yyyy (e.g., Jun 7, 2024).
    var MMMdyyyy: String {
        let f = DateFormatter()
        f.dateFormat = "MMM d, yyyy"
        return f.string(from: self)
    }

    /// Returns the date as a string using a custom format.
    func string(format: String) -> String {
        let f = DateFormatter()
        f.dateFormat = format
        return f.string(from: self)
    }

    /// Returns a relative time string (e.g., '2 hours ago').
    var relativeTime: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
