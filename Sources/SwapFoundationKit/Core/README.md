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

    var baseURL: String { "api.example.com" }
    var path: String { "/users" }
    var method: HTTPMethod { .get }
    var parameters: [String: String]? { ["limit": "\(limit)"] }
    var headers: [String: String]? { ["Authorization": "Bearer \(token)"] }
}
```

### Using Convenience Methods

```swift
// GET request
let response = try await client.get(
    baseURL: "api.example.com",
    path: "/users/123"
)

// POST request with JSON body
let userData = ["name": "John", "email": "john@example.com"]
let jsonData = try JSONSerialization.data(withJSONObject: userData)
let response = try await client.post(
    baseURL: "api.example.com",
    path: "/users",
    body: jsonData
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

## Best Practices

1. **Enable Networking**: Always set `enableNetworking: true` in configuration
2. **Error Handling**: Always handle network errors appropriately
3. **Timeouts**: Configure appropriate timeouts for your use case
4. **Headers**: Use default headers for common values like authorization
5. **JSON**: Use Codable for type-safe JSON handling
6. **Testing**: Mock HTTPClient in tests for reliable testing

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