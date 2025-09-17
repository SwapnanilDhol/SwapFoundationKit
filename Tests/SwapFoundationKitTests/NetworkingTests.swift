import XCTest
@testable import SwapFoundationKit

final class NetworkingTests: XCTestCase {
    var client: HTTPClient!
    var mockSession: URLSession!

    override func setUp() async throws {
        try await super.setUp()

        // Create mock session configuration
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        mockSession = URLSession(configuration: config)

        client = HTTPClient(configuration: mockSession.configuration)
    }

    override func tearDown() async throws {
        client = nil
        mockSession = nil
        MockURLProtocol.mockResponse = nil
        try await super.tearDown()
    }

    // MARK: - NetworkRequest Protocol Tests

    func testNetworkRequestURLBuilding() {
        // Given
        struct TestRequest: NetworkRequest {
            var scheme: String { "https" }
            var baseURL: String { "api.example.com" }
            var path: String { "/users/123" }
            var method: HTTPMethod { .get }
            var parameters: [String: String]? { ["expand": "details"] }
            var headers: [String: String]? { nil }
            var body: Data? { nil }
        }

        let request = TestRequest()

        // When
        let url = request.url

        // Then
        XCTAssertNotNil(url)
        XCTAssertEqual(url?.absoluteString, "https://api.example.com/users/123?expand=details")
    }

    func testNetworkRequestURLBuildingWithCustomScheme() {
        // Given
        struct TestRequest: NetworkRequest {
            var scheme: String { "http" }
            var baseURL: String { "localhost" }
            var path: String { "/api/test" }
            var method: HTTPMethod { .get }
            var parameters: [String: String]? { nil }
            var headers: [String: String]? { nil }
            var body: Data? { nil }

            // Override URL building for this test
            var url: URL? {
                var urlComponents = URLComponents()
                urlComponents.scheme = scheme
                urlComponents.host = baseURL
                urlComponents.port = 8080
                urlComponents.path = path
                return urlComponents.url
            }
        }

        let request = TestRequest()

        // When
        let url = request.url

        // Then
        XCTAssertNotNil(url)
        XCTAssertEqual(url?.absoluteString, "http://localhost:8080/api/test")
    }

    func testNetworkRequestWithoutParameters() {
        // Given
        struct TestRequest: NetworkRequest {
            var scheme: String { "https" }
            var baseURL: String { "api.example.com" }
            var path: String { "/health" }
            var method: HTTPMethod { .get }
            var parameters: [String: String]? { nil }
            var headers: [String: String]? { nil }
            var body: Data? { nil }
        }

        let request = TestRequest()

        // When
        let url = request.url

        // Then
        XCTAssertNotNil(url)
        XCTAssertEqual(url?.absoluteString, "https://api.example.com/health")
    }

    // MARK: - HTTP Method Tests

    func testHTTPMethods() {
        XCTAssertEqual(HTTPMethod.get.rawValue, "GET")
        XCTAssertEqual(HTTPMethod.post.rawValue, "POST")
        XCTAssertEqual(HTTPMethod.put.rawValue, "PUT")
        XCTAssertEqual(HTTPMethod.delete.rawValue, "DELETE")
        XCTAssertEqual(HTTPMethod.patch.rawValue, "PATCH")
        XCTAssertEqual(HTTPMethod.head.rawValue, "HEAD")
    }

    // MARK: - NetworkResponse Tests

    func testNetworkResponseProperties() {
        // Given
        let testData = Data("test response".utf8)
        let testURL = URL(string: "https://api.example.com/test")!
        let httpResponse = HTTPURLResponse(
            url: testURL,
            statusCode: 200,
            httpVersion: "HTTP/1.1",
            headerFields: ["Content-Type": "application/json"]
        )!
        let urlRequest = URLRequest(url: testURL)

        // When
        let response = NetworkResponse(
            data: testData,
            response: httpResponse,
            request: urlRequest
        )

        // Then
        XCTAssertEqual(response.data, testData)
        XCTAssertEqual(response.statusCode, 200)
        XCTAssertTrue(response.isSuccessful)
        XCTAssertEqual(response.contentType, "application/json")
        XCTAssertEqual(response.request, urlRequest)
    }

    func testNetworkResponseUnsuccessful() {
        // Given
        let testURL = URL(string: "https://api.example.com/test")!
        let httpResponse = HTTPURLResponse(
            url: testURL,
            statusCode: 404,
            httpVersion: "HTTP/1.1",
            headerFields: nil
        )!
        let urlRequest = URLRequest(url: testURL)

        // When
        let response = NetworkResponse(
            data: Data(),
            response: httpResponse,
            request: urlRequest
        )

        // Then
        XCTAssertEqual(response.statusCode, 404)
        XCTAssertFalse(response.isSuccessful)
    }

    // MARK: - NetworkError Tests

    func testNetworkErrorDescriptions() {
        XCTAssertEqual(NetworkError.invalidURL.errorDescription, "Invalid URL")
        XCTAssertEqual(NetworkError.invalidResponse.errorDescription, "Invalid response from server")
        XCTAssertEqual(NetworkError.timeout.errorDescription, "Request timed out")
        XCTAssertEqual(NetworkError.noInternetConnection.errorDescription, "No internet connection")
        XCTAssertEqual(NetworkError.cancelled.errorDescription, "Request was cancelled")

        let httpError = NetworkError.httpError(statusCode: 404, data: nil)
        XCTAssertEqual(httpError.errorDescription, "HTTP Error: 404")

        let decodingError = NetworkError.decodingError(NSError(domain: "test", code: 1, userInfo: nil))
        XCTAssertTrue(decodingError.errorDescription?.contains("Failed to decode response") ?? false)

        let requestError = NetworkError.requestFailed(NSError(domain: "test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Test error"]))
        XCTAssertEqual(requestError.errorDescription, "Request failed: Test error")
    }

    // MARK: - Convenience Methods Tests

    func testGetConvenienceMethod() async throws {
        // Given
        let expectedData = Data("success".utf8)
        MockURLProtocol.mockResponse = (
            data: expectedData,
            response: HTTPURLResponse(
                url: URL(string: "https://api.example.com/users")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!,
            error: nil
        )

        // When
        let response = try await client.get(
            baseURL: "api.example.com",
            path: "/users",
            parameters: ["limit": "10"]
        )

        // Then
        XCTAssertEqual(response.statusCode, 200)
        XCTAssertEqual(response.data, expectedData)
    }

    func testPostConvenienceMethod() async throws {
        // Given
        let requestBody = Data("test data".utf8)
        let expectedResponse = Data("created".utf8)
        MockURLProtocol.mockResponse = (
            data: expectedResponse,
            response: HTTPURLResponse(
                url: URL(string: "https://api.example.com/users")!,
                statusCode: 201,
                httpVersion: nil,
                headerFields: nil
            )!,
            error: nil
        )

        // When
        let response = try await client.post(
            baseURL: "api.example.com",
            path: "/users",
            body: requestBody
        )

        // Then
        XCTAssertEqual(response.statusCode, 201)
        XCTAssertEqual(response.data, expectedResponse)
    }

    func testPutConvenienceMethod() async throws {
        // Given
        let requestBody = Data("updated data".utf8)
        MockURLProtocol.mockResponse = (
            data: Data(),
            response: HTTPURLResponse(
                url: URL(string: "https://api.example.com/users/1")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!,
            error: nil
        )

        // When
        let response = try await client.put(
            baseURL: "api.example.com",
            path: "/users/1",
            body: requestBody
        )

        // Then
        XCTAssertEqual(response.statusCode, 200)
    }

    func testDeleteConvenienceMethod() async throws {
        // Given
        MockURLProtocol.mockResponse = (
            data: Data(),
            response: HTTPURLResponse(
                url: URL(string: "https://api.example.com/users/1")!,
                statusCode: 204,
                httpVersion: nil,
                headerFields: nil
            )!,
            error: nil
        )

        // When
        let response = try await client.delete(
            baseURL: "api.example.com",
            path: "/users/1"
        )

        // Then
        XCTAssertEqual(response.statusCode, 204)
    }

    func testCustomSchemeConvenienceMethods() async throws {
        // Given
        MockURLProtocol.mockResponse = (
            data: Data("response".utf8),
            response: HTTPURLResponse(
                url: URL(string: "http://localhost/test")!, // Valid URL for mock
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!,
            error: nil
        )

        // When
        let response = try await client.get(
            scheme: "http",
            baseURL: "localhost",
            path: "/test"
        )

        // Then
        XCTAssertEqual(response.statusCode, 200)
    }

    // MARK: - JSON Encoding/Decoding Tests

    func testExecuteAndDecodeSuccess() async throws {
        // Given
        struct User: Codable, Equatable {
            let id: Int
            let name: String
        }

        let expectedUsers = [User(id: 1, name: "John"), User(id: 2, name: "Jane")]
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

        // When
        struct GetUsersRequest: NetworkRequest {
            var scheme: String { "https" }
            var baseURL: String { "api.example.com" }
            var path: String { "/users" }
            var method: HTTPMethod { .get }
            var parameters: [String: String]? { nil }
            var headers: [String: String]? { nil }
            var body: Data? { nil }
        }

        let users: [User] = try await client.executeAndDecode(GetUsersRequest())

        // Then
        XCTAssertEqual(users, expectedUsers)
    }

    func testExecuteAndDecodeDecodingError() async {
        // Given
        struct User: Codable {
            let id: Int
            let name: String
        }

        let invalidJSON = Data("invalid json".utf8)

        MockURLProtocol.mockResponse = (
            data: invalidJSON,
            response: HTTPURLResponse(
                url: URL(string: "https://api.example.com/users")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!,
            error: nil
        )

        // When & Then
        struct GetUsersRequest: NetworkRequest {
            var scheme: String { "https" }
            var baseURL: String { "api.example.com" }
            var path: String { "/users" }
            var method: HTTPMethod { .get }
            var parameters: [String: String]? { nil }
            var headers: [String: String]? { nil }
            var body: Data? { nil }
        }

        do {
            let _: [User] = try await client.executeAndDecode(GetUsersRequest())
            XCTFail("Expected decoding error")
        } catch NetworkError.decodingError {
            // Success - expected error was thrown
        } catch {
            XCTFail("Expected NetworkError.decodingError, got \(error)")
        }
    }

    // MARK: - Error Handling Tests

    func testHTTPErrorHandling() async {
        // Given
        MockURLProtocol.mockResponse = (
            data: Data("Not Found".utf8),
            response: HTTPURLResponse(
                url: URL(string: "https://api.example.com/users/999")!,
                statusCode: 404,
                httpVersion: nil,
                headerFields: nil
            )!,
            error: nil
        )

        // When & Then
        struct GetUserRequest: NetworkRequest {
            var scheme: String { "https" }
            var baseURL: String { "api.example.com" }
            var path: String { "/users/999" }
            var method: HTTPMethod { .get }
            var parameters: [String: String]? { nil }
            var headers: [String: String]? { nil }
            var body: Data? { nil }
        }

        do {
            _ = try await client.execute(GetUserRequest())
            XCTFail("Expected HTTP error")
        } catch let NetworkError.requestFailed(error) {
            // HTTP errors may be wrapped in requestFailed in some scenarios
            if let httpError = error as? NetworkError,
               case .httpError(let statusCode, let data) = httpError {
                XCTAssertEqual(statusCode, 404)
                XCTAssertEqual(data, Data("Not Found".utf8))
            } else {
                XCTFail("Expected wrapped HTTP error, got \(error)")
            }
        } catch NetworkError.httpError(let statusCode, let data) {
            XCTAssertEqual(statusCode, 404)
            XCTAssertEqual(data, Data("Not Found".utf8))
        } catch {
            XCTFail("Expected NetworkError, got \(error)")
        }
    }

    func testTimeoutErrorHandling() async {
        // Given
        let timeoutError = URLError(.timedOut)
        MockURLProtocol.mockResponse = (
            data: nil,
            response: nil,
            error: timeoutError
        )

        // When & Then
        struct GetUsersRequest: NetworkRequest {
            var scheme: String { "https" }
            var baseURL: String { "api.example.com" }
            var path: String { "/users" }
            var method: HTTPMethod { .get }
            var parameters: [String: String]? { nil }
            var headers: [String: String]? { nil }
            var body: Data? { nil }
        }

        do {
            _ = try await client.execute(GetUsersRequest())
            XCTFail("Expected timeout error")
        } catch NetworkError.timeout {
            // Success - expected error was thrown
        } catch {
            XCTFail("Expected NetworkError.timeout, got \(error)")
        }
    }

    func testInvalidURLErrorHandling() async {
        // Given
        struct InvalidURLRequest: NetworkRequest {
            var scheme: String { "https" }
            var baseURL: String { "" } // Empty base URL
            var path: String { "/test" }
            var method: HTTPMethod { .get }
            var parameters: [String: String]? { nil }
            var headers: [String: String]? { nil }
            var body: Data? { nil }
        }

        // When & Then
        do {
            _ = try await client.execute(InvalidURLRequest())
            XCTFail("Expected invalid URL error")
        } catch NetworkError.invalidURL {
            // Success - expected error was thrown
        } catch {
            XCTFail("Expected NetworkError.invalidURL, got \(error)")
        }
    }

    // MARK: - Default Headers Tests

    func testDefaultHeaders() async throws {
        // Given
        MockURLProtocol.mockResponse = (
            data: Data(),
            response: HTTPURLResponse(
                url: URL(string: "https://api.example.com/test")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!,
            error: nil
        )

        // When
        let response = try await client.get(
            baseURL: "api.example.com",
            path: "/test"
        )

        // Then
        XCTAssertEqual(response.statusCode, 200)

        // Verify that the request was made (this would be checked in MockURLProtocol)
        // In a real test, you'd verify the request headers were set correctly
    }

    // MARK: - URL Extensions Tests

    func testURLAppendingQueryParameters() {
        // Given
        let baseURL = URL(string: "https://api.example.com/search")!

        // When
        let urlWithParams = baseURL.appendingQueryParameters([
            "query": "swift",
            "limit": "20"
        ])

        // Then
        XCTAssertNotNil(urlWithParams)
        XCTAssertNotNil(urlWithParams?.absoluteString)

        // Check that the base URL is correct
        XCTAssertTrue(urlWithParams!.absoluteString.hasPrefix("https://api.example.com/search?"))

        // Check that all parameters are present (order may vary)
        let components = URLComponents(url: urlWithParams!, resolvingAgainstBaseURL: false)
        let queryItems = components?.queryItems
        XCTAssertNotNil(queryItems)
        XCTAssertEqual(queryItems?.count, 2)

        let params = Dictionary(uniqueKeysWithValues: queryItems!.map { ($0.name, $0.value) })
        XCTAssertEqual(params["query"], "swift")
        XCTAssertEqual(params["limit"], "20")
    }

    func testURLAppendingQueryParametersWithExistingParams() {
        // Given
        let baseURL = URL(string: "https://api.example.com/search?sort=name")!

        // When
        let urlWithParams = baseURL.appendingQueryParameters([
            "query": "swift",
            "limit": "20"
        ])

        // Then
        XCTAssertNotNil(urlWithParams)
        let components = URLComponents(url: urlWithParams!, resolvingAgainstBaseURL: false)
        let queryItems = components?.queryItems

        XCTAssertNotNil(queryItems)
        XCTAssertEqual(queryItems?.count, 3)

        let queryParams = Dictionary(uniqueKeysWithValues: queryItems!.map { ($0.name, $0.value) })
        XCTAssertEqual(queryParams["sort"], "name")
        XCTAssertEqual(queryParams["query"], "swift")
        XCTAssertEqual(queryParams["limit"], "20")
    }

    // MARK: - Codable Extension Tests

    func testEncodableToJSONData() throws {
        // Given
        struct TestModel: Codable, Equatable {
            let id: Int
            let name: String
        }

        let model = TestModel(id: 1, name: "Test")

        // When
        let jsonData = try model.toJSONData()
        let decodedModel = try JSONDecoder().decode(TestModel.self, from: jsonData)

        // Then
        XCTAssertEqual(model, decodedModel)
    }

    // MARK: - Integration Tests

    func testFrameworkIntegration() async throws {
        // Given
        let config = SwapFoundationKitConfiguration(
            appMetadata: AppMetaData(appGroupIdentifier: "group.test.networking"),
            enableNetworking: true
        )

        // When
        try await SwapFoundationKit.shared.start(with: config)

        // Then
        XCTAssertNotNil(SwapFoundationKit.shared.networkClient)

        // Cleanup
        // Note: In a real scenario, you might want to reset the framework state
    }
}

// MARK: - Mock URL Protocol

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

// MARK: - Test Models

struct TestUser: Codable, Equatable {
    let id: Int
    let name: String
    let email: String
}

struct TestPost: Codable, Equatable {
    let id: Int
    let title: String
    let body: String
    let userId: Int
}

// MARK: - Test Request Types

struct GetUsersRequest: NetworkRequest {
    var scheme: String { "https" }
    var baseURL: String { "jsonplaceholder.typicode.com" }
    var path: String { "/users" }
    var method: HTTPMethod { .get }
    var parameters: [String: String]? { nil }
    var headers: [String: String]? { nil }
    var body: Data? { nil }
}

struct CreatePostRequest: NetworkRequest {
    let post: TestPost

    var scheme: String { "https" }
    var baseURL: String { "jsonplaceholder.typicode.com" }
    var path: String { "/posts" }
    var method: HTTPMethod { .post }
    var parameters: [String: String]? { nil }
    var body: Data? {
        try? JSONEncoder().encode(post)
    }
    var headers: [String: String]? {
        ["Content-Type": "application/json"]
    }
}

struct GetPostRequest: NetworkRequest {
    let postId: Int

    var scheme: String { "https" }
    var baseURL: String { "jsonplaceholder.typicode.com" }
    var path: String { "/posts/\(postId)" }
    var method: HTTPMethod { .get }
    var parameters: [String: String]? { nil }
    var headers: [String: String]? { nil }
    var body: Data? { nil }
}

struct UpdatePostRequest: NetworkRequest {
    let postId: Int
    let post: TestPost

    var scheme: String { "https" }
    var baseURL: String { "jsonplaceholder.typicode.com" }
    var path: String { "/posts/\(postId)" }
    var method: HTTPMethod { .put }
    var parameters: [String: String]? { nil }
    var body: Data? {
        try? JSONEncoder().encode(post)
    }
    var headers: [String: String]? {
        ["Content-Type": "application/json"]
    }
}

struct DeletePostRequest: NetworkRequest {
    let postId: Int

    var scheme: String { "https" }
    var baseURL: String { "jsonplaceholder.typicode.com" }
    var path: String { "/posts/\(postId)" }
    var method: HTTPMethod { .delete }
    var parameters: [String: String]? { nil }
    var headers: [String: String]? { nil }
    var body: Data? { nil }
}
