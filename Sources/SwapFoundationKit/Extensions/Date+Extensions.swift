import Foundation

// MARK: - Cached Calendar

/// Cached calendar instance to avoid repeated `Calendar.current` access.
private var cachedCalendar: Calendar {
    Calendar.current
}

// MARK: - Cached Formatters

/// Cached DateFormatters keyed by format string for thread-safe access.
private struct CachedFormatters {
    private static var formatters: [String: DateFormatter] = [:]
    private static var iso8601: ISO8601DateFormatter?
    private static var relativeFull: RelativeDateTimeFormatter?
    private static var relativeAbbreviated: RelativeDateTimeFormatter?

    static func dateFormatter(for format: String) -> DateFormatter {
        if let cached = formatters[format] {
            return cached
        }
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatters[format] = formatter
        return formatter
    }

    static func dateFormatter(dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style) -> DateFormatter {
        let key = "\(dateStyle.rawValue)-\(timeStyle.rawValue)"
        if let cached = formatters[key] {
            return cached
        }
        let formatter = DateFormatter()
        formatter.dateStyle = dateStyle
        formatter.timeStyle = timeStyle
        formatters[key] = formatter
        return formatter
    }

    static func relativeFullFormatter() -> RelativeDateTimeFormatter {
        if let cached = relativeFull {
            return cached
        }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        relativeFull = formatter
        return formatter
    }

    static func relativeAbbreviatedFormatter() -> RelativeDateTimeFormatter {
        if let cached = relativeAbbreviated {
            return cached
        }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        relativeAbbreviated = formatter
        return formatter
    }

    static func iso8601Formatter() -> ISO8601DateFormatter {
        if let cached = iso8601 {
            return cached
        }
        let formatter = ISO8601DateFormatter()
        iso8601 = formatter
        return formatter
    }
}

// MARK: - DateFormat

public enum DateFormat {
    case iso8601, short, medium, long, full, timeOnly, time24Hour
    case yyyyMMdd, MMddyyyy, MMMddyyyy, MMMM, MMM, EEEE, EEE
    case custom(String)

    public var formatter: DateFormatter {
        switch self {
        case .iso8601:
            return CachedFormatters.dateFormatter(for: "yyyy-MM-dd'T'HH:mm:ssZ")
        case .short:
            return CachedFormatters.dateFormatter(dateStyle: .short, timeStyle: .none)
        case .medium:
            return CachedFormatters.dateFormatter(dateStyle: .medium, timeStyle: .none)
        case .long:
            return CachedFormatters.dateFormatter(dateStyle: .long, timeStyle: .none)
        case .full:
            return CachedFormatters.dateFormatter(dateStyle: .full, timeStyle: .none)
        case .timeOnly:
            return CachedFormatters.dateFormatter(dateStyle: .none, timeStyle: .short)
        case .time24Hour:
            return CachedFormatters.dateFormatter(for: "HH:mm")
        case .yyyyMMdd:
            return CachedFormatters.dateFormatter(for: "yyyy-MM-dd")
        case .MMddyyyy:
            return CachedFormatters.dateFormatter(for: "MM/dd/yyyy")
        case .MMMddyyyy:
            return CachedFormatters.dateFormatter(for: "MMM dd, yyyy")
        case .MMMM:
            return CachedFormatters.dateFormatter(for: "MMMM")
        case .MMM:
            return CachedFormatters.dateFormatter(for: "MMM")
        case .EEEE:
            return CachedFormatters.dateFormatter(for: "EEEE")
        case .EEE:
            return CachedFormatters.dateFormatter(for: "EEE")
        case .custom(let format):
            return CachedFormatters.dateFormatter(for: format)
        }
    }
}

// MARK: - Date Extension

public extension Date {

    // MARK: - Formatting

    var iso8601String: String {
        CachedFormatters.iso8601Formatter().string(from: self)
    }

    var shortDate: String { DateFormat.short.formatter.string(from: self) }
    var mediumDate: String { DateFormat.medium.formatter.string(from: self) }
    var longDate: String { DateFormat.long.formatter.string(from: self) }
    var fullDate: String { DateFormat.full.formatter.string(from: self) }
    var timeOnly: String { DateFormat.timeOnly.formatter.string(from: self) }
    var time24Hour: String { DateFormat.time24Hour.formatter.string(from: self) }
    var yyyyMMdd: String { DateFormat.yyyyMMdd.formatter.string(from: self) }
    var MMddyyyy: String { DateFormat.MMddyyyy.formatter.string(from: self) }
    var MMMddyyyy: String { DateFormat.MMMddyyyy.formatter.string(from: self) }
    var monthName: String { DateFormat.MMMM.formatter.string(from: self) }
    var shortMonthName: String { DateFormat.MMM.formatter.string(from: self) }
    var weekdayName: String { DateFormat.EEEE.formatter.string(from: self) }
    var shortWeekdayName: String { DateFormat.EEE.formatter.string(from: self) }

    var relativeTime: String {
        CachedFormatters.relativeFullFormatter().localizedString(for: self, relativeTo: Date())
    }

    var relativeTimeAbbreviated: String {
        CachedFormatters.relativeAbbreviatedFormatter().localizedString(for: self, relativeTo: Date())
    }

    func monthAndYearString() -> String {
        DateFormat.custom("MMMM yyyy").formatter.string(from: self)
    }

    func shortMonthAndYearString() -> String {
        DateFormat.custom("MMM yyyy").formatter.string(from: self)
    }

    func string(format: String) -> String {
        DateFormat.custom(format).formatter.string(from: self)
    }

    func toString(using format: DateFormat) -> String {
        format.formatter.string(from: self)
    }

    func formatted(style: DateFormatter.Style) -> String {
        DateFormat.custom("").formatter.dateStyle = style
        return DateFormat.custom("").formatter.string(from: self)
    }

    // MARK: - Components

    var year: Int { cachedCalendar.component(.year, from: self) }
    var month: Int { cachedCalendar.component(.month, from: self) }
    var day: Int { cachedCalendar.component(.day, from: self) }
    var hour: Int { cachedCalendar.component(.hour, from: self) }
    var minute: Int { cachedCalendar.component(.minute, from: self) }
    var second: Int { cachedCalendar.component(.second, from: self) }
    var weekday: Int { cachedCalendar.component(.weekday, from: self) }
    var quarter: Int { (month - 1) / 3 + 1 }
    var timeZone: TimeZone { cachedCalendar.timeZone }

    // MARK: - Date Checks

    var isToday: Bool { cachedCalendar.isDateInToday(self) }
    var isYesterday: Bool { cachedCalendar.isDateInYesterday(self) }
    var isTomorrow: Bool { cachedCalendar.isDateInTomorrow(self) }
    var isWeekend: Bool {
        let day = weekday
        return day == 1 || day == 7
    }

    var isThisWeek: Bool {
        cachedCalendar.isDate(self, equalTo: Date(), toGranularity: .weekOfYear)
    }

    var isThisMonth: Bool {
        cachedCalendar.isDate(self, equalTo: Date(), toGranularity: .month)
    }

    var isThisYear: Bool {
        cachedCalendar.isDate(self, equalTo: Date(), toGranularity: .year)
    }

    var isInCurrentWeek: Bool { isThisWeek }
    var isInCurrentMonth: Bool { isThisMonth }
    var isInCurrentYear: Bool { isThisYear }

    // MARK: - Date Boundaries

    var startOfDay: Date { cachedCalendar.startOfDay(for: self) }

    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return cachedCalendar.date(byAdding: components, to: startOfDay) ?? self
    }

    var startOfWeek: Date {
        let components = cachedCalendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return cachedCalendar.date(from: components) ?? self
    }

    var endOfWeek: Date {
        var components = DateComponents()
        components.weekOfYear = 1
        components.second = -1
        return cachedCalendar.date(byAdding: components, to: startOfWeek) ?? self
    }

    var startOfMonth: Date {
        let components = cachedCalendar.dateComponents([.year, .month], from: self)
        return cachedCalendar.date(from: components) ?? self
    }

    var endOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return cachedCalendar.date(byAdding: components, to: startOfMonth) ?? self
    }

    var startOfYear: Date {
        let components = cachedCalendar.dateComponents([.year], from: self)
        return cachedCalendar.date(from: components) ?? self
    }

    var endOfYear: Date {
        var components = DateComponents()
        components.year = 1
        components.second = -1
        return cachedCalendar.date(byAdding: components, to: startOfYear) ?? self
    }

    // MARK: - Date Manipulation

    func adding(days: Int) -> Date {
        cachedCalendar.date(byAdding: .day, value: days, to: self) ?? self
    }

    func adding(months: Int) -> Date {
        cachedCalendar.date(byAdding: .month, value: months, to: self) ?? self
    }

    func adding(years: Int) -> Date {
        cachedCalendar.date(byAdding: .year, value: years, to: self) ?? self
    }

    // MARK: - Utilities

    func isBetween(_ start: Date, and end: Date) -> Bool {
        self >= start && self <= end
    }

    var daysInMonth: Int {
        cachedCalendar.range(of: .day, in: .month, for: self)?.count ?? 30
    }

    func workingDays(until date: Date) -> Int {
        var count = 0
        var current = self
        while current <= date {
            if !current.isWeekend {
                count += 1
            }
            guard let next = cachedCalendar.date(byAdding: .day, value: 1, to: current) else { break }
            current = next
        }
        return count
    }

    static func from(year: Int, month: Int, day: Int) -> Date? {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return cachedCalendar.date(from: components)
    }
}
