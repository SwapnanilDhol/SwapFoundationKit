import Foundation

// MARK: - Async Collection Extensions

public extension Sequence {
    /// Performs an async reduce over the sequence, processing each element sequentially.
    /// - Parameters:
    ///   - initialResult: The initial accumulator value.
    ///   - nextPartialResult: An async closure that takes the accumulator and an element.
    /// - Returns: The final accumulated result.
    func asyncReduce<Result>(
        _ initialResult: Result,
        _ nextPartialResult: @escaping (Result, Element) async throws -> Result
    ) async rethrows -> Result {
        var result = initialResult
        for element in self {
            result = try await nextPartialResult(result, element)
        }
        return result
    }
}

public extension Dictionary {
    /// Performs an async map over dictionary entries.
    /// - Parameter transform: An async closure receiving `(key, value)`.
    /// - Returns: An array of transformed values.
    func asyncMap<T>(
        _ transform: @escaping ((key: Key, value: Value)) async throws -> T
    ) async rethrows -> [T] {
        var results = [T]()
        results.reserveCapacity(count)
        for entry in self {
            try await results.append(transform(entry))
        }
        return results
    }
}
