import Foundation
import Dispatch

/// Debounces actions, only executing the last call after a delay.
public final class Debouncer {
    private var workItem: DispatchWorkItem?
    private let queue: DispatchQueue
    private let delay: TimeInterval

    public init(delay: TimeInterval, queue: DispatchQueue = .main) {
        self.delay = delay
        self.queue = queue
    }

    public func call(_ block: @escaping () -> Void) {
        workItem?.cancel()
        workItem = DispatchWorkItem(block: block)
        if let workItem = workItem {
            queue.asyncAfter(deadline: .now() + delay, execute: workItem)
        }
    }
} 