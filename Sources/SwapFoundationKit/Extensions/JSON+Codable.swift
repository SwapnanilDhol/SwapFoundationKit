import Foundation

// MARK: - JSON+Codable

enum JSONCodingError: Error {
    case encodingFailed(Error)
    case decodingFailed(Error)
    case fileNotFound(String)
    case invalidData
}

struct JSONCodable {
    private static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        return encoder
    }()

    private static let decoder = JSONDecoder()

    /// Encodes an Encodable value to Data
    /// - Parameters:
    ///   - value: The value to encode
    ///   - prettyPrinted: Whether to use pretty printing (default: true)
    /// - Returns: The encoded Data
    static func encode<T: Encodable>(_ value: T, prettyPrinted: Bool = true) throws -> Data {
        let encoder = JSONEncoder()
        if prettyPrinted {
            encoder.outputFormatting = .prettyPrinted
        }
        return try encoder.encode(value)
    }

    /// Decodes a Decodable type from Data
    /// - Parameters:
    ///   - type: The type to decode to
    ///   - data: The Data to decode
    /// - Returns: The decoded value
    static func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        return try decoder.decode(type, from: data)
    }

    /// Encodes an Encodable value to a JSON string
    /// - Parameters:
    ///   - value: The value to encode
    ///   - prettyPrinted: Whether to use pretty printing (default: true)
    /// - Returns: The encoded JSON string
    static func encodeToString<T: Encodable>(_ value: T, prettyPrinted: Bool = true) throws -> String {
        let data = try encode(value, prettyPrinted: prettyPrinted)
        guard let string = String(data: data, encoding: .utf8) else {
            throw JSONCodingError.invalidData
        }
        return string
    }

    /// Decodes a Decodable type from a JSON string
    /// - Parameters:
    ///   - type: The type to decode to
    ///   - string: The JSON string to decode
    /// - Returns: The decoded value
    static func decodeFromString<T: Decodable>(_ type: T.Type, from string: String) throws -> T {
        guard let data = string.data(using: .utf8) else {
            throw JSONCodingError.invalidData
        }
        return try decode(type, from: data)
    }

    /// Loads and decodes a Decodable type from a file in a bundle
    /// - Parameters:
    ///   - filename: The name of the file (without extension)
    ///   - bundle: The bundle to search in (default: .main)
    ///   - fileExtension: The file extension (default: "json")
    /// - Returns: The decoded value
    static func jsonFromFile<T: Decodable>(
        _ filename: String,
        in bundle: Bundle = .main,
        fileExtension: String = "json"
    ) throws -> T {
        guard let url = bundle.url(forResource: filename, withExtension: fileExtension) else {
            throw JSONCodingError.fileNotFound(filename)
        }

        let data = try Data(contentsOf: url)
        return try decode(T.self, from: data)
    }
}
