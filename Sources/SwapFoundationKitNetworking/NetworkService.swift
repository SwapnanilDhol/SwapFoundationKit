/*****************************************************************************
 * NetworkService.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import Foundation
import Network
import Combine
import SwapFoundationKit

/// Service for handling network operations, reachability, and basic networking utilities
@MainActor
public final class NetworkService: ObservableObject {
    public typealias ConnectionType = NetworkMonitor.ConnectionType

    public static let shared = NetworkService()

    @Published public private(set) var isConnected = false
    @Published public private(set) var connectionType: ConnectionType = .unknown

    /// Headers returned by this instance's backend provider.
    public var backendDefaultHeaders: [String: String] {
        backendHeadersProvider?() ?? [:]
    }

    private let monitor: NetworkMonitor
    private var monitorCancellables = Set<AnyCancellable>()
    private let client: HTTPClient
    private let backendHeadersProvider: (() -> [String: String])?
    private let backendOrigins: Set<HTTPOrigin>
    
    public init(
        client: HTTPClient = .shared,
        monitor: NetworkMonitor? = nil,
        backendHeadersProvider: (() -> [String: String])? = nil,
        backendOrigins: [URL] = []
    ) {
        self.client = client
        self.monitor = monitor ?? NetworkMonitor()
        self.backendHeadersProvider = backendHeadersProvider
        self.backendOrigins = Set(backendOrigins.compactMap(HTTPOrigin.init(url:)))
        self.isConnected = self.monitor.isConnected
        self.connectionType = self.monitor.connectionType
        setupNetworkMonitoring()
    }
    
    // MARK: - Network Monitoring
    
    private func setupNetworkMonitoring() {
        monitor.$isConnected
            .sink { [weak self] value in self?.isConnected = value }
            .store(in: &monitorCancellables)
        monitor.$connectionType
            .sink { [weak self] value in self?.connectionType = value }
            .store(in: &monitorCancellables)
    }

    // MARK: - Basic HTTP Operations
    
    /// Performs a GET request
    /// - Parameters:
    ///   - url: The URL to request
    ///   - headers: Additional headers
    ///   - timeout: Request timeout in seconds
    /// - Returns: The response data
    /// - Throws: NetworkError
    public func get(from url: URL, headers: [String: String] = [:], timeout: TimeInterval = 30) async throws -> Data {
        return try await performRequest(
            BasicURLNetworkRequest(
                url: url,
                method: .get,
                headers: headers,
                timeoutInterval: timeout
            )
        )
    }
    
    /// Performs a POST request
    /// - Parameters:
    ///   - url: The URL to request
    ///   - body: The request body data
    ///   - headers: Additional headers
    ///   - timeout: Request timeout in seconds
    /// - Returns: The response data
    /// - Throws: NetworkError
    public func post(to url: URL, body: Data, headers: [String: String] = [:], timeout: TimeInterval = 30) async throws -> Data {
        var requestHeaders = headers
        if !requestHeaders.keys.contains(where: { $0.caseInsensitiveCompare("Content-Type") == .orderedSame }) {
            requestHeaders["Content-Type"] = "application/json"
        }

        return try await performRequest(
            BasicURLNetworkRequest(
                url: url,
                method: .post,
                headers: requestHeaders,
                body: body,
                timeoutInterval: timeout
            )
        )
    }
    
    /// Performs a PUT request
    /// - Parameters:
    ///   - url: The URL to request
    ///   - body: The request body data
    ///   - headers: Additional headers
    ///   - timeout: Request timeout in seconds
    /// - Returns: The response data
    /// - Throws: NetworkError
    public func put(to url: URL, body: Data, headers: [String: String] = [:], timeout: TimeInterval = 30) async throws -> Data {
        var requestHeaders = headers
        if !requestHeaders.keys.contains(where: { $0.caseInsensitiveCompare("Content-Type") == .orderedSame }) {
            requestHeaders["Content-Type"] = "application/json"
        }

        return try await performRequest(
            BasicURLNetworkRequest(
                url: url,
                method: .put,
                headers: requestHeaders,
                body: body,
                timeoutInterval: timeout
            )
        )
    }
    
    /// Performs a DELETE request
    /// - Parameters:
    ///   - url: The URL to request
    ///   - timeout: Request timeout in seconds
    /// - Returns: The response data
    /// - Throws: NetworkError
    public func delete(from url: URL, timeout: TimeInterval = 30) async throws -> Data {
        return try await performRequest(
            BasicURLNetworkRequest(
                url: url,
                method: .delete,
                timeoutInterval: timeout
            )
        )
    }
    
    // MARK: - JSON Operations
    
    /// Performs a GET request and decodes the JSON response
    /// - Parameters:
    ///   - url: The URL to request
    ///   - type: The type to decode to
    ///   - decoder: JSON decoder to use
    ///   - timeout: Request timeout in seconds
    /// - Returns: The decoded object
    /// - Throws: NetworkError
    public func get<T: Decodable>(from url: URL, as type: T.Type, decoder: JSONDecoder = JSONDecoder(), timeout: TimeInterval = 30) async throws -> T {
        let data = try await get(from: url, timeout: timeout)
        
        do {
            return try decoder.decode(type, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
    
    /// Performs a POST request with JSON body and decodes the response
    /// - Parameters:
    ///   - url: The URL to request
    ///   - body: The object to encode as JSON
    ///   - responseType: The type to decode the response to
    ///   - encoder: JSON encoder to use
    ///   - decoder: JSON decoder to use
    ///   - timeout: Request timeout in seconds
    /// - Returns: The decoded response object
    /// - Throws: NetworkError
    public func post<T: Encodable, U: Decodable>(to url: URL, body: T, responseType: U.Type, encoder: JSONEncoder = JSONEncoder(), decoder: JSONDecoder = JSONDecoder(), timeout: TimeInterval = 30) async throws -> U {
        let bodyData: Data
        
        do {
            bodyData = try encoder.encode(body)
        } catch {
            throw NetworkError.requestFailed(error)
        }
        
        let responseData = try await post(to: url, body: bodyData, timeout: timeout)
        
        do {
            return try decoder.decode(responseType, from: responseData)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
    
    // MARK: - File Download
    
    /// Downloads a file from a URL
    /// - Parameters:
    ///   - url: The URL to download from
    ///   - destination: The destination URL
    ///   - expectedBytes: Optional expected file size for integrity validation (20% tolerance)
    ///   - progressHandler: Progress callback
    /// - Returns: The downloaded file URL
    /// - Throws: NetworkError
    public func downloadFile(from url: URL, to destination: URL, expectedBytes: Int64? = nil, progressHandler: ((Double) -> Void)? = nil) async throws -> URL {
        guard Self.isValidHTTPURL(url) else {
            throw NetworkError.invalidURL
        }
        let request = BasicURLNetworkRequest(url: url, method: .get)
        let response = try await client.download(request, to: destination, progressHandler: progressHandler)

        if let expectedBytes {
            let values = try response.fileURL.resourceValues(forKeys: [.fileSizeKey])
            let actualBytes = Int64(values.fileSize ?? 0)
            guard abs(actualBytes - expectedBytes) < max(1_000_000, expectedBytes / 20) else {
                throw NetworkError.invalidResponse
            }
        }

        return response.fileURL
    }
    
    // MARK: - Private Methods

    private func performRequest(_ request: NetworkRequest) async throws -> Data {
        guard let url = request.url, Self.isValidHTTPURL(url) else {
            throw NetworkError.invalidURL
        }
        let scopedBackendHeaders = backendHeaders(for: request)
        let headers = sfkMergedHTTPHeaders(scopedBackendHeaders, overriding: request.headers ?? [:])

        let finalRequest: NetworkRequest
        if headers.isEmpty {
            finalRequest = request
        } else {
            finalRequest = HeaderOverrideRequest(base: request, headers: headers)
        }

        let redirectDelegate: URLSessionTaskDelegate?
        if scopedBackendHeaders.isEmpty {
            redirectDelegate = nil
        } else {
            guard let url = request.url,
                  let delegate = SameOriginRedirectDelegate(url: url) else {
                throw NetworkError.invalidURL
            }
            redirectDelegate = delegate
        }

        let response = try await client.execute(finalRequest, delegate: redirectDelegate)
        return response.data
    }

    private static func isValidHTTPURL(_ url: URL) -> Bool {
        guard let scheme = url.scheme?.lowercased(),
              scheme == "http" || scheme == "https",
              let host = url.host,
              !host.isEmpty else {
            return false
        }
        return true
    }

    /// Returns `backendDefaultHeaders` only when a provider is set and the request's URL matches
    /// one of this instance's allowed backend origins.
    private func backendHeaders(for request: NetworkRequest) -> [String: String] {
        guard backendHeadersProvider != nil else { return [:] }
        guard let url = request.url else { return [:] }

        guard let origin = HTTPOrigin(url: url), backendOrigins.contains(origin) else { return [:] }

        return backendDefaultHeaders
    }
}

/// Wraps a request to apply merged headers without knowing its concrete request type.
private struct HeaderOverrideRequest: NetworkRequest {
    let base: NetworkRequest
    let headers: [String: String]?

    var scheme: String { base.scheme }
    var baseURL: String { base.baseURL }
    var path: String { base.path }
    var method: HTTPMethod { base.method }
    var parameters: [String: String]? { base.parameters }
    var body: Data? { base.body }
    var timeoutInterval: TimeInterval { base.timeoutInterval }
    var cachePolicy: URLRequest.CachePolicy { base.cachePolicy }
    var explicitURL: URL? { base.explicitURL }
    var usesClientDefaultHeaders: Bool { base.usesClientDefaultHeaders }
}

private struct HTTPOrigin: Hashable {
    let scheme: String
    let host: String
    let port: Int

    init?(url: URL) {
        guard let scheme = url.scheme?.lowercased(),
              let host = url.host?.lowercased(),
              let defaultPort = Self.defaultPort(for: scheme),
              url.user == nil,
              url.password == nil else { return nil }
        self.scheme = scheme
        self.host = host
        self.port = url.port ?? defaultPort
    }

    init?(host: String, scheme: String, port: Int?) {
        let normalizedScheme = scheme.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let normalizedHost = host.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard let defaultPort = Self.defaultPort(for: normalizedScheme),
              !normalizedHost.isEmpty else { return nil }
        let normalizedPort = port ?? defaultPort
        guard (1...65_535).contains(normalizedPort) else { return nil }
        self.scheme = normalizedScheme
        self.host = normalizedHost
        self.port = normalizedPort
    }

    private static func defaultPort(for scheme: String) -> Int? {
        switch scheme {
        case "https": return 443
        case "http": return 80
        default: return nil
        }
    }
}

/// Prevents origin-scoped backend headers from following a redirect to a different effective
/// scheme, host, or port. Returning `nil` cancels the redirect before URLSession sends it.
private final class SameOriginRedirectDelegate: NSObject, URLSessionTaskDelegate, @unchecked Sendable {
    private let origin: HTTPOrigin

    init?(url: URL) {
        guard let origin = HTTPOrigin(url: url) else { return nil }
        self.origin = origin
    }

    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        willPerformHTTPRedirection response: HTTPURLResponse,
        newRequest request: URLRequest,
        completionHandler: @escaping (URLRequest?) -> Void
    ) {
        guard let destination = request.url, let destinationOrigin = HTTPOrigin(url: destination), destinationOrigin == origin else {
            completionHandler(nil)
            return
        }
        completionHandler(request)
    }
}

private struct BasicURLNetworkRequest: NetworkRequest {
    let scheme: String
    let baseURL: String
    let path: String
    let method: HTTPMethod
    let parameters: [String: String]?
    let headers: [String: String]?
    let body: Data?
    let timeoutInterval: TimeInterval
    let cachePolicy: URLRequest.CachePolicy
    let explicitURL: URL?

    init(
        url: URL,
        method: HTTPMethod,
        parameters: [String: String]? = nil,
        headers: [String: String]? = nil,
        body: Data? = nil,
        timeoutInterval: TimeInterval = 30,
        cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy
    ) {
        self.scheme = url.scheme ?? "https"
        let host = url.host ?? ""
        if let port = url.port {
            self.baseURL = "\(host):\(port)"
        } else {
            self.baseURL = host
        }
        self.path = url.path.isEmpty ? "/" : url.path
        self.method = method
        self.parameters = parameters ?? Self.queryParameters(from: url)
        self.headers = headers
        self.body = body
        self.timeoutInterval = timeoutInterval
        self.cachePolicy = cachePolicy
        self.explicitURL = url
    }

    private static func queryParameters(from url: URL) -> [String: String]? {
        guard let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: true)?.queryItems else {
            return nil
        }

        var parameters: [String: String] = [:]
        for item in queryItems {
            if let value = item.value {
                parameters[item.name] = value
            }
        }
        return parameters.isEmpty ? nil : parameters
    }
}

// MARK: - Network Reachability

extension NetworkService {
    
    /// Checks if the device has internet connectivity
    /// - Returns: True if connected to the internet
    public var hasInternetConnection: Bool {
        return isConnected
    }
    
    /// Gets the current connection type
    /// - Returns: The current connection type
    public var currentConnectionType: ConnectionType {
        return connectionType
    }
    
    /// Waits for internet connectivity with a timeout
    /// - Parameter timeout: Maximum time to wait in seconds
    /// - Returns: True if connection is established within timeout
    public func waitForConnection(timeout: TimeInterval = 10) async -> Bool {
        guard !Task.isCancelled else { return false }
        if isConnected {
            return true
        }
        
        let startTime = Date()
        while !isConnected && Date().timeIntervalSince(startTime) < timeout {
            guard !Task.isCancelled else { return false }
            do {
                try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
            } catch {
                // Task.sleep throws on cancellation; don't keep polling a cancelled task.
                return false
            }
        }

        return !Task.isCancelled && isConnected
    }
}

// MARK: - Convenience Extensions

extension NetworkService {
    
    /// Performs a GET request to a string URL
    /// - Parameters:
    ///   - urlString: The URL string
    ///   - timeout: Request timeout in seconds
    /// - Returns: The response data
    /// - Throws: NetworkError
    public func get(from urlString: String, timeout: TimeInterval = 30) async throws -> Data {
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        return try await get(from: url, timeout: timeout)
    }
    
    /// Performs a POST request to a string URL
    /// - Parameters:
    ///   - urlString: The URL string
    ///   - body: The request body data
    ///   - headers: Additional headers
    ///   - timeout: Request timeout in seconds
    /// - Returns: The response data
    /// - Throws: NetworkError
    public func post(to urlString: String, body: Data, headers: [String: String] = [:], timeout: TimeInterval = 30) async throws -> Data {
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        return try await post(to: url, body: body, headers: headers, timeout: timeout)
    }
}
