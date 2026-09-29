/****************************************************************************
 * SFKAmountInputTests.swift
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

@Suite("SFKAmountInput amount-entry rules")
struct SFKAmountInputTests {

    @Test("Backspace on an empty string is a no-op")
    func backspaceOnEmptyIsNoOp() {
        var amount = SFKAmountInput()
        amount.apply(.backspace, decimalSeparator: ".")

        #expect(amount.text == "")
        #expect(amount.isEmpty)
    }

    @Test("Backspace removes the last character")
    func backspaceRemovesLastCharacter() {
        var amount = SFKAmountInput(text: "12.5")
        amount.apply(.backspace, decimalSeparator: ".")

        #expect(amount.text == "12.")
    }

    @Test("A period on an empty string seeds a leading zero")
    func periodOnEmptySeedsLeadingZero() {
        var amount = SFKAmountInput()
        amount.apply(.period, decimalSeparator: ".")

        #expect(amount.text == "0.")
    }

    @Test("A second period is ignored")
    func secondPeriodIsIgnored() {
        var amount = SFKAmountInput(text: "1.5")
        amount.apply(.period, decimalSeparator: ".")

        #expect(amount.text == "1.5")
    }

    @Test("Fraction digits are capped at two")
    func fractionDigitsAreCappedAtTwo() {
        var amount = SFKAmountInput(text: "1.23")
        amount.apply(.four, decimalSeparator: ".")

        #expect(amount.text == "1.23")
    }

    @Test("A digit typed on a lone leading zero replaces it")
    func digitReplacesLeadingZero() {
        var amount = SFKAmountInput(text: "0")
        amount.apply(.five, decimalSeparator: ".")

        #expect(amount.text == "5")
    }

    @Test("Integer digits are capped when a limit is set")
    func integerDigitsAreCappedAtLimit() {
        var amount = SFKAmountInput(text: "123456789", maxIntegerDigits: 9)
        amount.apply(.one, decimalSeparator: ".")

        #expect(amount.text == "123456789")
    }

    @Test("A nil integer digit cap allows unlimited integer digits")
    func nilCapAllowsUnlimitedIntegerDigits() {
        var amount = SFKAmountInput(text: "123456789", maxIntegerDigits: nil)
        amount.apply(.one, decimalSeparator: ".")

        #expect(amount.text == "1234567891")
    }

    @Test("A comma-decimal locale separator is honored end to end")
    func commaDecimalSeparatorIsHonored() {
        var amount = SFKAmountInput()
        for input in [.one, .two, .three, .period, .five, .zero] as [SFKNumberPadInput] {
            amount.apply(input, decimalSeparator: ",")
        }

        #expect(amount.text == "123,50")
    }

    @Test("The keypad builds the same string as manual entry across a mixed sequence")
    func mixedSequenceMatchesManualEntry() {
        var amount = SFKAmountInput(maxIntegerDigits: 9)
        // "7" is dropped: two fraction digits already follow the separator.
        // The trailing backspace then removes the "0" from "12.50".
        for input in [.one, .two, .period, .five, .zero, .seven, .backspace] as [SFKNumberPadInput] {
            amount.apply(input, decimalSeparator: ".")
        }

        #expect(amount.text == "12.5")
    }

    @Test("isValidInput accepts digits and a period, rejects other characters")
    func isValidInputAcceptsDigitsAndPeriod() {
        #expect(SFKNumberPadInput.isValidInput("123.45"))
        #expect(!SFKNumberPadInput.isValidInput("12a.45"))
        #expect(!SFKNumberPadInput.isValidInput("12,45"))
    }
}
