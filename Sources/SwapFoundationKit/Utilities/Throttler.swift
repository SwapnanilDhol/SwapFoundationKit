import Foundation

// MARK: - Throttler

/// A utility that executes a closure immediately on the first call,
/// then ignores subsequent calls until the specified time interval has elapsed.
/// Unlike Debouncer which delays execution, Throttler executes immediately
/// and then blocks until the interval passes.
final class Throttler {
    private let interval: TimeInterval
    private var lastExecutionTime: Date?
    private let queue: DispatchQueue
    private var pendingWorkItem: DispatchWorkItem?

    /// Creates a new Throttler
    /// - Parameters:
    ///   - interval: The minimum interval between executions in seconds
    ///   - queue: The queue to execute the work on (default: .main)
    init(interval: TimeInterval, queue: DispatchQueue = .main) {
        self.interval = interval
        self.queue = queue
    }

    /// Throttles the execution of a closure
    /// The first call executes immediately, subsequent calls within the interval are ignored
    /// - Parameter work: The closure to execute
    func throttle(_ work: @escaping () -> Void) {
        let now = Date()

        // If this is the first call or enough time has passed, execute immediately
        if let lastTime = lastExecutionTime {
            let timeSinceLastExecution = now.timeIntervalSince(lastTime)
            if timeSinceLastExecution >= interval {
                lastExecutionTime = now
                queue.async(execute: work)
            }
        } else {
            // First execution
            lastExecutionTime = now
            queue.async(execute: work)
        }
    }

    /// Throttles the execution of an async closure
    /// - Parameter work: The async closure to execute
    func throttle(_ work: @escaping () async -> Void) {
        let now = Date()

        // If this is the first call or enough time has passed, execute immediately
        if let lastTime = lastExecutionTime {
            let timeSinceLastExecution = now.timeIntervalSince(lastTime)
            if timeSinceLastExecution >= interval {
                lastExecutionTime = now
                Task { @MainActor in
                    await work()
                }
            }
        } else {
            // First execution
            lastExecutionTime = now
            Task { @MainActor in
                await work()
            }
        }
    }

    /// Resets the throttler, allowing the next call to execute immediately
    func reset() {
        lastExecutionTime = nil
        pendingWorkItem?.cancel()
        pendingWorkItem = nil
    }
}

// MARK: - AsyncThrottler

/// An async/await compatible throttler
@available(iOS 13.0, *)
final class AsyncThrottler {
    private let interval: TimeInterval
    private var lastExecutionTime: Date?
    private let lock = NSLock()

    /// Creates a new AsyncThrottler
    /// - Parameter interval: The minimum interval between executions in seconds
    init(interval: TimeInterval) {
        self.interval = interval
    }

    /// Throttles the execution of an async closure
    /// - Parameter work: The async closure to execute
    func throttle<T>(_ work: @escaping () async throws -> T) async throws -> T? {
        lock.lock()
        defer { lock.unlock() }

        let now = Date()

        // Check if we should execute
        if let lastTime = lastExecutionTime {
            let timeSinceLastExecution = now.timeIntervalSince(lastTime)
            if timeSinceLastExecution < interval {
                return nil // Throttled
            }
        }

        // Execute and update time
        lastExecutionTime = now
        return try await work()
    }

    /// Forces execution regardless of throttling
    /// - Parameter work: The async closure to execute
    func forceThrottle<T>(_ work: @escaping () async throws -> T) async throws -> T {
        lock.lock()
        lastExecutionTime = Date()
        lock.unlock()

        return try await work()
    }

    /// Resets the throttler
    func reset() {
        lock.lock()
        defer { lock.unlock() }
        lastExecutionTime = nil
    }
}
