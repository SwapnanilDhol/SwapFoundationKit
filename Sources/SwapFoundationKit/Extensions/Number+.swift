/*****************************************************************************
 * Number+.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import Foundation
#if canImport(CoreGraphics)
import CoreGraphics
#endif

#if canImport(CoreGraphics)
public extension CGFloat {
    /// Returns a random CGFloat between 0 and 1.
    static var random: CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}
#endif

/// Builds the formatter behind ``Double/clean`` and ``Double/plainDecimalString``.
///
/// Grouping separator and grouping size come from the locale. Hardcoding them
/// corrupts the output wherever the locale's decimal separator is a comma: a
/// forced comma group separator collides with it and `15757.58` renders as the
/// unreadable `15,757,58` instead of `15.757,58`. A fixed grouping size of 3 is
/// also wrong for Indian numbering, which groups 3-then-2.
///
/// `locale` exists so tests can pin a locale; production callers take the
/// current one.
internal func sfkDecimalFormatter(
    grouping: Bool,
    locale: Locale? = nil
) -> NumberFormatter {
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .decimal
    if let locale { numberFormatter.locale = locale }
    numberFormatter.alwaysShowsDecimalSeparator = false
    numberFormatter.maximumFractionDigits = 2
    numberFormatter.usesGroupingSeparator = grouping
    return numberFormatter
}

public extension Float {
    /// A localized display string with up to 2 decimal places and no trailing `.0`.
    ///
    /// Grouped for readability using the current locale's conventions. For a value
    /// you intend to parse back, use ``plainDecimalString`` instead.
    var clean: String {
        sfkDecimalFormatter(grouping: true).string(from: self as NSNumber) ?? ""
    }

    /// An ungrouped localized string with up to 2 decimal places.
    ///
    /// Uses the locale's decimal separator but omits grouping separators, so the
    /// result round-trips through a locale-aware parse. Prefer this over
    /// ``clean`` for values that seed an editable field or are parsed again.
    var plainDecimalString: String {
        sfkDecimalFormatter(grouping: false).string(from: self as NSNumber) ?? ""
    }
}

public extension Double {
    /// A localized display string with up to 2 decimal places and no trailing `.0`.
    ///
    /// Grouped for readability using the current locale's conventions. For a value
    /// you intend to parse back, use ``plainDecimalString`` instead.
    var clean: String {
        sfkDecimalFormatter(grouping: true).string(from: self as NSNumber) ?? ""
    }

    /// An ungrouped localized string with up to 2 decimal places.
    ///
    /// Uses the locale's decimal separator but omits grouping separators, so the
    /// result round-trips through a locale-aware parse. Prefer this over
    /// ``clean`` for values that seed an editable field or are parsed again.
    ///
    /// `clean` is a display helper; grouping separators make its output ambiguous
    /// to re-parse, and `Double("1.000")` silently yields `1.0` in locales where
    /// `.` groups thousands.
    var plainDecimalString: String {
        sfkDecimalFormatter(grouping: false).string(from: self as NSNumber) ?? ""
    }

    static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .spellOut
        return formatter
    }()

    var wordRepresentation: String? {
        guard self >= 1 && self <= 999_999 else { return nil }
        return Double.numberFormatter.string(from: NSNumber(value: self))
    }
}
