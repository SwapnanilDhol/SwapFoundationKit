/****************************************************************************
 * NumberCleanLocaleTests.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import Foundation
import Testing
@testable import SwapFoundationKit

/// Locales whose decimal separator is a comma. These are the ones a forced
/// comma grouping separator corrupts.
private let commaDecimalLocales = [
    "de_DE", "fr_FR", "es_ES", "it_IT", "pt_BR", "nl_NL",
    "ru_RU", "pl_PL", "tr_TR", "cs_CZ", "nb_NO", "da_DK", "fi_FI", "hu_HU"
]

private let allTestLocales = commaDecimalLocales + [
    "en_US", "en_GB", "en_IN", "hi_IN", "ja_JP", "sv_SE"
]

/// Values chosen around the grouping boundary, where the bug appears.
private let testValues: [Double] = [0, 5, 73.08, 999.99, 1000, 15757.58, 1234567.89]

private func format(_ value: Double, grouping: Bool, locale: String) -> String {
    sfkDecimalFormatter(grouping: grouping, locale: Locale(identifier: locale))
        .string(from: value as NSNumber) ?? ""
}

private func parse(_ string: String, locale: String) -> Double? {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.locale = Locale(identifier: locale)
    return formatter.number(from: string)?.doubleValue
}

@Suite("Number clean/plainDecimalString locale handling")
struct NumberCleanLocaleTests {

    @Test("Grouped output never reuses the locale's decimal separator")
    func groupedOutputDoesNotCollideWithDecimalSeparator() {
        for identifier in allTestLocales {
            let locale = Locale(identifier: identifier)
            let decimalSeparator = locale.decimalSeparator ?? "."
            let formatted = format(15757.58, grouping: true, locale: identifier)

            // The regression: forcing "," produced "15,757,58" in comma-decimal
            // locales, where the separator appeared twice with different meanings.
            let occurrences = formatted.components(separatedBy: decimalSeparator).count - 1
            #expect(
                occurrences == 1,
                "\(identifier): \"\(formatted)\" uses the decimal separator \(occurrences) times"
            )
        }
    }

    @Test("Grouped output matches known locale conventions")
    func groupedOutputMatchesConventions() {
        #expect(format(15757.58, grouping: true, locale: "en_US") == "15,757.58")
        #expect(format(15757.58, grouping: true, locale: "de_DE") == "15.757,58")
        #expect(format(15757.58, grouping: true, locale: "es_ES") == "15.757,58")

        // Indian numbering groups 3-then-2, which a hardcoded groupingSize of 3
        // also got wrong.
        #expect(format(12345678, grouping: true, locale: "en_IN") == "1,23,45,678")
    }

    @Test("plainDecimalString omits grouping but keeps the locale decimal separator")
    func plainOmitsGrouping() {
        #expect(format(15757.58, grouping: false, locale: "en_US") == "15757.58")
        #expect(format(15757.58, grouping: false, locale: "de_DE") == "15757,58")
        #expect(format(12345678, grouping: false, locale: "en_IN") == "12345678")
    }

    @Test("plainDecimalString round-trips through a locale-aware parse")
    func plainRoundTrips() {
        for failure in roundTripFailures(grouping: false) {
            Issue.record("\(failure)")
        }
        #expect(roundTripFailures(grouping: false).isEmpty)
    }

    @Test("Grouped output round-trips through a locale-aware parse")
    func groupedRoundTrips() {
        for failure in roundTripFailures(grouping: true) {
            Issue.record("\(failure)")
        }
        #expect(roundTripFailures(grouping: true).isEmpty)
    }

    /// Returns a description of every locale/value pair that fails to survive a
    /// format-then-parse cycle.
    private func roundTripFailures(grouping: Bool) -> [String] {
        var failures: [String] = []
        for identifier in allTestLocales {
            for value in testValues {
                let formatted = format(value, grouping: grouping, locale: identifier)
                let parsed = parse(formatted, locale: identifier)
                let matches: Bool
                if let parsed {
                    matches = abs(parsed - value) < 0.005
                } else {
                    matches = false
                }
                if !matches {
                    let got = parsed.map { String($0) } ?? "nil"
                    failures.append("\(identifier): \(value) -> \"\(formatted)\" -> \(got)")
                }
            }
        }
        return failures
    }

    @Test("Whole values carry no trailing decimal separator")
    func wholeValuesHaveNoTrailingSeparator() {
        for identifier in allTestLocales {
            let separator = Locale(identifier: identifier).decimalSeparator ?? "."
            for grouping in [true, false] {
                let formatted = format(42, grouping: grouping, locale: identifier)
                #expect(
                    !formatted.contains(separator),
                    "\(identifier) grouping=\(grouping): \"\(formatted)\""
                )
            }
        }
    }

    @Test("Fraction digits stay capped at two")
    func fractionDigitsCapped() {
        #expect(format(1.005, grouping: false, locale: "en_US") == "1")
        #expect(format(1.567, grouping: false, locale: "en_US") == "1.57")
        #expect(format(1.567, grouping: false, locale: "de_DE") == "1,57")
    }

    @Test("Double and Float agree in the current locale")
    func doubleAndFloatAgree() {
        #expect((15757.5).clean == Float(15757.5).clean)
        #expect((15757.5).plainDecimalString == Float(15757.5).plainDecimalString)
        #expect((0.0).clean == Float(0.0).clean)
    }

    @Test("Public properties use the current locale")
    func publicPropertiesUseCurrentLocale() {
        let expectedGrouped = sfkDecimalFormatter(grouping: true)
            .string(from: 15757.58 as NSNumber)
        let expectedPlain = sfkDecimalFormatter(grouping: false)
            .string(from: 15757.58 as NSNumber)

        #expect((15757.58).clean == expectedGrouped)
        #expect((15757.58).plainDecimalString == expectedPlain)
    }
}
