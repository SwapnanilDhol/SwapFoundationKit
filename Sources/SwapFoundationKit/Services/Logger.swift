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

public enum LogLevel: String, Sendable, CaseIterable, Comparable {
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

    private var severity: Int {
        switch self {
        case .debug: return 0
        case .info: return 1
        case .warning: return 2
        case .error: return 3
        }
    }

    public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        lhs.severity < rhs.severity
    }
}

actor LoggerSettings {
    static let shared = LoggerSettings()
    private var _sendAnalyticsOnError: Bool = false

    var sendAnalyticsOnError: Bool {
        get { _sendAnalyticsOnError }
    }

    func setSendAnalyticsOnError(_ value: Bool) {
        _sendAnalyticsOnError = value
    }
}

public enum Logger {
    public static var minimumLevel: LogLevel = .debug

    public static func setSendAnalyticsOnError(_ value: Bool) async {
        await LoggerSettings.shared.setSendAnalyticsOnError(value)
    }

    public static func getSendAnalyticsOnError() async -> Bool {
        await LoggerSettings.shared.sendAnalyticsOnError
    }

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
        Task {
            let shouldSendAnalytics = await LoggerSettings.shared.sendAnalyticsOnError
            if level == .error && shouldSendAnalytics {
                let event = DefaultAnalyticsEvent(
                    name: "logger_error_logged",
                    parameters: [
                        "message": message,
                        "context": context ?? "",
                        "function": function,
                        "file": file,
                        "line": String(line)
                    ]
                )
                AnalyticsManager.shared.logEvent(event: event, parameters: event.parameters)
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
        level >= minimumLevel
    }

    private static func timestampString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter.string(from: Date())
    }
}
