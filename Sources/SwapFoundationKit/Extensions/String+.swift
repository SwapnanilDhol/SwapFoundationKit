import Foundation

#if canImport(SwiftUI)
import SwiftUI
#endif

// MARK: - String Extension

public extension String {

    // MARK: - Validation

    var isBlank: Bool { trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    var isNotBlank: Bool { !isBlank }
    var isNumeric: Bool { Double(self) != nil }
    var isNumbers: Bool {
        !isEmpty && rangeOfCharacter(from: .decimalDigits.inverted) == nil
    }
    var isAlphabetic: Bool {
        !isEmpty && rangeOfCharacter(from: .letters.inverted) == nil
    }
    var isAlphanumeric: Bool {
        !isEmpty && range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
    }

    /// Valid email format
    var isValidEmail: Bool {
        let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return matches(regex: pattern)
    }

    // MARK: - Manipulation

    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }
    var capitalizedFirst: String {
        guard let first = first else { return self }
        return String(first).uppercased() + dropFirst()
    }
    var withoutWhitespace: String {
        components(separatedBy: .whitespacesAndNewlines).joined()
    }

    func truncated(to maxLength: Int, with suffix: String = "...") -> String {
        guard count > maxLength else { return self }
        let truncatedLength = max(0, maxLength - suffix.count)
        return String(prefix(truncatedLength)) + suffix
    }

    func masked(keepFirst: Int = 0, keepLast: Int = 4, maskChar: Character = "*") -> String {
        guard count > keepFirst + keepLast else { return self }
        let maskLength = count - keepFirst - keepLast
        return String(prefix(keepFirst)) + String(repeating: maskChar, count: maskLength) + suffix(keepLast)
    }

    func containsIgnoringCase(_ other: String) -> Bool {
        range(of: other, options: .caseInsensitive) != nil
    }

    func replacingFirstOccurrence(of target: String, with replacement: String) -> String {
        guard let range = range(of: target) else { return self }
        return replacingCharacters(in: range, with: replacement)
    }

    func replacingLastOccurrence(of target: String, with replacement: String) -> String {
        guard let range = range(of: target, options: .backwards) else { return self }
        return replacingCharacters(in: range, with: replacement)
    }

    func countOccurrences(of substring: String) -> Int {
        components(separatedBy: substring).count - 1
    }

    // MARK: - Conversion

    var toInt: Int? { Int(self) }
    var toDouble: Double? { Double(self) }
    var reversedString: String { String(reversed()) }
    var lines: [String] { components(separatedBy: .newlines) }
    var wordCount: Int {
        components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.count
    }
    var data: Data? { data(using: .utf8) }
    var url: URL? { URL(string: self) }
    var doubleValue: Double? { Double(self) }
    var intValue: Int? { Int(self) }

    var boolValue: Bool? {
        switch lowercased() {
        case "true", "yes", "1", "on": return true
        case "false", "no", "0", "off": return false
        default: return nil
        }
    }

    // MARK: - Localization

    var localized: String { NSLocalizedString(self, comment: "") }

    func localized(bundle: Bundle) -> String {
        NSLocalizedString(self, bundle: bundle, comment: "")
    }

    func localized(bundle: Bundle, table: String) -> String {
        NSLocalizedString(self, tableName: table, bundle: bundle, comment: "")
    }

    func localizedFormat(_ arguments: CVarArg...) -> String {
        String(format: localized, arguments: arguments)
    }

    func localizedFormat(bundle: Bundle, _ arguments: CVarArg...) -> String {
        String(format: localized(bundle: bundle), arguments: arguments)
    }

    func localizedFormat(bundle: Bundle, table: String, _ arguments: CVarArg...) -> String {
        String(format: localized(bundle: bundle, table: table), arguments: arguments)
    }

    func localized(with arguments: CVarArg...) -> String {
        String(format: localized, arguments: arguments)
    }

    #if canImport(SwiftUI) && (os(iOS) || os(macOS))
    @available(macOS 13.0, *)
    var localizedResource: LocalizedStringResource {
        LocalizedStringResource(stringLiteral: self)
    }
    #endif
}

// MARK: - String Security

public extension String {
    var sanitized: String {
        components(separatedBy: CharacterSet(charactersIn: "<>&\"'")).joined()
    }

    var fileNameSafe: String {
        components(separatedBy: CharacterSet(charactersIn: ":/\\?%*|\"<>")).joined(separator: "_")
    }
}

// MARK: - String Crypto

public extension String {
    var md5: String { data?.md5 ?? "" }
    var sha1: String { data?.sha1 ?? "" }
    var sha256: String { data?.sha256 ?? "" }
}

// MARK: - String Regex & Validation

public extension String {
    func matches(regex pattern: String) -> Bool {
        range(of: pattern, options: .regularExpression) != nil
    }

    func matches(of pattern: String) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return [] }
        let results = regex.matches(in: self, range: NSRange(startIndex..., in: self))
        return results.compactMap { Range($0.range, in: self).map { String(self[$0]) } }
    }

    var isValidURL: Bool {
        guard let url = URL(string: self) else { return false }
        return url.scheme != nil && url.host != nil
    }

    var isValidPhoneNumber: Bool {
        matches(regex: "^[+]?[0-9]{7,15}$")
    }

    var isValidCreditCard: Bool {
        let cleaned = replacingOccurrences(of: " ", with: "")
        guard cleaned.isNumbers, (13...19).contains(cleaned.count) else { return false }

        var sum = 0
        for (index, digit) in cleaned.reversed().map({ Int(String($0))! }).enumerated() {
            sum += index % 2 == 1 ? (digit * 2 > 9 ? digit * 2 - 9 : digit * 2) : digit
        }
        return sum % 10 == 0
    }

    var htmlStripped: String {
        guard let data = data(using: .utf8),
              let attributed = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) else {
            return self
        }
        return attributed.string
    }

    var base64Encoded: String? { data?.base64EncodedString() }

    var base64Decoded: String? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    func levenshteinDistance(to other: String) -> Int {
        let m = count, n = other.count
        if m == 0 { return n }
        if n == 0 { return m }

        var matrix = [[Int]](repeating: [Int](repeating: 0, count: n + 1), count: m + 1)
        for i in 0...m { matrix[i][0] = i }
        for j in 0...n { matrix[0][j] = j }

        let selfArray = Array(self), otherArray = Array(other)
        for i in 1...m {
            for j in 1...n {
                let cost = selfArray[i - 1] == otherArray[j - 1] ? 0 : 1
                matrix[i][j] = Swift.min(matrix[i-1][j] + 1, Swift.min(matrix[i][j-1] + 1, matrix[i-1][j-1] + cost))
            }
        }
        return matrix[m][n]
    }
}

// MARK: - String Date

public extension String {
    func toDate(using format: DateFormat) -> Date? {
        format.formatter.date(from: self)
    }
}
