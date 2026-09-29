/****************************************************************************
 * SFKNumberPadInput.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import Foundation

/// Represents the possible inputs on a number pad for amount entry.
public enum SFKNumberPadInput: String, CaseIterable, Sendable {
    /// The number 1
    case one = "1"
    /// The number 2
    case two = "2"
    /// The number 3
    case three = "3"
    /// The number 4
    case four = "4"
    /// The number 5
    case five = "5"
    /// The number 6
    case six = "6"
    /// The number 7
    case seven = "7"
    /// The number 8
    case eight = "8"
    /// The number 9
    case nine = "9"
    /// The decimal point
    case period = "."
    /// The number 0
    case zero = "0"
    /// The backspace/delete key
    case backspace = "B"

    /// Returns true if the given string is made up only of digits and/or a period.
    public static func isValidInput(_ string: String) -> Bool {
        string.allSatisfy { $0.isNumber || $0 == "." }
    }
}
