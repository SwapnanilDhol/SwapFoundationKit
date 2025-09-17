# Networking Module

The Networking module provides a comprehensive HTTP client implementation with support for async/await, automatic JSON encoding/decoding, and flexible request configuration.

## Features

- ✅ Async/await support
- ✅ Automatic JSON encoding/decoding
- ✅ Flexible request configuration
- ✅ Comprehensive error handling
- ✅ URL building with query parameters
- ✅ Default headers management
- ✅ Certificate pinning support (configurable)
- ✅ Timeout configuration
- ✅ Cross-platform support (iOS/macOS)

## Quick Start

### 1. Enable Networking in Configuration

```swift
let config = SwapFoundationKitConfiguration(
    appMetadata: AppMetaData(appGroupIdentifier: "group.com.example.app"),
    enableNetworking: true,  // Enable networking features
    networkTimeout: 30.0     // 30 second timeout
)

try await SwapFoundationKit.shared.start(with: config)
```

### 2. Make Network Requests

```swift
// Get HTTP client from framework
guard let client = SwapFoundationKit.shared.networkClient else {
    print("Networking not enabled")
    return
}

// Execute a simple GET request
let response = try await client.get(
    baseURL: "api.example.com",
    path: "/users",
    parameters: ["limit": "10"]
)

// Decode JSON response
let users: [User] = try await client.executeAndDecode(
    GetUsersRequest(limit: 10)
)
```

## Request Types

### Using NetworkRequest Protocol

```swift
struct GetUsersRequest: NetworkRequest {
    let limit: Int

    var scheme: String { "https" }           // Default: "https"
    var baseURL: String { "api.example.com" }
    var path: String { "/users" }
    var method: HTTPMethod { .get }
    var parameters: [String: String]? { ["limit": "\(limit)"] }
    var headers: [String: String]? { ["Authorization": "Bearer \(token)"] }
    var body: Data? { nil }
}

// Example with custom scheme (HTTP for development)
struct DevGetUsersRequest: NetworkRequest {
    var scheme: String { "http" }            // Use HTTP for development
    var baseURL: String { "localhost:8080" }
    var path: String { "/api/users" }
    var method: HTTPMethod { .get }
}
```

### Using Convenience Methods

```swift
// GET request (default HTTPS scheme)
let response = try await client.get(
    baseURL: "api.example.com",
    path: "/users/123"
)

// GET request with custom scheme (HTTP for development)
let devResponse = try await client.get(
    scheme: "http",                    // Custom scheme
    baseURL: "localhost:8080",
    path: "/api/users/123"
)

// POST request with JSON body
let userData = ["name": "John", "email": "john@example.com"]
let jsonData = try JSONSerialization.data(withJSONObject: userData)
let response = try await client.post(
    baseURL: "api.example.com",
    path: "/users",
    body: jsonData,
    headers: ["Content-Type": "application/json"]
)

// PUT request
let response = try await client.put(
    baseURL: "api.example.com",
    path: "/users/123",
    body: updatedUserData
)

// DELETE request
let response = try await client.delete(
    baseURL: "api.example.com",
    path: "/users/123"
)
```

## Error Handling

```swift
do {
    let response = try await client.execute(request)
    print("Success: \(response.statusCode)")
} catch NetworkError.invalidURL {
    print("Invalid URL")
} catch NetworkError.httpError(let statusCode, let data) {
    print("HTTP Error: \(statusCode)")
    if let data = data {
        let errorMessage = String(data: data, encoding: .utf8)
        print("Error details: \(errorMessage ?? "Unknown")")
    }
} catch NetworkError.timeout {
    print("Request timed out")
} catch NetworkError.noInternetConnection {
    print("No internet connection")
} catch {
    print("Other error: \(error)")
}
```

## Advanced Configuration

### Custom HTTP Client

```swift
let sessionConfig = URLSessionConfiguration.default
sessionConfig.timeoutIntervalForRequest = 60.0
sessionConfig.timeoutIntervalForResource = 300.0

let customClient = HTTPClient(configuration: sessionConfig)
customClient.defaultHeaders["Custom-Header"] = "Value"

let config = SwapFoundationKitConfiguration(
    appMetadata: AppMetaData(appGroupIdentifier: "group.com.example.app"),
    enableNetworking: true,
    customHTTPClient: customClient
)
```

### Certificate Pinning

```swift
let config = SwapFoundationKitConfiguration(
    appMetadata: AppMetaData(appGroupIdentifier: "group.com.example.app"),
    enableNetworking: true,
    enableCertificatePinning: true
)
// Note: Certificate pinning implementation would need additional setup
```

## JSON Encoding/Decoding

### Encoding Objects to JSON

```swift
struct User: Codable {
    let id: Int
    let name: String
    let email: String
}

let user = User(id: 1, name: "John", email: "john@example.com")
let jsonData = try user.toJSONData()

let response = try await client.post(
    baseURL: "api.example.com",
    path: "/users",
    body: jsonData
)
```

### Decoding JSON Responses

```swift
let users: [User] = try await client.executeAndDecode(
    GetUsersRequest()
)
```

## URL Building

```swift
// Automatic URL building from request properties
let request = GetUsersRequest(limit: 10)
// URL: https://api.example.com/users?limit=10

// Manual URL building with parameters
let baseURL = URL(string: "https://api.example.com")!
let urlWithParams = baseURL.appendingQueryParameters([
    "limit": "10",
    "offset": "0"
])
// URL: https://api.example.com?limit=10&offset=0
```

## Advanced Usage

### Custom Request Types

```swift
// API Request with authentication
struct AuthenticatedRequest: NetworkRequest {
    let path: String
    let method: HTTPMethod
    let body: Data?
    let accessToken: String

    var scheme: String { "https" }
    var baseURL: String { "api.example.com" }
    var headers: [String: String]? {
        ["Authorization": "Bearer \(accessToken)"]
    }
}

// Reusable API client
class APIClient {
    private let client: HTTPClient
    private let baseURL = "api.example.com"

    init(client: HTTPClient = .shared) {
        self.client = client
    }

    func getUsers(limit: Int = 20) async throws -> [User] {
        struct GetUsersRequest: NetworkRequest {
            let limit: Int
            var scheme: String { "https" }
            var baseURL: String { "api.example.com" }
            var path: String { "/users" }
            var method: HTTPMethod { .get }
            var parameters: [String: String]? { ["limit": "\(limit)"] }
        }

        return try await client.executeAndDecode(GetUsersRequest(limit: limit))
    }

    func createUser(_ user: User) async throws -> User {
        let jsonData = try user.toJSONData()

        let response = try await client.post(
            baseURL: baseURL,
            path: "/users",
            body: jsonData,
            headers: ["Content-Type": "application/json"]
        )

        return try JSONDecoder().decode(User.self, from: response.data)
    }
}
```

### Response Validation

```swift
// Custom response validation
extension HTTPClient {
    func executeWithValidation<T: Decodable>(
        _ request: NetworkRequest,
        validator: (NetworkResponse) throws -> Void
    ) async throws -> T {
        let response = try await execute(request)
        try validator(response)
        return try JSONDecoder().decode(T.self, from: response.data)
    }
}

// Usage
let users = try await client.executeWithValidation(GetUsersRequest()) { response in
    guard response.statusCode == 200 else {
        throw APIError.invalidStatusCode(response.statusCode)
    }
    guard response.contentType?.contains("application/json") == true else {
        throw APIError.invalidContentType
    }
}
```

### Request Interceptors

```swift
// Request interceptor protocol
protocol RequestInterceptor {
    func intercept(_ request: inout URLRequest) async throws
}

// Authentication interceptor
struct AuthInterceptor: RequestInterceptor {
    let token: String

    func intercept(_ request: inout URLRequest) async throws {
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }
}

// Custom HTTP client with interceptors
class InterceptableHTTPClient: HTTPClient {
    private var interceptors: [RequestInterceptor] = []

    func addInterceptor(_ interceptor: RequestInterceptor) {
        interceptors.append(interceptor)
    }

    override func execute(_ request: NetworkRequest) async throws -> NetworkResponse {
        guard let urlRequest = request.request else {
            throw NetworkError.invalidURL
        }

        var finalRequest = urlRequest

        // Apply all interceptors
        for interceptor in interceptors {
            try await interceptor.intercept(&finalRequest)
        }

        // Execute with modified request
        let (data, response) = try await session.data(for: finalRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        let networkResponse = NetworkResponse(data: data, response: httpResponse, request: finalRequest)

        guard networkResponse.isSuccessful else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode, data: data)
        }

        return networkResponse
    }
}
```

## Testing

### Unit Testing

```swift
import XCTest
@testable import SwapFoundationKit

class NetworkingTests: XCTestCase {
    var client: HTTPClient!
    var mockSession: URLSession!

    override func setUp() {
        super.setUp()

        // Create mock session configuration
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        mockSession = URLSession(configuration: config)

        client = HTTPClient(configuration: mockSession.configuration)
    }

    func testGetUsersSuccess() async throws {
        // Arrange
        let expectedUsers = [User(id: 1, name: "John")]
        let jsonData = try JSONEncoder().encode(expectedUsers)

        MockURLProtocol.mockResponse = (
            data: jsonData,
            response: HTTPURLResponse(
                url: URL(string: "https://api.example.com/users")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!,
            error: nil
        )

        // Act
        let users: [User] = try await client.executeAndDecode(
            GetUsersRequest()
        )

        // Assert
        XCTAssertEqual(users.count, 1)
        XCTAssertEqual(users.first?.name, "John")
    }

    func testNetworkErrorHandling() async {
        // Arrange
        MockURLProtocol.mockResponse = (
            data: Data(),
            response: HTTPURLResponse(
                url: URL(string: "https://api.example.com/users")!,
                statusCode: 404,
                httpVersion: nil,
                headerFields: nil
            )!,
            error: nil
        )

        // Act & Assert
        do {
            let _: [User] = try await client.executeAndDecode(GetUsersRequest())
            XCTFail("Expected error to be thrown")
        } catch NetworkError.httpError(let statusCode, _) {
            XCTAssertEqual(statusCode, 404)
        } catch {
            XCTFail("Expected NetworkError.httpError, got \(error)")
        }
    }
}

// Mock URL Protocol for testing
class MockURLProtocol: URLProtocol {
    static var mockResponse: (data: Data?, response: URLResponse?, error: Error?)?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        if let mockResponse = MockURLProtocol.mockResponse {
            if let data = mockResponse.data {
                client?.urlProtocol(self, didLoad: data)
            }
            if let response = mockResponse.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            if let error = mockResponse.error {
                client?.urlProtocol(self, didFailWithError: error)
            } else {
                client?.urlProtocolDidFinishLoading(self)
            }
        }
    }

    override func stopLoading() {}
}
```

### Integration Testing

```swift
class APIIntegrationTests: XCTestCase {
    var apiClient: APIClient!

    override func setUp() {
        super.setUp()

        // Use test server configuration
        let testConfig = SwapFoundationKitConfiguration(
            appMetadata: AppMetaData(appGroupIdentifier: "group.test"),
            enableNetworking: true
        )

        try? await SwapFoundationKit.shared.start(with: testConfig)
        apiClient = APIClient(client: SwapFoundationKit.shared.networkClient!)
    }

    func testEndToEndUserFlow() async throws {
        // Test user creation and retrieval
        let newUser = User(id: 0, name: "Test User", email: "test@example.com")
        let createdUser = try await apiClient.createUser(newUser)

        XCTAssertGreaterThan(createdUser.id, 0)
        XCTAssertEqual(createdUser.name, newUser.name)

        // Test user retrieval
        let users = try await apiClient.getUsers()
        XCTAssertTrue(users.contains(where: { $0.id == createdUser.id }))
    }
}
```

## Best Practices

1. **Enable Networking**: Always set `enableNetworking: true` in configuration
2. **Error Handling**: Always handle network errors appropriately with do-catch
3. **Timeouts**: Configure appropriate timeouts for your use case (default 30s)
4. **Headers**: Use default headers for common values like authorization
5. **JSON**: Use `Codable` for type-safe JSON handling with `executeAndDecode`
6. **Testing**: Mock HTTPClient in tests for reliable unit testing
7. **Schemes**: Use HTTPS in production, HTTP only for local development
8. **Response Validation**: Validate response status codes and content types
9. **Request Interceptors**: Use interceptors for cross-cutting concerns like auth
10. **Memory Management**: URLSession handles memory automatically, but watch for retain cycles in interceptors

## HTTP Methods Supported

- `GET` - Retrieve data
- `POST` - Create new resources
- `PUT` - Update existing resources
- `DELETE` - Delete resources
- `PATCH` - Partial updates
- `HEAD` - Get headers only

## Response Types

- `NetworkResponse` - Contains data, HTTP response, and request
- `NetworkError` - Comprehensive error types for different failure scenarios
- Decoded objects using `executeAndDecode<T>()` method
