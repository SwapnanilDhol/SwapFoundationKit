/*****************************************************************************
 * Networking.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import Foundation

public enum NetworkLogLevel: String, Sendable, CaseIterable {
    case none
    case error
    case warning
    case info
    case debug

    fileprivate func allows(_ level: LogLevel) -> Bool {
        switch self {
        case .none:
            return false
        case .error:
            return level >= .error
        case .warning:
            return level >= .warning
        case .info:
            return level >= .info
        case .debug:
            return true
        }
    }
}

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
        let normalizedBaseURL = baseURL.trimmingCharacters(in: .whitespacesAndNewlines)
        let baseURLComponents = URLComponents(string: "\(scheme)://\(normalizedBaseURL)")

        if let host = baseURLComponents?.host {
            urlComponents.host = host
            urlComponents.port = baseURLComponents?.port
            let basePath = baseURLComponents?.path ?? ""
            urlComponents.path = Self.normalizedPath(basePath: basePath, requestPath: path)
        } else {
            urlComponents.host = normalizedBaseURL
            urlComponents.path = Self.normalizedPath(basePath: "", requestPath: path)
        }
        urlComponents.queryItems = parameters?.compactMap { URLQueryItem(name: $0.key, value: $0.value) }

        return urlComponents.url
    }

    private static func normalizedPath(basePath: String, requestPath: String) -> String {
        let sanitizedBasePath = basePath == "/" ? "" : basePath.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let sanitizedRequestPath = requestPath.trimmingCharacters(in: CharacterSet(charactersIn: "/"))

        let pathComponents = [sanitizedBasePath, sanitizedRequestPath]
            .filter { !$0.isEmpty }

        return "/" + pathComponents.joined(separator: "/")
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

/// Download response containing file location and response metadata.
public struct NetworkDownloadResponse {
    /// Final file location chosen by the caller.
    public let fileURL: URL
    /// The HTTP response object.
    public let response: HTTPURLResponse
    /// The request that was executed.
    public let request: URLRequest

    /// HTTP status code of the response.
    public var statusCode: Int { response.statusCode }

    /// Whether the request was successful (200-299).
    public var isSuccessful: Bool { (200...299).contains(statusCode) }

    /// Content type from response headers.
    public var contentType: String? { response.value(forHTTPHeaderField: "Content-Type") }

    /// Expected content length reported by the server, or `NSURLSessionTransferSizeUnknown`.
    public var expectedContentLength: Int64 { response.expectedContentLength }

    /// File size on disk for the final downloaded file.
    public var downloadedFileSize: Int64 {
        FileManager.default.fileSize(at: fileURL.path)
    }
}

/// Rich progress information for an in-flight download.
public struct NetworkDownloadProgress: Sendable {
    public let bytesWritten: Int64
    public let totalBytesWritten: Int64
    public let totalBytesExpectedToWrite: Int64

    /// Fraction completed when the server provides a valid expected size.
    public var fractionCompleted: Double? {
        guard totalBytesExpectedToWrite > 0 else { return nil }
        return Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
    }

    public init(
        bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        self.bytesWritten = bytesWritten
        self.totalBytesWritten = totalBytesWritten
        self.totalBytesExpectedToWrite = totalBytesExpectedToWrite
    }
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

extension NetworkError {
    static func from(_ error: Error) -> NetworkError {
        if let networkError = error as? NetworkError {
            return networkError
        }

        if let urlError = error as? URLError {
            switch urlError.code {
            case .timedOut:
                return .timeout
            case .notConnectedToInternet, .networkConnectionLost:
                return .noInternetConnection
            case .cancelled:
                return .cancelled
            default:
                return .requestFailed(urlError)
            }
        }

        return .requestFailed(error)
    }
}

public typealias HTTPClientError = NetworkError

/// HTTP client for executing network requests
public final class HTTPClient {
    /// Shared singleton instance
    public static let shared = HTTPClient()

    /// URLSession instance used for network requests
    public let session: URLSession
    private let sessionPerformer: any SFKURLSessionPerforming

    /// Default headers to include in all requests
    public var defaultHeaders: [String: String] = [
        "Content-Type": "application/json",
        "Accept": "application/json"
    ]

    /// Controls how verbosely the client logs request and response details.
    public var networkLogLevel: NetworkLogLevel = .none

    /// Initialize with custom URLSession configuration
    public init(configuration: URLSessionConfiguration = .default) {
        let components = SFKPulseService.makeSession(configuration: configuration)
        self.session = components.session
        self.sessionPerformer = components.performer
    }

    /// Execute a network request
    /// - Parameter request: The network request to execute
    /// - Returns: NetworkResponse containing the result
    /// - Throws: NetworkError if the request fails
    public func execute(_ request: NetworkRequest) async throws -> NetworkResponse {
        let finalRequest = try makeURLRequest(from: request)
        logRequest(finalRequest)

        do {
            let (data, response) = try await sessionPerformer.data(for: finalRequest)

            guard let httpResponse = response as? HTTPURLResponse else {
                log(.error, "Received non-HTTP response for \(finalRequest.httpMethod ?? "REQUEST") \(finalRequest.url?.absoluteString ?? "unknown URL")")
                throw NetworkError.invalidResponse
            }

            let networkResponse = NetworkResponse(data: data, response: httpResponse, request: finalRequest)
            logResponse(networkResponse)

            guard networkResponse.isSuccessful else {
                log(
                    .error,
                    "Request failed with HTTP \(httpResponse.statusCode) for \(finalRequest.httpMethod ?? "REQUEST") \(finalRequest.url?.absoluteString ?? "unknown URL")\(formattedBodySuffix(data))"
                )
                throw NetworkError.httpError(statusCode: httpResponse.statusCode, data: data)
            }

            return networkResponse
        } catch let error as URLError {
            log(.error, "Transport error for \(finalRequest.httpMethod ?? "REQUEST") \(finalRequest.url?.absoluteString ?? "unknown URL"): \(error.localizedDescription)")
            throw NetworkError.from(error)
        } catch let error as NetworkError {
            throw error
        } catch {
            log(.error, "Unexpected request failure for \(finalRequest.httpMethod ?? "REQUEST") \(finalRequest.url?.absoluteString ?? "unknown URL"): \(error.localizedDescription)")
            throw NetworkError.from(error)
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

    /// Downloads a response body to the given file destination.
    /// - Parameters:
    ///   - request: The network request to execute.
    ///   - destination: Final file location for the downloaded contents.
    ///   - progressHandler: Optional callback for fractional progress when the server provides content length.
    /// - Returns: Download metadata including the final file URL and HTTP response.
    /// - Throws: NetworkError if request creation, transport, response validation, or file writing fails.
    public func download(
        _ request: NetworkRequest,
        to destination: URL,
        progress: ((NetworkDownloadProgress) -> Void)? = nil,
        progressHandler: ((Double) -> Void)? = nil
    ) async throws -> NetworkDownloadResponse {
        let finalRequest = try makeURLRequest(from: request)
        logRequest(finalRequest)

        let fileManager = FileManager.default
        let destinationDirectory = destination.deletingLastPathComponent()

        do {
            if usesCustomProtocolTransport {
                let (data, response) = try await sessionPerformer.data(for: finalRequest)

                guard let httpResponse = response as? HTTPURLResponse else {
                    log(.error, "Received non-HTTP download response for \(finalRequest.httpMethod ?? "REQUEST") \(finalRequest.url?.absoluteString ?? "unknown URL")")
                    throw NetworkError.invalidResponse
                }

                guard (200...299).contains(httpResponse.statusCode) else {
                    log(.error, "Download failed with HTTP \(httpResponse.statusCode) for \(finalRequest.httpMethod ?? "REQUEST") \(finalRequest.url?.absoluteString ?? "unknown URL")")
                    throw NetworkError.httpError(statusCode: httpResponse.statusCode, data: data)
                }

                try fileManager.createDirectoryIfNeeded(at: destinationDirectory)
                if fileManager.fileExists(at: destination) {
                    try fileManager.removeItem(at: destination)
                }
                try data.write(to: destination, options: .atomic)

                let snapshot = NetworkDownloadProgress(
                    bytesWritten: Int64(data.count),
                    totalBytesWritten: Int64(data.count),
                    totalBytesExpectedToWrite: Int64(data.count)
                )
                progress?(snapshot)
                progressHandler?(1.0)

                return NetworkDownloadResponse(
                    fileURL: destination,
                    response: httpResponse,
                    request: finalRequest
                )
            }

            let (temporaryURL, response) = try await performDownload(
                request: finalRequest,
                progress: progress,
                progressHandler: progressHandler
            )

            guard let httpResponse = response as? HTTPURLResponse else {
                log(.error, "Received non-HTTP download response for \(finalRequest.httpMethod ?? "REQUEST") \(finalRequest.url?.absoluteString ?? "unknown URL")")
                throw NetworkError.invalidResponse
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                log(.error, "Download failed with HTTP \(httpResponse.statusCode) for \(finalRequest.httpMethod ?? "REQUEST") \(finalRequest.url?.absoluteString ?? "unknown URL")")
                throw NetworkError.httpError(statusCode: httpResponse.statusCode, data: nil)
            }

            try fileManager.createDirectoryIfNeeded(at: destinationDirectory)
            if fileManager.fileExists(at: destination) {
                try fileManager.removeItem(at: destination)
            }
            try fileManager.moveFile(from: temporaryURL, to: destination)

            return NetworkDownloadResponse(
                fileURL: destination,
                response: httpResponse,
                request: finalRequest
            )
        } catch let error as NetworkError {
            fileManager.removeItemSafely(at: destination)
            throw error
        } catch {
            fileManager.removeItemSafely(at: destination)
            log(.error, "Download transport failure for \(finalRequest.httpMethod ?? "REQUEST") \(finalRequest.url?.absoluteString ?? "unknown URL"): \(error.localizedDescription)")
            throw NetworkError.from(error)
        }
    }
}

/// Holds a download task so cancellation handlers can reference it without capturing a mutable local.
private final class DownloadTaskBox: @unchecked Sendable {
    var task: URLSessionDownloadTask?
}

private extension HTTPClient {
    var usesCustomProtocolTransport: Bool {
        !(session.configuration.protocolClasses ?? []).isEmpty
    }

    func makeURLRequest(from request: NetworkRequest) throws -> URLRequest {
        guard let urlRequest = request.request else {
            log(.error, "Failed to create URLRequest for \(request.method.rawValue) \(request.baseURL)\(request.path)")
            throw NetworkError.invalidURL
        }

        var finalRequest = urlRequest
        var allHeaders = defaultHeaders
        if let requestHeaders = request.headers {
            allHeaders.merge(requestHeaders) { (_, new) in new }
        }
        finalRequest.allHTTPHeaderFields = allHeaders
        return finalRequest
    }

    func performDownload(
        request: URLRequest,
        progress: ((NetworkDownloadProgress) -> Void)?,
        progressHandler: ((Double) -> Void)?
    ) async throws -> (URL, URLResponse) {
        var observation: NSKeyValueObservation?
        let taskBox = DownloadTaskBox()
        var lastReportedCompleted: Int64 = 0

        return try await withTaskCancellationHandler(operation: {
            try await withCheckedThrowingContinuation { continuation in
                let downloadTask = session.downloadTask(with: request) { temporaryURL, response, error in
                    observation?.invalidate()

                    if let error {
                        continuation.resume(throwing: error)
                        return
                    }

                    guard let temporaryURL, let response else {
                        continuation.resume(throwing: NetworkError.invalidResponse)
                        return
                    }

                    continuation.resume(returning: (temporaryURL, response))
                }
                taskBox.task = downloadTask

                if progress != nil || progressHandler != nil {
                    observation = downloadTask.progress.observe(\.completedUnitCount, options: [.initial, .new]) { taskProgress, change in
                        let totalWritten = change.newValue ?? taskProgress.completedUnitCount
                        let snapshot = NetworkDownloadProgress(
                            bytesWritten: max(0, totalWritten - lastReportedCompleted),
                            totalBytesWritten: totalWritten,
                            totalBytesExpectedToWrite: taskProgress.totalUnitCount
                        )
                        lastReportedCompleted = totalWritten
                        progress?(snapshot)
                        if let fraction = snapshot.fractionCompleted {
                            progressHandler?(fraction)
                        }
                    }
                }

                downloadTask.resume()
            }
        }, onCancel: {
            taskBox.task?.cancel()
        })
    }

    func log(_ level: LogLevel, _ message: String) {
        guard networkLogLevel.allows(level) else { return }

        switch level {
        case .debug:
            Logger.debug(message, context: "Network")
        case .info:
            Logger.info(message, context: "Network")
        case .warning:
            Logger.warning(message, context: "Network")
        case .error:
            Logger.error(message, context: "Network")
        }
    }

    func logRequest(_ request: URLRequest) {
        let method = request.httpMethod ?? "REQUEST"
        let url = request.url?.absoluteString ?? "unknown URL"
        log(.info, "→ \(method) \(url)")

        if networkLogLevel.allows(.debug) {
            let headerSummary = sanitizedHeaders(request.allHTTPHeaderFields)
            log(.debug, "Headers: \(headerSummary)")
            log(.debug, "Cache policy: \(String(describing: request.cachePolicy)), timeout: \(request.timeoutInterval)s")

            if let body = request.httpBody, !body.isEmpty {
                log(.debug, "Body: \(formattedBody(body))")
            }
        }
    }

    func logResponse(_ response: NetworkResponse) {
        let method = response.request.httpMethod ?? "REQUEST"
        let url = response.request.url?.absoluteString ?? "unknown URL"
        let status = response.statusCode
        let responseSize = ByteCountFormatter.string(fromByteCount: Int64(response.data.count), countStyle: .file)

        let level: LogLevel = response.isSuccessful ? .info : .warning
        log(level, "← \(status) \(method) \(url) [\(responseSize)]")

        if networkLogLevel.allows(.debug) {
            let headerSummary = sanitizedResponseHeaders(response.response.allHeaderFields)
            log(.debug, "Response headers: \(headerSummary)")

            if !response.data.isEmpty {
                log(.debug, "Response body: \(formattedBody(response.data))")
            }
        }
    }

    func sanitizedHeaders(_ headers: [String: String]?) -> String {
        guard let headers, !headers.isEmpty else {
            return "none"
        }

        let redactedKeys: Set<String> = ["authorization", "cookie", "set-cookie", "x-api-key", "proxy-authorization"]
        let sanitized = headers
            .map { key, value in
                let safeValue = redactedKeys.contains(key.lowercased()) ? "<redacted>" : value
                return "\(key)=\(safeValue)"
            }
            .sorted()

        return sanitized.joined(separator: ", ")
    }

    func sanitizedResponseHeaders(_ headers: [AnyHashable: Any]) -> String {
        guard !headers.isEmpty else {
            return "none"
        }

        let stringHeaders = headers.reduce(into: [String: String]()) { partialResult, item in
            guard let key = item.key as? String else { return }
            partialResult[key] = String(describing: item.value)
        }

        return sanitizedHeaders(stringHeaders)
    }

    func formattedBody(_ data: Data, maxLength: Int = 2_048) -> String {
        guard !data.isEmpty else { return "<empty>" }

        let preview = String(decoding: data.prefix(maxLength), as: UTF8.self)
        if data.count > maxLength {
            return "\(preview)… [truncated \(data.count - maxLength) bytes]"
        }
        return preview
    }

    func formattedBodySuffix(_ data: Data) -> String {
        guard networkLogLevel.allows(.debug), !data.isEmpty else {
            return ""
        }
        return " | body: \(formattedBody(data, maxLength: 512))"
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

    /// Download a file using the common URL-component request shape.
    /// - Parameters:
    ///   - scheme: URL scheme (default: "https")
    ///   - baseURL: Base URL for the request
    ///   - path: Path component
    ///   - destination: Final file location for the downloaded contents
    ///   - parameters: Query parameters
    ///   - headers: Additional headers
    ///   - progressHandler: Optional callback for fractional progress when available
    /// - Returns: Download metadata for the completed file
    func download(scheme: String = "https",
                  baseURL: String,
                  path: String,
                  to destination: URL,
                  parameters: [String: String]? = nil,
                  headers: [String: String]? = nil,
                  progress: ((NetworkDownloadProgress) -> Void)? = nil,
                  progressHandler: ((Double) -> Void)? = nil) async throws -> NetworkDownloadResponse {
        try await download(
            SimpleRequest(
                scheme: scheme,
                baseURL: baseURL,
                path: path,
                method: .get,
                parameters: parameters,
                headers: headers,
                body: nil
            ),
            to: destination,
            progress: progress,
            progressHandler: progressHandler
        )
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
