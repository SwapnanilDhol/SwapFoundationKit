import Foundation

/// A protocol for types that can provide and set a default value.
///
/// Conform to this protocol to allow a type to define a static default value and a way to update it at runtime.
public protocol ValueDefaultProvider {
    associatedtype Value
    /// Returns the default value for the type.
    static func defaultValue() -> Value
    /// Sets the default value for the type.
    static func setDefaultValue(_ value: Value)
}

public extension ValueDefaultProvider {
    /// Returns the default value for the type (as a static property).
    static var `default`: Value { defaultValue() }
}
