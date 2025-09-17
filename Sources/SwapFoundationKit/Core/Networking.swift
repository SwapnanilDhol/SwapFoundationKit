import Foundation

/// HTTP methods supported by the networking module
public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
    case head = "HEAD"
}

/// Protocol defining a network request
public protocol NetworkRequest {
    /// Scheme for the request (e.g., "https")
    var scheme: String { get }
    /// Base URL for the request (e.g., "api.example.com")
    var baseURL: String { get }
    /// Path component of the URL (e.g., "/users/123")
    var path: String { get }
    /// HTTP method for the request
    var method: HTTPMethod { get }
    /// Query parameters to append to the URL
    var parameters: [String: String]? { get }
    /// HTTP headers to include in the request
    var headers: [String: String]? { get }
    /// Body data for the request
    var body: Data? { get }
    /// Timeout interval for the request
    var timeoutInterval: TimeInterval { get }
    /// Cache policy for the request
    var cachePolicy: URLRequest.CachePolicy { get }
}

public extension NetworkRequest {
    /// Default timeout interval (30 seconds)
    var timeoutInterval: TimeInterval { 30.0 }
    /// Default cache policy (.useProtocolCachePolicy)
    var cachePolicy: URLRequest.CachePolicy { .useProtocolCachePolicy }

    /// Computed URLRequest from the network request properties
    var request: URLRequest? {
        guard let url else {
            // URL construction failed due to invalid scheme or baseURL
            return nil
        }
        var request = URLRequest(url: url,
                               cachePolicy: cachePolicy,
                               timeoutInterval: timeoutInterval)
        request.httpMethod = method.rawValue.uppercased()
        request.allHTTPHeaderFields = headers
        if let body {
            request.httpBody = body
        }
        return request
    }

    /// Computed URL from the network request properties
    var url: URL? {
        // Validate required components
        guard !scheme.isEmpty, !baseURL.isEmpty else {
            return nil
        }

        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = baseURL
        urlComponents.path = path
        urlComponents.queryItems = parameters?.compactMap { URLQueryItem(name: $0.key, value: $0.value) }

        return urlComponents.url
    }
}

/// Network response containing data and metadata
public struct NetworkResponse {
    /// The data returned from the network request
    public let data: Data
    /// The HTTP response object
    public let response: HTTPURLResponse
    /// The request that was executed
    public let request: URLRequest

    /// HTTP status code of the response
    public var statusCode: Int { response.statusCode }

    /// Whether the request was successful (200-299)
    public var isSuccessful: Bool { (200...299).contains(statusCode) }

    /// Content type from response headers
    public var contentType: String? { response.value(forHTTPHeaderField: "Content-Type") }
}

/// Network error types
public enum NetworkError: Error, LocalizedError {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case httpError(statusCode: Int, data: Data?)
    case decodingError(Error)
    case timeout
    case noInternetConnection
    case cancelled

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .requestFailed(let error):
            return "Request failed: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let statusCode, _):
            return "HTTP Error: \(statusCode)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .timeout:
            return "Request timed out"
        case .noInternetConnection:
            return "No internet connection"
        case .cancelled:
            return "Request was cancelled"
        }
    }
}

/// HTTP client for executing network requests
public final class HTTPClient {
    /// Shared singleton instance
    public static let shared = HTTPClient()

    /// URLSession instance used for network requests
    public let session: URLSession

    /// Default headers to include in all requests
    public var defaultHeaders: [String: String] = [
        "Content-Type": "application/json",
        "Accept": "application/json"
    ]

    /// Initialize with custom URLSession configuration
    public init(configuration: URLSessionConfiguration = .default) {
        self.session = URLSession(configuration: configuration)
    }

    /// Execute a network request
    /// - Parameter request: The network request to execute
    /// - Returns: NetworkResponse containing the result
    /// - Throws: NetworkError if the request fails
    public func execute(_ request: NetworkRequest) async throws -> NetworkResponse {
        guard let urlRequest = request.request else {
            throw NetworkError.invalidURL
        }

        // Merge default headers with request headers
        var finalRequest = urlRequest
        var allHeaders = defaultHeaders
        if let requestHeaders = request.headers {
            allHeaders.merge(requestHeaders) { (_, new) in new }
        }
        finalRequest.allHTTPHeaderFields = allHeaders

        do {
            let (data, response) = try await session.data(for: finalRequest)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }

            let networkResponse = NetworkResponse(data: data, response: httpResponse, request: finalRequest)

            guard networkResponse.isSuccessful else {
                throw NetworkError.httpError(statusCode: httpResponse.statusCode, data: data)
            }

            return networkResponse
        } catch let error as URLError {
            switch error.code {
            case .timedOut:
                throw NetworkError.timeout
            case .notConnectedToInternet, .networkConnectionLost:
                throw NetworkError.noInternetConnection
            case .cancelled:
                throw NetworkError.cancelled
            default:
                throw NetworkError.requestFailed(error)
            }
        } catch {
            throw NetworkError.requestFailed(error)
        }
    }

    /// Execute a network request and decode the response as JSON
    /// - Parameters:
    ///   - request: The network request to execute
    ///   - decoder: JSONDecoder to use for decoding
    /// - Returns: Decoded object of type T
    /// - Throws: NetworkError if the request fails or decoding fails
    public func executeAndDecode<T: Decodable>(_ request: NetworkRequest,
                                              decoder: JSONDecoder = JSONDecoder()) async throws -> T {
        let response = try await execute(request)

        do {
            return try decoder.decode(T.self, from: response.data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
}

/// Convenience methods for common HTTP operations
public extension HTTPClient {
    /// Perform a GET request
    /// - Parameters:
    ///   - scheme: URL scheme (default: "https")
    ///   - baseURL: Base URL for the request
    ///   - path: Path component
    ///   - parameters: Query parameters
    ///   - headers: Additional headers
    /// - Returns: NetworkResponse
    func get(scheme: String = "https",
             baseURL: String,
             path: String,
             parameters: [String: String]? = nil,
             headers: [String: String]? = nil) async throws -> NetworkResponse {
        try await execute(SimpleRequest(scheme: scheme,
                                       baseURL: baseURL,
                                       path: path,
                                       method: .get,
                                       parameters: parameters,
                                       headers: headers,
                                       body: nil))
    }

    /// Perform a POST request
    /// - Parameters:
    ///   - scheme: URL scheme (default: "https")
    ///   - baseURL: Base URL for the request
    ///   - path: Path component
    ///   - body: Request body data
    ///   - parameters: Query parameters
    ///   - headers: Additional headers
    /// - Returns: NetworkResponse
    func post(scheme: String = "https",
              baseURL: String,
              path: String,
              body: Data? = nil,
              parameters: [String: String]? = nil,
              headers: [String: String]? = nil) async throws -> NetworkResponse {
        try await execute(SimpleRequest(scheme: scheme,
                                       baseURL: baseURL,
                                       path: path,
                                       method: .post,
                                       parameters: parameters,
                                       headers: headers,
                                       body: body))
    }

    /// Perform a PUT request
    /// - Parameters:
    ///   - scheme: URL scheme (default: "https")
    ///   - baseURL: Base URL for the request
    ///   - path: Path component
    ///   - body: Request body data
    ///   - parameters: Query parameters
    ///   - headers: Additional headers
    /// - Returns: NetworkResponse
    func put(scheme: String = "https",
             baseURL: String,
             path: String,
             body: Data? = nil,
             parameters: [String: String]? = nil,
             headers: [String: String]? = nil) async throws -> NetworkResponse {
        try await execute(SimpleRequest(scheme: scheme,
                                       baseURL: baseURL,
                                       path: path,
                                       method: .put,
                                       parameters: parameters,
                                       headers: headers,
                                       body: body))
    }

    /// Perform a DELETE request
    /// - Parameters:
    ///   - scheme: URL scheme (default: "https")
    ///   - baseURL: Base URL for the request
    ///   - path: Path component
    ///   - parameters: Query parameters
    ///   - headers: Additional headers
    /// - Returns: NetworkResponse
    func delete(scheme: String = "https",
                baseURL: String,
                path: String,
                parameters: [String: String]? = nil,
                headers: [String: String]? = nil) async throws -> NetworkResponse {
        try await execute(SimpleRequest(scheme: scheme,
                                       baseURL: baseURL,
                                       path: path,
                                       method: .delete,
                                       parameters: parameters,
                                       headers: headers,
                                       body: nil))
    }
}

/// Simple network request implementation
private struct SimpleRequest: NetworkRequest {
    let scheme: String
    let baseURL: String
    let path: String
    let method: HTTPMethod
    let parameters: [String: String]?
    let headers: [String: String]?
    let body: Data?
}

// MARK: - JSON Encoding Extensions

public extension Encodable {
    /// Encode the object to JSON Data
    func toJSONData() throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(self)
    }
}

// MARK: - URL Extensions

public extension URL {
    /// Create URL with query parameters
    /// - Parameter parameters: Dictionary of query parameters
    /// - Returns: URL with appended query parameters
    func appendingQueryParameters(_ parameters: [String: String]) -> URL? {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: false)
        let queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        if components?.queryItems != nil {
            components?.queryItems?.append(contentsOf: queryItems)
        } else {
            components?.queryItems = queryItems
        }
        return components?.url
    }
}
