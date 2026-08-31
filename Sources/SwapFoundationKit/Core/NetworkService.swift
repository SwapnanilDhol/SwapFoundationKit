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

/// Service for handling network operations, reachability, and basic networking utilities
@MainActor
public final class NetworkService: ObservableObject {
    public enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case unknown
    }

    public static let shared = NetworkService()

    @Published public private(set) var isConnected = false
    @Published public private(set) var connectionType: ConnectionType = .unknown

    /// Raw headers returned by `backendHeadersProvider`.
    ///
    /// `get(from:)` and `post(to:)` scope these headers to an exact origin registered via
    /// `registerBackendOrigin(host:scheme:port:)` immediately before sending. This property is
    /// only the provider output; reading it does not perform origin filtering. `downloadFile`
    /// currently bypasses this backend-header merge entirely.
    public var backendDefaultHeaders: [String: String] {
        Self.backendHeadersProvider?() ?? [:]
    }

    /// Closure that returns backend headers. Set by the host app at launch.
    /// Example: { ["X-App-User-ID": AppUserID.headerValue] }
    ///
    /// Setting this alone is not enough for headers to reach the wire: `get(from:)`/`post(to:)`
    /// accept arbitrary URLs, so the provider's output is only merged into requests whose origin
    /// was registered via `registerBackendOrigin(host:scheme:port:)`. Without a registered origin,
    /// headers are computed but never applied — call `registerBackendOrigin` alongside this at app
    /// launch. `downloadFile` does not currently apply these headers.
    public static var backendHeadersProvider: (() -> [String: String])?

    /// Registers a backend origin that should receive `backendDefaultHeaders` (e.g. `X-App-User-ID`).
    ///
    /// Call this once at app launch (alongside setting `backendHeadersProvider`) for each origin
    /// that is actually your backend. Without a registered origin, `backendDefaultHeaders` are
    /// never merged into outgoing requests — this prevents them from leaking to arbitrary/
    /// third-party hosts that `get(from:)`/`post(to:)` might be pointed at.
    ///
    /// - Parameters:
    ///   - host: The backend host, e.g. `"api.example.com"`.
    ///   - scheme: The scheme to match. Defaults to `"https"`.
    ///   - port: Optional port to match. When `nil`, the scheme's default port is matched
    ///     (`443` for HTTPS and `80` for HTTP).
    public static func registerBackendOrigin(host: String, scheme: String = "https", port: Int? = nil) {
        SFKBackendOriginRegistry.register(host: host, scheme: scheme, port: port)
    }

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkService")
    private let client: HTTPClient
    
    public init(client: HTTPClient = .shared) {
        self.client = client
        setupNetworkMonitoring()
    }
    
    deinit {
        monitor.cancel()
    }
    
    // MARK: - Network Monitoring
    
    private func setupNetworkMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
                self?.connectionType = self?.determineConnectionType(path) ?? .unknown
            }
        }
        monitor.start(queue: queue)
    }
    
    private func determineConnectionType(_ path: NWPath) -> ConnectionType {
        if path.usesInterfaceType(.wifi) {
            return .wifi
        } else if path.usesInterfaceType(.cellular) {
            return .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            return .ethernet
        } else {
            return .unknown
        }
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
    /// a registered backend origin; otherwise returns an empty dictionary and, when a provider is
    /// set but no origin matched, emits a one-time warning so the omission doesn't look like a
    /// silent no-op forever.
    private func backendHeaders(for request: NetworkRequest) -> [String: String] {
        guard Self.backendHeadersProvider != nil else { return [:] }
        guard let url = request.url else { return [:] }

        guard SFKBackendOriginRegistry.matches(url) else {
            SFKBackendOriginRegistry.warnAboutUnmatchedOriginIfNeeded(for: url)
            return [:]
        }

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

/// Registry that lets a host app declare which origins should receive
/// `NetworkService.backendDefaultHeaders`.
///
/// `NetworkService.get(from:)`/`post(to:)` accept arbitrary caller-supplied URLs, so unconditionally
/// merging backend headers (such as `X-App-User-ID`) into every outgoing request would leak them to
/// third-party hosts. Instead, a host app registers the origin(s) that are actually its backend via
/// `NetworkService.registerBackendOrigin(host:scheme:port:)`, and only requests whose origin matches
/// receive `backendDefaultHeaders`. This mirrors the App Attest "origin restriction" invariant:
/// backend-only headers stay scoped to the backend's own origin.
///
/// This is intentionally a function-based registration rather than a public mutable static
/// property/closure, matching `SFKNetworkInstrumentation`'s registration boundary: it keeps the
/// registration boundary explicit and prevents arbitrary call sites from silently mutating shared
/// state.
public enum SFKBackendOriginRegistry {
    private static let lock = NSLock()
    private static var origins: Set<HTTPOrigin> = []
    private static var didWarnAboutUnmatchedOrigin = false

    /// Registers a backend origin that should receive `NetworkService.backendDefaultHeaders`.
    ///
    /// - Parameters:
    ///   - host: The backend host, e.g. `"api.example.com"`.
    ///   - scheme: The scheme to match. Defaults to `"https"`.
    ///   - port: Optional port to match. When `nil`, the scheme's default port is matched
    ///     (`443` for HTTPS and `80` for HTTP).
    public static func register(host: String, scheme: String = "https", port: Int? = nil) {
        guard let origin = HTTPOrigin(host: host, scheme: scheme, port: port) else { return }
        lock.lock()
        origins.insert(origin)
        lock.unlock()
    }

    static func matches(_ url: URL) -> Bool {
        guard let origin = HTTPOrigin(url: url) else { return false }

        lock.lock()
        let registered = origins
        lock.unlock()

        return registered.contains(origin)
    }

    /// Emits a one-time (per process) warning explaining that backend headers were skipped for
    /// the URL origin because no registered origin matched it. Rate-limited so a host that forgot to
    /// register an origin doesn't get spammed with a warning per request.
    static func warnAboutUnmatchedOriginIfNeeded(for url: URL) {
        lock.lock()
        let alreadyWarned = didWarnAboutUnmatchedOrigin
        didWarnAboutUnmatchedOrigin = true
        lock.unlock()

        guard !alreadyWarned else { return }

        Logger.warning(
            "backendHeadersProvider is set, but origin \(originDescription(for: url)) did not match a registered backend origin, so backend default headers (e.g. X-App-User-ID) were skipped for this request. Call NetworkService.registerBackendOrigin(host:scheme:port:) with your backend's origin to fix this. (Logged once per process.)",
            context: "NetworkService"
        )
    }

    private static func originDescription(for url: URL) -> String {
        if let origin = HTTPOrigin(url: url) {
            return "\(origin.scheme)://\(origin.host):\(origin.port)"
        }
        let scheme = url.scheme?.lowercased() ?? "unknown"
        let host = url.host?.lowercased() ?? "unknown"
        return "\(scheme)://\(host)"
    }

    /// Test-only support to restore default behavior between test cases. Not part of the public API.
    static func resetForTesting() {
        lock.lock()
        origins = []
        didWarnAboutUnmatchedOrigin = false
        lock.unlock()
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
        self.parameters = parameters ?? url.queryParameters
        self.headers = headers
        self.body = body
        self.timeoutInterval = timeoutInterval
        self.cachePolicy = cachePolicy
        self.explicitURL = url
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
        if isConnected {
            return true
        }
        
        let startTime = Date()
        while !isConnected && Date().timeIntervalSince(startTime) < timeout {
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        }
        
        return isConnected
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
