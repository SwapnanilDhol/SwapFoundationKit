import Foundation

// MARK: - Result+Extensions

extension Result {
    /// Returns true if the result is a success
    var isSuccess: Bool {
        switch self {
        case .success:
            return true
        case .failure:
            return false
        }
    }

    /// Returns true if the result is a failure
    var isFailure: Bool {
        !isSuccess
    }

    /// Returns the success value or a default value
    /// - Parameter defaultValue: The value to return if the result is a failure
    /// - Returns: The success value or the default
    func getOrElse(_ defaultValue: Success) -> Success {
        switch self {
        case .success(let value):
            return value
        case .failure:
            return defaultValue
        }
    }

    /// Returns the success value or nil if it's a failure
    var getOrNil: Success? {
        switch self {
        case .success(let value):
            return value
        case .failure:
            return nil
        }
    }

    /// Returns the success value or throws the failure
    /// This is essentially the same as get() but makes the intent clearer
    func getOrThrow() throws -> Success {
        switch self {
        case .success(let value):
            return value
        case .failure(let error):
            throw error
        }
    }

    /// Transforms the success value
    /// - Parameter transform: The transformation closure
    /// - Returns: A new result with the transformed value
    func map<NewSuccess>(_ transform: (Success) -> NewSuccess) -> Result<NewSuccess, Failure> {
        switch self {
        case .success(let value):
            return .success(transform(value))
        case .failure(let error):
            return .failure(error)
        }
    }

    /// Transforms the failure value
    /// - Parameter transform: The transformation closure
    /// - Returns: A new result with the transformed error
    func mapError<NewFailure>(_ transform: (Failure) -> NewFailure) -> Result<Success, NewFailure> {
        switch self {
        case .success(let value):
            return .success(value)
        case .failure(let error):
            return .failure(transform(error))
        }
    }

    /// FlatMaps the success value
    /// - Parameter transform: The transformation closure that returns a Result
    /// - Returns: The flatMapped result
    func flatMap<NewSuccess>(_ transform: (Success) -> Result<NewSuccess, Failure>) -> Result<NewSuccess, Failure> {
        switch self {
        case .success(let value):
            return transform(value)
        case .failure(let error):
            return .failure(error)
        }
    }
}
