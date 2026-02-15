/*****************************************************************************
 * String+.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/
 
import Foundation

#if canImport(SwiftUI)
import SwiftUI
#endif

public extension String {
    /// Returns true if the string is blank (empty or whitespace only).
    var isBlank: Bool { trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    /// Returns true if the string is not blank
    var isNotBlank: Bool { !isBlank }
    /// Returns true if the string can be converted to a Double.
    var isNumeric: Bool { Double(self) != nil }
    
    /// Checks if the string contains only numeric characters
    var isNumbers: Bool {
        let numericCharacterSet = CharacterSet.decimalDigits
        return !isEmpty && rangeOfCharacter(from: numericCharacterSet.inverted) == nil
    }
    
    /// Checks if the string is a valid email format
    var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }
    
    /// Checks if the string contains only alphabetic characters
    var isAlphabetic: Bool {
        let alphabeticCharacterSet = CharacterSet.letters
        return !isEmpty && rangeOfCharacter(from: alphabeticCharacterSet.inverted) == nil
    }
    
    /// Checks if the string represents a valid decimal number
    var isValidDecimal: Bool {
        return Double(self) != nil
    }
    
    /// Checks if the string represents a valid integer
    var isValidInteger: Bool {
        return Int(self) != nil
    }

    /// Returns a new string made by removing whitespace and newlines from both ends.
    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }

    /// Returns the string with only the first character capitalized.
    var capitalizedFirst: String {
        guard let first = first else { return self }
        return String(first).uppercased() + dropFirst()
    }

    /// Returns true if the string contains the given substring, case-insensitive.
    func containsIgnoringCase(_ other: String) -> Bool {
        range(of: other, options: .caseInsensitive) != nil
    }

    /// Returns true if the string is a valid email address (simple regex).
    var isEmail: Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return range(of: regex, options: .regularExpression) != nil
    }

    /// Returns true if the string contains only alphanumeric characters.
    var isAlphanumeric: Bool {
        !isEmpty && range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
    }

    /// Returns a new string made by removing all whitespaces and newlines.
    var removingWhitespaces: String {
        replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\n", with: "")
    }
    
    /// Removes all whitespace from the string
    var withoutWhitespace: String {
        return components(separatedBy: .whitespacesAndNewlines).joined()
    }
    
    /// Limits the string to a maximum length with optional ellipsis
    func truncated(to maxLength: Int, with suffix: String = "...") -> String {
        guard count > maxLength else { return self }
        let truncatedLength = max(0, maxLength - suffix.count)
        return String(prefix(truncatedLength)) + suffix
    }
    
    /// Masks the string for privacy (e.g., credit card numbers)
    func masked(keepFirst: Int = 0, keepLast: Int = 4, maskChar: Character = "*") -> String {
        guard count > keepFirst + keepLast else { return self }

        let firstPart = prefix(keepFirst)
        let lastPart = suffix(keepLast)
        let maskLength = count - keepFirst - keepLast
        let mask = String(repeating: maskChar, count: maskLength)

        return firstPart + mask + lastPart
    }

    /// Converts the string to an Int, if possible.
    var toInt: Int? { Int(self) }

    /// Converts the string to a Double, if possible.
    var toDouble: Double? { Double(self) }

    /// Returns the reversed string.
    var reversedString: String { String(reversed()) }

    /// Returns the lines of the string as an array.
    var lines: [String] { components(separatedBy: .newlines) }

    /// Returns the number of words in the string.
    var wordCount: Int {
        let words = components(separatedBy: CharacterSet.whitespacesAndNewlines).filter { !$0.isEmpty }
        return words.count
    }

    /// Returns a localized version of the string using the main bundle.
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    /// Returns a localized version of the string using the specified bundle.
    /// - Parameter bundle: The bundle to use for localization.
    /// - Returns: The localized string.
    func localized(bundle: Bundle) -> String {
        return NSLocalizedString(self, bundle: bundle, comment: "")
    }
    
    /// Returns a localized version of the string using the specified bundle and table.
    /// - Parameters:
    ///   - bundle: The bundle to use for localization.
    ///   - table: The table name to use for localization.
    /// - Returns: The localized string.
    func localized(bundle: Bundle, table: String) -> String {
        return NSLocalizedString(self, tableName: table, bundle: bundle, comment: "")
    }
    
    /// Returns a localized version of the string with format arguments.
    /// - Parameter arguments: The arguments to format the string with.
    /// - Returns: The formatted localized string.
    func localizedFormat(_ arguments: CVarArg...) -> String {
        return String(format: localized, arguments: arguments)
    }
    
    /// Returns a localized version of the string with format arguments using the specified bundle.
    /// - Parameters:
    ///   - bundle: The bundle to use for localization.
    ///   - arguments: The arguments to format the string with.
    /// - Returns: The formatted localized string.
    func localizedFormat(bundle: Bundle, _ arguments: CVarArg...) -> String {
        return String(format: localized(bundle: bundle), arguments: arguments)
    }
    
    /// Returns a localized version of the string with format arguments using the specified bundle and table.
    /// - Parameters:
    ///   - bundle: The bundle to use for localization.
    ///   - table: The table name to use for localization.
    ///   - arguments: The arguments to format the string with.
    /// - Returns: The formatted localized string.
    func localizedFormat(bundle: Bundle, table: String, _ arguments: CVarArg...) -> String {
        return String(format: localized(bundle: bundle, table: table), arguments: arguments)
    }
    
    /// Returns a localized version with arguments
    func localized(with arguments: CVarArg...) -> String {
        return String(format: localized, arguments: arguments)
    }
    
#if canImport(SwiftUI) && (os(iOS) || os(macOS))
    /// Returns a localized version of the string using LocalizedStringResource.
    @available(macOS 13.0, *)
    func localizedResource() -> LocalizedStringResource {
        return LocalizedStringResource(stringLiteral: self)
    }
    
    /// Returns a localized version of the string using LocalizedStringResource with a specific bundle.
    /// - Parameter bundle: The bundle to use for localization.
    /// - Returns: The localized string resource.
    @available(macOS 13.0, *)
    func localizedResource(bundle: Bundle) -> LocalizedStringResource {
        return LocalizedStringResource(stringLiteral: self)
    }
    
    /// Returns a localized version of the string using LocalizedStringResource with a specific bundle and table.
    /// - Parameters:
    ///   - bundle: The bundle to use for localization.
    ///   - table: The table name to use for localization.
    /// - Returns: The localized string resource.
    @available(macOS 13.0, *)
    func localizedResource(bundle: Bundle, table: String) -> LocalizedStringResource {
        return LocalizedStringResource(stringLiteral: self)
    }
#endif
}

// MARK: - String Security Extensions

public extension String {
    
    /// Sanitizes the string for safe display (removes potential XSS characters)
    var sanitized: String {
        let dangerousCharacters = CharacterSet(charactersIn: "<>&\"'")
        return components(separatedBy: dangerousCharacters).joined()
    }
    
    /// Returns a version of the string safe for use in file names
    var fileNameSafe: String {
        let invalidCharacters = CharacterSet(charactersIn: ":/\\?%*|\"<>")
        return components(separatedBy: invalidCharacters).joined(separator: "_")
    }
}

// MARK: - String Conversion Extensions

public extension String {
    
    /// Converts string to Data using UTF-8 encoding
    var data: Data? {
        return data(using: .utf8)
    }
    
    /// Converts string to URL
    var url: URL? {
        return URL(string: self)
    }
    
    /// Converts string to Double safely
    var doubleValue: Double? {
        return Double(self)
    }
    
    /// Converts string to Int safely
    var intValue: Int? {
        return Int(self)
    }
    
    /// Converts string to Bool safely
    var boolValue: Bool? {
        switch lowercased() {
        case "true", "yes", "1", "on":
            return true
        case "false", "no", "0", "off":
            return false
        default:
            return nil
        }
    }
}

// MARK: - String Crypto Extensions

public extension String {
    
    /// Returns the MD5 hash of the string
    var md5: String {
        guard let data = data(using: .utf8) else { return "" }
        return data.md5
    }
    
    /// Returns the SHA1 hash of the string
    var sha1: String {
        guard let data = data(using: .utf8) else { return "" }
        return data.sha1
    }
    
    /// Returns the SHA256 hash of the string
    var sha256: String {
        guard let data = data(using: .utf8) else { return "" }
        return data.sha256
    }
}

// MARK: - String Utility Extensions

public extension String {
    
    /// Returns the string with the first occurrence of a substring replaced
    func replacingFirstOccurrence(of target: String, with replacement: String) -> String {
        guard let range = range(of: target) else { return self }
        return replacingCharacters(in: range, with: replacement)
    }
    
    /// Returns the string with the last occurrence of a substring replaced
    func replacingLastOccurrence(of target: String, with replacement: String) -> String {
        guard let range = range(of: target, options: .backwards) else { return self }
        return replacingCharacters(in: range, with: replacement)
    }
    
    /// Counts the number of occurrences of a substring
    func countOccurrences(of substring: String) -> Int {
        return components(separatedBy: substring).count - 1
    }
}

// MARK: - String Date Extensions

public extension String {
    
    /// Converts the string to a Date using the specified DateFormat
    /// - Parameter format: The DateFormat to use for parsing
    /// - Returns: A Date object if the string can be parsed, nil otherwise
    func toDate(using format: DateFormat) -> Date? {
        return format.formatter.date(from: self)
    }
}

// MARK: - String Regex & Validation Extensions

public extension String {
    /// Checks if the string matches a regex pattern
    /// - Parameter pattern: The regex pattern
    /// - Returns: True if the string matches the pattern
    func matches(regex pattern: String) -> Bool {
        range(of: pattern, options: .regularExpression) != nil
    }

    /// Returns all matches of a regex pattern
    /// - Parameter pattern: The regex pattern
    /// - Returns: An array of matching strings
    func matches(of pattern: String) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return []
        }

        let range = NSRange(location: 0, length: utf16.count)
        let results = regex.matches(in: self, options: [], range: range)

        return results.compactMap { result in
            guard let range = Range(result.range, in: self) else { return nil }
            return String(self[range])
        }
    }

    /// Checks if the string is a valid URL
    var isValidURL: Bool {
        guard let url = URL(string: self) else { return false }
        return url.scheme != nil && url.host != nil
    }

    /// Checks if the string is a valid phone number (basic validation)
    var isValidPhoneNumber: Bool {
        let phoneRegex = "^[+]?[0-9]{7,15}$"
        return matches(regex: phoneRegex)
    }

    /// Checks if the string is a valid credit card number (Luhn algorithm)
    var isValidCreditCard: Bool {
        let cleaned = replacingOccurrences(of: " ", with: "")
        guard cleaned.isNumbers, cleaned.count >= 13, cleaned.count <= 19 else {
            return false
        }

        // Luhn algorithm
        var sum = 0
        let reversedDigits = cleaned.reversed().map { Int(String($0))! }

        for (index, digit) in reversedDigits.enumerated() {
            if index % 2 == 1 {
                let doubled = digit * 2
                sum += doubled > 9 ? doubled - 9 : doubled
            } else {
                sum += digit
            }
        }

        return sum % 10 == 0
    }

    /// Strips HTML tags from the string
    var htmlStripped: String {
        guard let data = data(using: .utf8) else { return self }

        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]

        guard let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else {
            return self
        }

        return attributedString.string
    }

    /// Returns the base64 encoded string
    var base64Encoded: String? {
        data(using: .utf8)?.base64EncodedString()
    }

    /// Returns the base64 decoded string
    var base64Decoded: String? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    /// Returns the MD5 hash of the string
    var md5: String? {
        data(using: .utf8)?.md5
    }

    /// Calculates the Levenshtein distance to another string
    /// - Parameter other: The other string
    /// - Returns: The Levenshtein distance
    func levenshteinDistance(to other: String) -> Int {
        let m = self.count
        let n = other.count

        if m == 0 { return n }
        if n == 0 { return m }

        var matrix = [[Int]](repeating: [Int](repeating: 0, count: n + 1), count: m + 1)

        for i in 0...m { matrix[i][0] = i }
        for j in 0...n { matrix[0][j] = j }

        let selfArray = Array(self)
        let otherArray = Array(other)

        for i in 1...m {
            for j in 1...n {
                let cost = selfArray[i - 1] == otherArray[j - 1] ? 0 : 1
                matrix[i][j] = Swift.min(
                    matrix[i - 1][j] + 1,       // deletion
                    Swift.min(matrix[i][j - 1] + 1, matrix[i - 1][j - 1] + cost)  // insertion/substitution
                )
            }
        }

        return matrix[m][n]
    }

    /// Truncates the string to a maximum length with an ellipsis
    /// - Parameter maxLength: The maximum length
    /// - Returns: The truncated string
    func truncated(to maxLength: Int, trailing: String = "...") -> String {
        guard count > maxLength else { return self }
        return String(prefix(maxLength - trailing.count)) + trailing
    }
}
