/*****************************************************************************
 * SFKLogSink.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import Foundation

/// A destination that receives every message routed through `Logger.log`.
///
/// Register a sink from an opt-in product (such as `SwapFoundationKitPulse`) to forward SFK's
/// log stream elsewhere, without the default `SwapFoundationKit` target depending on that
/// product.
public protocol SFKLogSink: Sendable {
    func record(
        level: LogLevel,
        message: String,
        context: String?,
        function: String,
        file: String,
        line: Int
    )
}

/// Registry of `SFKLogSink` destinations. `Logger.log` broadcasts to every registered sink.
///
/// With no sink registered, broadcasting is a cheap no-op: `Logger.log` is a hot path and must
/// not pay for work nobody asked for.
public enum SFKLogSinkRegistry {
    private static let lock = NSLock()
    private static var sinks: [any SFKLogSink] = []

    /// Registers a log sink. Registering more than one sink fans a message out to all of them.
    ///
    /// This is intentionally a function rather than a public mutable static property: it keeps
    /// the registration boundary explicit and prevents arbitrary call sites from silently
    /// mutating shared logging state.
    public static func register(_ sink: any SFKLogSink) {
        lock.lock()
        defer { lock.unlock() }
        sinks.append(sink)
    }

    static func broadcast(
        level: LogLevel,
        message: String,
        context: String?,
        function: String,
        file: String,
        line: Int
    ) {
        lock.lock()
        let currentSinks = sinks
        lock.unlock()

        guard !currentSinks.isEmpty else { return }

        for sink in currentSinks {
            sink.record(level: level, message: message, context: context, function: function, file: file, line: line)
        }
    }

    /// Test-only support to remove every registered sink between test cases. Not part of the
    /// public API.
    static func resetForTesting() {
        lock.lock()
        sinks.removeAll()
        lock.unlock()
    }
}
