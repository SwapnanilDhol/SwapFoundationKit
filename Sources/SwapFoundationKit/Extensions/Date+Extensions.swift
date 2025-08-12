import Foundation

public extension Date {
    
    // MARK: - ISO 8601 Formatting
    
    /// Returns the date in ISO 8601 format
    var iso8601String: String {
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: self)
    }
    
    // MARK: - Short Date Formatting
    
    /// Returns the date in short format (e.g., "1/15/24")
    var shortDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }
    
    /// Returns the date in medium format (e.g., "Jan 15, 2024")
    var mediumDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }
    
    /// Returns the date in long format (e.g., "January 15, 2024")
    var longDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }
    
    /// Returns the date in full format (e.g., "Monday, January 15, 2024")
    var fullDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }
    
    // MARK: - Time Formatting
    
    /// Returns only the time (e.g., "10:30 AM")
    var timeOnly: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
    
    /// Returns the time in 24-hour format (e.g., "14:30")
    var time24Hour: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }
    
    // MARK: - Custom Formatting
    
    /// Returns the date in yyyy-MM-dd format (e.g., "2024-01-15")
    var yyyyMMdd: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }
    
    /// Returns the date in MM/dd/yyyy format (e.g., "01/15/2024")
    var MMddyyyy: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.string(from: self)
    }
    
    /// Returns the date in MMM dd, yyyy format (e.g., "Jan 15, 2024")
    var MMMddyyyy: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter.string(from: self)
    }
    
    // MARK: - Relative Time
    
    /// Returns a relative time string (e.g., "2 hours ago", "yesterday")
    var relativeTime: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
    
    /// Returns a relative time string with abbreviated units (e.g., "2h ago", "1d ago")
    var relativeTimeAbbreviated: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }
    
    // MARK: - Date Components
    
    /// Returns the year component
    var year: Int {
        return Calendar.current.component(.year, from: self)
    }
    
    /// Returns the month component
    var month: Int {
        return Calendar.current.component(.month, from: self)
    }
    
    /// Returns the day component
    var day: Int {
        return Calendar.current.component(.day, from: self)
    }
    
    /// Returns the hour component
    var hour: Int {
        return Calendar.current.component(.hour, from: self)
    }
    
    /// Returns the minute component
    var minute: Int {
        return Calendar.current.component(.minute, from: self)
    }
    
    /// Returns the second component
    var second: Int {
        return Calendar.current.component(.second, from: self)
    }
    
    /// Returns the weekday component (1 = Sunday, 2 = Monday, etc.)
    var weekday: Int {
        return Calendar.current.component(.weekday, from: self)
    }
    
    /// Returns the weekday name (e.g., "Sunday", "Monday")
    var weekdayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: self)
    }
    
    /// Returns the short weekday name (e.g., "Sun", "Mon")
    var shortWeekdayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: self)
    }
    
    /// Returns the month name (e.g., "January", "February")
    var monthName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: self)
    }
    
    /// Returns the short month name (e.g., "Jan", "Feb")
    var shortMonthName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: self)
    }
    
    // MARK: - Date Calculations
    
    /// Returns true if the date is today
    var isToday: Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    /// Returns true if the date is yesterday
    var isYesterday: Bool {
        return Calendar.current.isDateInYesterday(self)
    }
    
    /// Returns true if the date is tomorrow
    var isTomorrow: Bool {
        return Calendar.current.isDateInTomorrow(self)
    }
    
    /// Returns true if the date is in the current week
    var isThisWeek: Bool {
        return Calendar.current.isDate(self, equalTo: Date(), toGranularity: .weekOfYear)
    }
    
    /// Returns true if the date is in the current month
    var isThisMonth: Bool {
        return Calendar.current.isDate(self, equalTo: Date(), toGranularity: .month)
    }
    
    /// Returns true if the date is in the current year
    var isThisYear: Bool {
        return Calendar.current.isDate(self, equalTo: Date(), toGranularity: .year)
    }
    
    // MARK: - Date Manipulation
    
    /// Returns a new date by adding days
    func adding(days: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }
    
    /// Returns a new date by adding months
    func adding(months: Int) -> Date {
        return Calendar.current.date(byAdding: .month, value: months, to: self) ?? self
    }
    
    /// Returns a new date by adding years
    func adding(years: Int) -> Date {
        return Calendar.current.date(byAdding: .year, value: years, to: self) ?? self
    }
    
    /// Returns the start of the day (midnight)
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    /// Returns the end of the day (23:59:59)
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay) ?? self
    }
    
    /// Returns the start of the week
    var startOfWeek: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components) ?? self
    }
    
    /// Returns the end of the week
    var endOfWeek: Date {
        let calendar = Calendar.current
        let startOfWeek = self.startOfWeek
        var components = DateComponents()
        components.weekOfYear = 1
        components.second = -1
        return calendar.date(byAdding: components, to: startOfWeek) ?? self
    }
    
    // MARK: - Custom Formatting
    
    /// Returns a string representation using a custom date format
    /// - Parameter format: The date format string (e.g., "EEE, MMM d @ h:mm a")
    /// - Returns: Formatted date string
    func string(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}
