/****************************************************************************
 * SFKAmountInput.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import Foundation

/// A plain-text amount string plus the exact editing rules a
/// ``SFKNumberPad`` keypad applies to it.
///
/// `SFKAmountInput` owns nothing but the string being typed. It does not
/// parse the string into a `Double`, does not know about currencies, and does
/// not know about a host app's own locale/`NumberFormatter` setup for
/// validation or display, because those have diverged slightly between host
/// apps and are out of scope for what the keypad itself guarantees. Callers
/// pass in the decimal separator they already compute (typically from their
/// own `NumberFormatter`), so this type never has to choose a locale.
///
/// ## Usage
/// ```swift
/// @Published var amountValueString: String = ""
///
/// func applyNumberPadInput(_ input: SFKNumberPadInput) {
///     var amount = SFKAmountInput(text: amountValueString, maxIntegerDigits: 9)
///     amount.apply(input, decimalSeparator: decimalSeparator)
///     amountValueString = amount.text
/// }
/// ```
public struct SFKAmountInput: Equatable, Sendable {
    /// The current amount string, e.g. `"12.5"`.
    public private(set) var text: String

    /// The maximum number of digits allowed before the decimal separator.
    /// `nil` means unlimited, matching hosts that never capped the integer
    /// part.
    public var maxIntegerDigits: Int?

    public init(text: String = "", maxIntegerDigits: Int? = nil) {
        self.text = text
        self.maxIntegerDigits = maxIntegerDigits
    }

    /// Whether the amount string has no characters yet.
    public var isEmpty: Bool { text.isEmpty }

    /// Applies one keypad input using the shared amount-entry rules:
    /// - Backspace removes the last character, or does nothing on an empty string.
    /// - A period is ignored if the string already contains the decimal separator;
    ///   otherwise it is appended, seeding a leading `"0"` first when the string was empty.
    /// - A digit typed while two fraction digits already follow the separator is ignored.
    /// - A digit typed while the string reads exactly `"0"` replaces it instead of appending.
    /// - A digit typed once ``maxIntegerDigits`` integer digits are already present is ignored.
    ///
    /// - Parameters:
    ///   - input: The key that was tapped.
    ///   - decimalSeparator: The separator the host app resolved for the
    ///     current locale (for example from its own `NumberFormatter`).
    @discardableResult
    public mutating func apply(_ input: SFKNumberPadInput, decimalSeparator: String) -> String {
        switch input {
        case .backspace:
            guard !text.isEmpty else { return text }
            text.removeLast()

        case .period:
            guard !text.contains(decimalSeparator) else { return text }
            text = text.isEmpty ? "0\(decimalSeparator)" : text + decimalSeparator

        case .zero, .one, .two, .three, .four, .five, .six, .seven, .eight, .nine:
            appendDigit(input.rawValue, decimalSeparator: decimalSeparator)
        }
        return text
    }

    private mutating func appendDigit(_ digit: String, decimalSeparator: String) {
        if text.contains(decimalSeparator) {
            let parts = text.components(separatedBy: decimalSeparator)
            let fractionalPart = parts.count > 1 ? parts[1] : ""
            guard fractionalPart.count < 2 else { return }
            text += digit
            return
        }

        if text == "0" {
            text = digit
            return
        }

        if let maxIntegerDigits, text.count >= maxIntegerDigits { return }
        text += digit
    }
}
