import Foundation

public extension String {
    /// Returns true if the string is blank (empty or whitespace only).
    var isBlank: Bool { trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    /// Returns true if the string can be converted to a Double.
    var isNumeric: Bool { Double(self) != nil }

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
}