import XCTest
@testable import SwapFoundationKit

final class StringExtensionsTests: XCTestCase {

    // MARK: - Validation

    func testIsBlank() {
        XCTAssertTrue("".isBlank)
        XCTAssertTrue("   ".isBlank)
        XCTAssertTrue("\n\t".isBlank)
        XCTAssertFalse("hello".isBlank)
    }

    func testIsNotBlank() {
        XCTAssertFalse("".isNotBlank)
        XCTAssertTrue("hello".isNotBlank)
    }

    func testIsNumeric() {
        XCTAssertTrue("123".isNumeric)
        XCTAssertTrue("123.45".isNumeric)
        XCTAssertFalse("abc".isNumeric)
        XCTAssertFalse("12a".isNumeric)
    }

    func testIsNumbers() {
        XCTAssertTrue("123".isNumbers)
        XCTAssertFalse("123.45".isNumbers)
        XCTAssertFalse("abc".isNumbers)
    }

    func testIsAlphabetic() {
        XCTAssertTrue("hello".isAlphabetic)
        XCTAssertTrue("HELLO".isAlphabetic)
        XCTAssertFalse("hello123".isAlphabetic)
        XCTAssertFalse("".isAlphabetic)
    }

    func testIsAlphanumeric() {
        XCTAssertTrue("hello123".isAlphanumeric)
        XCTAssertTrue("HelloWorld".isAlphanumeric)
        XCTAssertFalse("hello world".isAlphanumeric)
        XCTAssertFalse("hello!".isAlphanumeric)
    }

    func testIsValidEmail() {
        XCTAssertTrue("test@example.com".isValidEmail)
        XCTAssertTrue("user.name+tag@domain.co.uk".isValidEmail)
        XCTAssertFalse("invalid".isValidEmail)
        XCTAssertFalse("invalid@".isValidEmail)
        XCTAssertFalse("@domain.com".isValidEmail)
    }

    func testIsEmail() {
        XCTAssertEqual("test@example.com".isEmail, "test@example.com".isValidEmail)
    }

    // MARK: - Manipulation

    func testTrimmed() {
        XCTAssertEqual("  hello  ".trimmed, "hello")
        XCTAssertEqual("\n\thello\n\t".trimmed, "hello")
    }

    func testCapitalizedFirst() {
        XCTAssertEqual("hello".capitalizedFirst, "Hello")
        XCTAssertEqual("HELLO".capitalizedFirst, "HELLO")
        XCTAssertEqual("".capitalizedFirst, "")
    }

    func testWithoutWhitespace() {
        XCTAssertEqual("hello world".withoutWhitespace, "helloworld")
        XCTAssertEqual("a b c".withoutWhitespace, "abc")
    }

    func testRemovingWhitespaces() {
        // Removes both spaces and newlines
        XCTAssertEqual("hello world".removingWhitespaces, "helloworld")
    }

    func testTruncated() {
        XCTAssertEqual("Hello World".truncated(to: 5), "He...")
        XCTAssertEqual("Hi".truncated(to: 10), "Hi")
        XCTAssertEqual("Hello".truncated(to: 5, with: "…"), "Hello")
    }

    func testMasked() {
        // Default: keepFirst=0, keepLast=4
        XCTAssertEqual("1234567890".masked(), "******7890")
        // keepFirst=2, keepLast=0: 2 first chars, 8 masked
        XCTAssertEqual("1234567890".masked(keepFirst: 2, keepLast: 0), "12********")
        // keepFirst=2, keepLast=2: 2 first, 2 last, 6 masked
        XCTAssertEqual("1234567890".masked(keepFirst: 2, keepLast: 2), "12******90")
    }

    func testContainsIgnoringCase() {
        XCTAssertTrue("Hello World".containsIgnoringCase("hello"))
        XCTAssertTrue("Hello World".containsIgnoringCase("WORLD"))
        XCTAssertFalse("Hello World".containsIgnoringCase("foo"))
    }

    // MARK: - Conversion

    func testToInt() {
        XCTAssertEqual("123".toInt, 123)
        XCTAssertNil("abc".toInt)
        XCTAssertNil("12.5".toInt)
    }

    func testToDouble() {
        XCTAssertEqual("123.45".toDouble, 123.45)
        XCTAssertNil("abc".toDouble)
    }

    func testReversedString() {
        XCTAssertEqual("hello".reversedString, "olleh")
        XCTAssertEqual("123".reversedString, "321")
    }

    func testLines() {
        XCTAssertEqual("a\nb\nc".lines, ["a", "b", "c"])
        XCTAssertEqual("a".lines, ["a"])
    }

    func testWordCount() {
        XCTAssertEqual("hello world".wordCount, 2)
        XCTAssertEqual("one two three four".wordCount, 4)
        XCTAssertEqual("".wordCount, 0)
    }

    func testData() {
        XCTAssertEqual("hello".data, Data("hello".utf8))
        XCTAssertEqual("hello".data?.count, 5)
    }

    func testUrl() {
        XCTAssertEqual("https://example.com".url, URL(string: "https://example.com"))
        // URL(string:) encodes spaces
        XCTAssertNotNil("not a url".url)
    }

    func testBoolValue() {
        XCTAssertEqual("true".boolValue, true)
        XCTAssertEqual("TRUE".boolValue, true)
        XCTAssertEqual("yes".boolValue, true)
        XCTAssertEqual("1".boolValue, true)
        XCTAssertEqual("false".boolValue, false)
        XCTAssertEqual("no".boolValue, false)
        XCTAssertEqual("0".boolValue, false)
        XCTAssertNil("invalid".boolValue)
    }

    // MARK: - Regex

    func testMatches() {
        XCTAssertTrue("123".matches(regex: "\\d+"))
        XCTAssertFalse("abc".matches(regex: "\\d+"))
    }

    func testMatchesOf() {
        let result = "hello123world456".matches(of: "\\d+")
        XCTAssertEqual(result, ["123", "456"])
    }

    func testIsValidURL() {
        XCTAssertTrue("https://example.com".isValidURL)
        XCTAssertTrue("http://test.org/path".isValidURL)
        XCTAssertFalse("not a url".isValidURL)
        XCTAssertFalse("://missing-scheme".isValidURL)
    }

    func testIsValidPhoneNumber() {
        XCTAssertTrue("1234567890".isValidPhoneNumber)
        XCTAssertTrue("+1234567890".isValidPhoneNumber)
        XCTAssertFalse("123".isValidPhoneNumber)
    }

    func testIsValidCreditCard() {
        XCTAssertTrue("4111111111111111".isValidCreditCard) // Valid test Visa
        XCTAssertFalse("1234567890123456".isValidCreditCard) // Invalid
    }

    // MARK: - Security

    func testSanitized() {
        let result = "<script>alert('xss')</script>".sanitized
        XCTAssertFalse(result.contains("<"))
        XCTAssertFalse(result.contains(">"))
    }

    func testFileNameSafe() {
        XCTAssertEqual("file:name?.txt".fileNameSafe.contains("_"), true)
    }

    // MARK: - Crypto

    func testMD5() {
        XCTAssertEqual("hello".md5, "5d41402abc4b2a76b9719d911017c592")
    }

    func testSHA1() {
        XCTAssertEqual("hello".sha1, "aaf4c61ddcc5e8a2dabede0f3b482cd9aea9434d")
    }

    func testSHA256() {
        XCTAssertEqual("hello".sha256, "2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824")
    }

    // MARK: - Base64

    func testBase64Encoded() {
        XCTAssertEqual("hello".base64Encoded, "aGVsbG8=")
    }

    func testBase64Decoded() {
        XCTAssertEqual("aGVsbG8=".base64Decoded, "hello")
        XCTAssertNil("invalid!!!".base64Decoded)
    }

    // MARK: - Levenshtein

    func testLevenshteinDistance() {
        XCTAssertEqual("hello".levenshteinDistance(to: "hello"), 0)
        XCTAssertEqual("hello".levenshteinDistance(to: "hallo"), 1)
        XCTAssertEqual("hello".levenshteinDistance(to: "world"), 4)
    }

    // MARK: - Replacement

    func testReplacingFirstOccurrence() {
        XCTAssertEqual("hello hello".replacingFirstOccurrence(of: "hello", with: "hi"), "hi hello")
    }

    func testReplacingLastOccurrence() {
        XCTAssertEqual("hello hello".replacingLastOccurrence(of: "hello", with: "hi"), "hello hi")
    }

    func testCountOccurrences() {
        // "hello hello hello" has 3 occurrences of "hello"
        XCTAssertEqual("hello hello hello".countOccurrences(of: "hello"), 3)
        XCTAssertEqual("test".countOccurrences(of: "x"), 0)
    }
}
