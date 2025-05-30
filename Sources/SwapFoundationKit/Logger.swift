/*****************************************************************************
 * Logger.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/
 
import Foundation

public enum LogLevel: String, Sendable {
    case debug = "DEBUG"
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"

    var emoji: String {
        switch self {
        case .info: return "🟢"
        case .warning: return "🟡"
        case .error: return "🔴"
        case .debug: return "🟣"
        }
    }

    var color: String {
        switch self {
        case .info: return "\u{001B}[0;32m"    // Green
        case .warning: return "\u{001B}[0;33m" // Yellow
        case .error: return "\u{001B}[0;31m"   // Red
        case .debug: return "\u{001B}[0;35m"   // Magenta
        }
    }
}

public enum Logger {
    public static let minimumLevel: LogLevel = .debug // Change to .info for less verbosity

    /// If true, send an analytics event when an error is logged.
    public static var sendAnalyticsOnError: Bool = false

    public static func log(
        _ level: LogLevel,
        _ message: String,
        context: String? = nil,
        function: String = #function,
        file: String = #file,
        line: Int = #line
    ) {
        guard shouldLog(level) else { return }
        let timestamp = timestampString()
        let fileName = (file as NSString).lastPathComponent
        let projectName = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "Unknown"
        let thread = Thread.isMainThread ? "main" : "bg"
        let contextString = context.map { "[\($0)]" } ?? ""
        let color = level.color
        let reset = "\u{001B}[0m"
        print("\(color)\(level.emoji) [\(projectName)][\(timestamp)][\(level.rawValue)] [\(fileName):\(line) \(function)] [\(thread)]\(contextString) - \(message)\(reset)")
        if level == .error && sendAnalyticsOnError {
            Task {
                await AnalyticsManager.shared.logEvent(LoggerAnalyticsEvent.errorLogged(
                    message: message,
                    context: context,
                    function: function,
                    file: file,
                    line: line
                ))
            }
        }
    }

    public static func info(_ message: String, context: String? = nil, function: String = #function, file: String = #file, line: Int = #line) {
        log(.info, message, context: context, function: function, file: file, line: line)
    }
    public static func debug(_ message: String, context: String? = nil, function: String = #function, file: String = #file, line: Int = #line) {
        log(.debug, message, context: context, function: function, file: file, line: line)
    }
    public static func warning(_ message: String, context: String? = nil, function: String = #function, file: String = #file, line: Int = #line) {
        log(.warning, message, context: context, function: function, file: file, line: line)
    }
    public static func error(_ message: String, context: String? = nil, function: String = #function, file: String = #file, line: Int = #line) {
        log(.error, message, context: context, function: function, file: file, line: line)
    }

    private static func shouldLog(_ level: LogLevel) -> Bool {
        // You can make this smarter (e.g., only log warnings/errors in release)
        switch minimumLevel {
        case .debug: return true
        case .info: return level != .debug
        case .warning: return level == .warning || level == .error
        case .error: return level == .error
        }
    }

    private static func timestampString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter.string(from: Date())
    }
}

/// Analytics event for logger errors
private enum LoggerAnalyticsEvent: AnalyticsEvent {
    case errorLogged(message: String, context: String?, function: String, file: String, line: Int)

    var name: String {
        switch self {
        case .errorLogged: return "logger_error_logged"
        }
    }
    var parameters: [String: any Sendable] {
        switch self {
        case let .errorLogged(message, context, function, file, line):
            return [
                "message": message,
                "context": context ?? "",
                "function": function,
                "file": file,
                "line": line
            ]
        }
    }
}
