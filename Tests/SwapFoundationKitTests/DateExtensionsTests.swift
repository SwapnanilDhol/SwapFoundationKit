import XCTest
@testable import SwapFoundationKit

final class DateExtensionsTests: XCTestCase {

    // MARK: - Formatting

    func testISO8601String() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        formatter.timeZone = TimeZone(identifier: "UTC")

        let date = formatter.date(from: "2024-06-15T10:30:00+0000")!
        XCTAssertEqual(date.iso8601String, "2024-06-15T10:30:00Z")
    }

    func testShortDate() {
        let date = Date(timeIntervalSince1970: 0)
        let result = date.shortDate
        XCTAssertFalse(result.isEmpty)
    }

    func testMediumDate() {
        let date = Date(timeIntervalSince1970: 0)
        let result = date.mediumDate
        XCTAssertFalse(result.isEmpty)
    }

    func testLongDate() {
        let date = Date(timeIntervalSince1970: 0)
        let result = date.longDate
        XCTAssertFalse(result.isEmpty)
    }

    func testFullDate() {
        let date = Date(timeIntervalSince1970: 0)
        let result = date.fullDate
        XCTAssertFalse(result.isEmpty)
    }

    func testTimeOnly() {
        let date = Date(timeIntervalSince1970: 0)
        let result = date.timeOnly
        XCTAssertFalse(result.isEmpty)
    }

    func testCustomFormat() {
        let date = Date(timeIntervalSince1970: 0)
        let result = date.string(format: "yyyy")
        XCTAssertEqual(result, "1970")
    }

    func testToStringUsingDateFormat() {
        let date = Date(timeIntervalSince1970: 0)
        let result = date.toString(using: .yyyyMMdd)
        XCTAssertFalse(result.isEmpty)
    }

    // MARK: - Components

    func testYear() {
        let calendar = Calendar.current
        let components = DateComponents(year: 2024, month: 6, day: 15)
        let date = calendar.date(from: components)!

        XCTAssertEqual(date.year, 2024)
        XCTAssertEqual(date.month, 6)
        XCTAssertEqual(date.day, 15)
    }

    func testWeekday() {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = 2024
        components.month = 6
        components.day = 16 // A Sunday

        if let date = calendar.date(from: components) {
            XCTAssertEqual(date.weekday, 1)
        }
    }

    func testQuarter() {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = 2024
        components.month = 4
        components.day = 1

        if let date = calendar.date(from: components) {
            XCTAssertEqual(date.quarter, 2)
        }
    }

    // MARK: - Date Checks

    func testIsToday() {
        XCTAssertTrue(Date().isToday)
    }

    func testIsNotToday() {
        let yesterday = Date().adding(days: -1)
        XCTAssertFalse(yesterday.isToday)
    }

    func testIsYesterday() {
        let yesterday = Date().adding(days: -1)
        XCTAssertTrue(yesterday.isYesterday)
    }

    func testIsTomorrow() {
        let tomorrow = Date().adding(days: 1)
        XCTAssertTrue(tomorrow.isTomorrow)
    }

    func testIsWeekend() {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = 2024
        components.month = 6
        components.day = 16 // Sunday

        if let sunday = calendar.date(from: components) {
            XCTAssertTrue(sunday.isWeekend)
        }

        components.day = 17 // Monday
        if let monday = calendar.date(from: components) {
            XCTAssertFalse(monday.isWeekend)
        }
    }

    // MARK: - Date Manipulation

    func testAddingDays() {
        let date = Date(timeIntervalSince1970: 0)
        let future = date.adding(days: 5)
        let expected = Date(timeIntervalSince1970: 5 * 24 * 60 * 60)
        XCTAssertEqual(future.timeIntervalSince1970, expected.timeIntervalSince1970, accuracy: 1)
    }

    func testAddingMonths() {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = 2024
        components.month = 1
        components.day = 15

        if let date = calendar.date(from: components) {
            let future = date.adding(months: 1)
            let futureComponents = calendar.dateComponents([.month], from: future)
            XCTAssertEqual(futureComponents.month, 2)
        }
    }

    func testStartOfDay() {
        let date = Date()
        let start = date.startOfDay
        XCTAssertEqual(start.hour, 0)
        XCTAssertEqual(start.minute, 0)
        XCTAssertEqual(start.second, 0)
    }

    func testEndOfDay() {
        let date = Date()
        let end = date.endOfDay
        XCTAssertEqual(end.hour, 23)
        XCTAssertEqual(end.minute, 59)
        XCTAssertEqual(end.second, 59)
    }

    // MARK: - Date Creation

    func testFromYearMonthDay() {
        let date = Date.from(year: 2024, month: 6, day: 15)
        XCTAssertNotNil(date)

        if let date = date {
            XCTAssertEqual(date.year, 2024)
            XCTAssertEqual(date.month, 6)
            XCTAssertEqual(date.day, 15)
        }
    }

    // MARK: - Relative Time

    func testRelativeTime() {
        let past = Date().adding(days: -1)
        let result = past.relativeTime
        XCTAssertTrue(result.contains("day") || result.contains("Yesterday") || result.contains("1"))
    }

    func testRelativeTimeAbbreviated() {
        let past = Date().adding(days: -1)
        let result = past.relativeTimeAbbreviated
        XCTAssertFalse(result.isEmpty)
    }

    // MARK: - DateFormat Enum

    func testDateFormatCases() {
        let formatter = DateFormat.yyyyMMdd.formatter
        XCTAssertNotNil(formatter)

        let iso = DateFormat.iso8601.formatter
        XCTAssertNotNil(iso)
    }
}
