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
    
    public enum NetworkError: Error, LocalizedError {
        case noInternetConnection
        case requestFailed(Error)
        case invalidResponse
        case decodingFailed(Error)
        case timeout
        case serverError(Int)
        
        public var errorDescription: String? {
            switch self {
            case .noInternetConnection:
                return "No internet connection available"
            case .requestFailed(let error):
                return "Request failed: \(error.localizedDescription)"
            case .invalidResponse:
                return "Invalid response from server"
            case .decodingFailed(let error):
                return "Failed to decode response: \(error.localizedDescription)"
            case .timeout:
                return "Request timed out"
            case .serverError(let code):
                return "Server error: \(code)"
            }
        }
    }
    
    public enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case unknown
    }
    
    @Published public private(set) var isConnected = false
    @Published public private(set) var connectionType: ConnectionType = .unknown
    
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
    ///   - timeout: Request timeout in seconds
    /// - Returns: The response data
    /// - Throws: NetworkError
    public func get(from url: URL, timeout: TimeInterval = 30) async throws -> Data {
        guard isConnected else {
            throw NetworkError.noInternetConnection
        }

        return try await performRequest(
            BasicURLNetworkRequest(
                url: url,
                method: .get,
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
        guard isConnected else {
            throw NetworkError.noInternetConnection
        }

        var requestHeaders = headers
        requestHeaders["Content-Type"] = requestHeaders["Content-Type"] ?? "application/json"

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
        guard isConnected else {
            throw NetworkError.noInternetConnection
        }

        var requestHeaders = headers
        requestHeaders["Content-Type"] = requestHeaders["Content-Type"] ?? "application/json"

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
        guard isConnected else {
            throw NetworkError.noInternetConnection
        }

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
            throw NetworkError.decodingFailed(error)
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
            throw NetworkError.decodingFailed(error)
        }
    }
    
    // MARK: - File Download
    
    /// Downloads a file from a URL
    /// - Parameters:
    ///   - url: The URL to download from
    ///   - destination: The destination URL
    ///   - progressHandler: Progress callback
    /// - Returns: The downloaded file URL
    /// - Throws: NetworkError
    public func downloadFile(from url: URL, to destination: URL, progressHandler: ((Double) -> Void)? = nil) async throws -> URL {
        guard isConnected else {
            throw NetworkError.noInternetConnection
        }
        
        let request = BasicURLNetworkRequest(url: url, method: .get)
        guard let urlRequest = request.request else {
            throw NetworkError.invalidResponse
        }

        let (asyncBytes, response) = try await client.session.bytes(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw NetworkError.serverError(httpResponse.statusCode)
        }
        
        let totalBytes = httpResponse.expectedContentLength
        var downloadedBytes: Int64 = 0
        
        let fileHandle = try FileHandle(forWritingTo: destination)
        defer { try? fileHandle.close() }
        
        for try await byte in asyncBytes {
            try fileHandle.write(contentsOf: [byte])
            downloadedBytes += 1
            
            if let progressHandler = progressHandler, totalBytes > 0 {
                let progress = Double(downloadedBytes) / Double(totalBytes)
                progressHandler(progress)
            }
        }
        
        return destination
    }
    
    // MARK: - Private Methods
    
    private func performRequest(_ request: NetworkRequest) async throws -> Data {
        do {
            let response = try await client.execute(request)
            return response.data
        } catch let error as HTTPClientError {
            throw mapNetworkError(error)
        } catch {
            if (error as NSError).code == NSURLErrorTimedOut {
                throw NetworkError.timeout
            } else {
                throw NetworkError.requestFailed(error)
            }
        }
    }

    private func mapNetworkError(_ error: HTTPClientError) -> NetworkError {
        switch error {
        case .invalidURL, .invalidResponse:
            return .invalidResponse
        case .requestFailed(let underlying):
            return .requestFailed(underlying)
        case .httpError(let statusCode, _):
            if (500...599).contains(statusCode) {
                return .serverError(statusCode)
            }
            return .requestFailed(NSError(domain: "Client Error", code: statusCode, userInfo: nil))
        case .decodingError(let underlying):
            return .decodingFailed(underlying)
        case .timeout:
            return .timeout
        case .noInternetConnection:
            return .noInternetConnection
        case .cancelled:
            return .requestFailed(URLError(.cancelled))
        }
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
            throw NetworkError.invalidResponse
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
            throw NetworkError.invalidResponse
        }
        return try await post(to: url, body: body, headers: headers, timeout: timeout)
    }
}
