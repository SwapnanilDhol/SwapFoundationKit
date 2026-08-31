/*****************************************************************************
 * NetworkServiceBackendHeadersTests.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import XCTest
import Network
@testable import SwapFoundationKit
@testable import SwapFoundationKitNetworking

/// Covers `NetworkService.performRequest`'s origin-scoped merge of `backendDefaultHeaders`
/// (see `NetworkService`'s instance-scoped origin policy): headers must only reach requests whose
/// origin was explicitly supplied, and per-request headers must keep winning over backend defaults.
@MainActor
final class NetworkServiceBackendHeadersTests: XCTestCase {
    var client: HTTPClient!

    override func setUp() async throws {
        try await super.setUp()
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        client = HTTPClient(configuration: config)
    }

    override func tearDown() async throws {
        client = nil
        MockURLProtocol.mockResponse = nil
        MockURLProtocol.lastRequest = nil
        try await super.tearDown()
    }

    private func stubOK(for url: URL) {
        MockURLProtocol.mockResponse = (
            data: Data("ok".utf8),
            response: HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!,
            error: nil
        )
    }

    func testBackendHeadersAppliedForRegisteredOrigin() async throws {
        let url = URL(string: "https://api.example.com/ping")!
        stubOK(for: url)

        let service = NetworkService(client: client, backendHeadersProvider: { ["X-App-User-ID": "user-123"] }, backendOrigins: [url])
        _ = try await service.get(from: url)

        XCTAssertEqual(MockURLProtocol.lastRequest?.value(forHTTPHeaderField: "X-App-User-ID"), "user-123")
    }

    func testBackendHeadersNotAppliedForUnregisteredThirdPartyOrigin() async throws {
        let url = URL(string: "https://third-party-analytics.example.com/track")!
        stubOK(for: url)

        let service = NetworkService(client: client, backendHeadersProvider: { ["X-App-User-ID": "user-123"] }, backendOrigins: [URL(string: "https://api.example.com")!])
        _ = try await service.get(from: url)

        XCTAssertNil(MockURLProtocol.lastRequest?.value(forHTTPHeaderField: "X-App-User-ID"))
    }

    func testBackendHeadersNotAppliedWhenNoOriginIsRegisteredAtAll() async throws {
        let url = URL(string: "https://api.example.com/ping")!
        stubOK(for: url)

        let service = NetworkService(client: client, backendHeadersProvider: { ["X-App-User-ID": "user-123"] })
        _ = try await service.get(from: url)

        XCTAssertNil(MockURLProtocol.lastRequest?.value(forHTTPHeaderField: "X-App-User-ID"))
    }

    func testCallerSuppliedHeaderWinsOverBackendDefault() async throws {
        let url = URL(string: "https://api.example.com/ping")!
        stubOK(for: url)

        let service = NetworkService(client: client, backendHeadersProvider: { ["X-App-User-ID": "from-provider"] }, backendOrigins: [url])
        _ = try await service.get(from: url, headers: ["X-App-User-ID": "caller-override"])

        XCTAssertEqual(MockURLProtocol.lastRequest?.value(forHTTPHeaderField: "X-App-User-ID"), "caller-override")
    }

    func testCallerSuppliedHeaderWinsRegardlessOfCase() async throws {
        let url = URL(string: "https://api.example.com/ping")!
        stubOK(for: url)

        let service = NetworkService(client: client, backendHeadersProvider: { ["X-App-User-ID": "from-provider"] }, backendOrigins: [url])
        _ = try await service.get(from: url, headers: ["x-app-user-id": "caller-override"])

        let fields = MockURLProtocol.lastRequest?.allHTTPHeaderFields ?? [:]
        let matching = fields.filter { $0.key.caseInsensitiveCompare("X-App-User-ID") == .orderedSame }
        XCTAssertEqual(matching.count, 1)
        XCTAssertEqual(matching.first?.value, "caller-override")
    }

    func testBackendHeadersRespectRegisteredPort() async throws {
        // Same host/scheme, but no port match.
        let url = URL(string: "https://api.example.com/ping")!
        stubOK(for: url)

        let service = NetworkService(client: client, backendHeadersProvider: { ["X-App-User-ID": "user-123"] }, backendOrigins: [URL(string: "https://api.example.com:8443")!])
        _ = try await service.get(from: url)

        XCTAssertNil(MockURLProtocol.lastRequest?.value(forHTTPHeaderField: "X-App-User-ID"))
    }

    func testBackendProviderAndOriginsAreIsolatedPerServiceInstance() async throws {
        let backend = URL(string: "https://api.example.com")!
        let thirdParty = URL(string: "https://third-party.example.com")!
        let first = NetworkService(
            client: client,
            backendHeadersProvider: { ["X-App-User-ID": "first"] },
            backendOrigins: [backend]
        )
        let second = NetworkService(
            client: client,
            backendHeadersProvider: { ["X-App-User-ID": "second"] },
            backendOrigins: [thirdParty]
        )

        stubOK(for: backend)
        _ = try await first.get(from: backend)
        XCTAssertEqual(MockURLProtocol.lastRequest?.value(forHTTPHeaderField: "X-App-User-ID"), "first")

        MockURLProtocol.lastRequest = nil
        stubOK(for: thirdParty)
        _ = try await second.get(from: thirdParty)
        XCTAssertEqual(MockURLProtocol.lastRequest?.value(forHTTPHeaderField: "X-App-User-ID"), "second")

        MockURLProtocol.lastRequest = nil
        stubOK(for: thirdParty)
        _ = try await first.get(from: thirdParty)
        XCTAssertNil(MockURLProtocol.lastRequest?.value(forHTTPHeaderField: "X-App-User-ID"))
    }

    func testInstanceOriginsNormalizeDefaultPortsInBothDirections() async throws {
        let omitted = URL(string: "https://api.example.com/ping")!
        let explicit = URL(string: "https://api.example.com:443/ping")!
        stubOK(for: explicit)
        let first = NetworkService(client: client, backendHeadersProvider: { ["X-Scoped": "one"] }, backendOrigins: [omitted])
        _ = try await first.get(from: explicit)
        XCTAssertEqual(MockURLProtocol.lastRequest?.value(forHTTPHeaderField: "X-Scoped"), "one")

        MockURLProtocol.lastRequest = nil
        stubOK(for: omitted)
        let second = NetworkService(client: client, backendHeadersProvider: { ["X-Scoped": "two"] }, backendOrigins: [explicit])
        _ = try await second.get(from: omitted)
        XCTAssertEqual(MockURLProtocol.lastRequest?.value(forHTTPHeaderField: "X-Scoped"), "two")
    }

    func testInstanceOriginsNormalizeHTTPDefaultPortInBothDirections() async throws {
        let omitted = URL(string: "http://api.example.com/ping")!
        let explicit = URL(string: "http://api.example.com:80/ping")!
        stubOK(for: explicit)
        let first = NetworkService(client: client, backendHeadersProvider: { ["X-Scoped": "one"] }, backendOrigins: [omitted])
        _ = try await first.get(from: explicit)
        XCTAssertEqual(MockURLProtocol.lastRequest?.value(forHTTPHeaderField: "X-Scoped"), "one")

        MockURLProtocol.lastRequest = nil
        stubOK(for: omitted)
        let second = NetworkService(client: client, backendHeadersProvider: { ["X-Scoped": "two"] }, backendOrigins: [explicit])
        _ = try await second.get(from: omitted)
        XCTAssertEqual(MockURLProtocol.lastRequest?.value(forHTTPHeaderField: "X-Scoped"), "two")
    }

    func testInstanceOriginsRejectNonDefaultPorts() async throws {
        let omitted = URL(string: "https://api.example.com/ping")!
        let explicit = URL(string: "https://api.example.com:8443/ping")!
        stubOK(for: explicit)
        let service = NetworkService(client: client, backendHeadersProvider: { ["X-Scoped": "secret"] }, backendOrigins: [omitted])
        _ = try await service.get(from: explicit)
        XCTAssertNil(MockURLProtocol.lastRequest?.value(forHTTPHeaderField: "X-Scoped"))
    }

    func testInstanceOriginsFailClosedForLookalikeOrigins() async throws {
        let allowed = URL(string: "https://api.example.com/ping")!
        let rejected = [
            URL(string: "http://api.example.com/ping")!,
            URL(string: "https://sub.api.example.com/ping")!,
            URL(string: "https://api.example.com.evil.test/ping")!,
            URL(string: "https://api.example.com@evil.test/ping")!,
            URL(string: "https://attacker@api.example.com/ping")!,
            URL(string: "ftp://api.example.com/ping")!
        ]
        let service = NetworkService(client: client, backendHeadersProvider: { ["X-Scoped": "secret"] }, backendOrigins: [allowed])
        for url in rejected {
            MockURLProtocol.lastRequest = nil
            do {
                // FTP is rejected before URLSession dispatch, so it has no
                // response to stub.  The HTTP lookalikes still exercise the
                // actual request path and must remain fail-closed.
                if URLComponents(url: url, resolvingAgainstBaseURL: false)?.scheme != "ftp" {
                    stubOK(for: url)
                }
                _ = try await service.get(from: url)
            } catch NetworkError.invalidURL {
                // Invalid schemes are rejected before dispatch.
            }
            XCTAssertNil(MockURLProtocol.lastRequest?.value(forHTTPHeaderField: "X-Scoped"), url.absoluteString)
        }
    }

    func testGetWithoutBackendOverridePreservesSignedURL() async throws {
        let url = URL(string: "https://api.example.com/assets/%2Fencoded/?first=1&dup=a&dup=b&raw&last=#fragment")!
        stubOK(for: url)

        let service = NetworkService(client: client)
        _ = try await service.get(from: url)

        XCTAssertEqual(MockURLProtocol.lastRequest?.url?.absoluteString, url.absoluteString)
    }

    func testPostWithBackendOverridePreservesSignedURL() async throws {
        let url = URL(string: "https://api.example.com/assets/%2Fencoded/?first=1&dup=a&dup=b&raw&last=#fragment")!
        stubOK(for: url)

        let service = NetworkService(client: client, backendHeadersProvider: { ["X-App-User-ID": "user-123"] }, backendOrigins: [url])
        _ = try await service.post(to: url, body: Data("{}".utf8))

        XCTAssertEqual(MockURLProtocol.lastRequest?.url?.absoluteString, url.absoluteString)
        XCTAssertEqual(MockURLProtocol.lastRequest?.value(forHTTPHeaderField: "X-App-User-ID"), "user-123")
    }

    func testGetWithBackendOverridePreservesSignedURL() async throws {
        let url = URL(string: "https://api.example.com/assets/%2Fencoded/?first=1&dup=a&dup=b&raw&last=#fragment")!
        stubOK(for: url)

        let service = NetworkService(client: client, backendHeadersProvider: { ["X-App-User-ID": "user-123"] }, backendOrigins: [url])
        _ = try await service.get(from: url, headers: ["X-Request-ID": "request-1"])

        XCTAssertEqual(MockURLProtocol.lastRequest?.url?.absoluteString, url.absoluteString)
        XCTAssertEqual(MockURLProtocol.lastRequest?.value(forHTTPHeaderField: "X-App-User-ID"), "user-123")
    }

    func testPostWithoutBackendOverridePreservesSignedURL() async throws {
        let url = URL(string: "https://api.example.com/assets/%2Fencoded/?first=1&dup=a&dup=b&raw&last=#fragment")!
        stubOK(for: url)

        let service = NetworkService(client: client)
        _ = try await service.post(to: url, body: Data("{}".utf8), headers: [:])

        XCTAssertEqual(MockURLProtocol.lastRequest?.url?.absoluteString, url.absoluteString)
    }

    func testBackendHeadersFollowSameOriginRedirect() async throws {
        let server = try LoopbackHTTPServer(redirectMode: .sameOrigin)
        let port = try await server.start()
        defer { server.stop() }

        let source = URL(string: "http://127.0.0.1:\(port)/start")!
        let service = NetworkService(client: HTTPClient(configuration: .ephemeral), backendHeadersProvider: { ["X-App-User-ID": "user-123"] }, backendOrigins: [source])
        let data = try await service.get(from: source, timeout: 3)

        XCTAssertEqual(data, Data("ok".utf8))
        XCTAssertEqual(server.recordedEndRequestHeaders["x-app-user-id"], "user-123")
    }

    func testBackendHeadersCancelCrossOriginRedirect() async throws {
        let server = try LoopbackHTTPServer(redirectMode: .crossOrigin)
        let port = try await server.start()
        defer { server.stop() }

        let source = URL(string: "http://127.0.0.1:\(port)/start")!
        let service = NetworkService(client: HTTPClient(configuration: .ephemeral), backendHeadersProvider: { ["X-App-User-ID": "user-123"] }, backendOrigins: [source])

        do {
            _ = try await service.get(from: source, timeout: 3)
            XCTFail("Expected the rejected redirect to surface the original 302")
        } catch NetworkError.httpError(let statusCode, _) {
            XCTAssertEqual(statusCode, 302)
        } catch {
            XCTFail("Expected NetworkError.httpError(302), got \(error)")
        }

        XCTAssertTrue(server.recordedEndRequestHeaders.isEmpty)
    }

    func testNoBackendHeadersWhenProviderIsNilEvenWithAllowedOrigin() async throws {
        let url = URL(string: "https://api.example.com/ping")!
        stubOK(for: url)

        let service = NetworkService(client: client, backendOrigins: [url])
        _ = try await service.get(from: url)

        XCTAssertNil(MockURLProtocol.lastRequest?.value(forHTTPHeaderField: "X-App-User-ID"))
    }
}

private final class LoopbackHTTPServer: @unchecked Sendable {
    enum RedirectMode { case sameOrigin, crossOrigin }

    private let redirectMode: RedirectMode
    private let listener: NWListener
    private let queue = DispatchQueue(label: "SFKTests.LoopbackHTTPServer")
    private let lock = NSLock()
    private var readyContinuation: CheckedContinuation<UInt16, Error>?
    private var connections: [NWConnection] = []
    private var portValue: UInt16?
    private(set) var endRequestHeaders: [String: String] = [:]

    init(redirectMode: RedirectMode) throws {
        self.redirectMode = redirectMode
        let parameters = NWParameters.tcp
        parameters.requiredLocalEndpoint = NWEndpoint.hostPort(
            host: NWEndpoint.Host("127.0.0.1"),
            port: NWEndpoint.Port(rawValue: 0)!
        )
        self.listener = try NWListener(using: parameters)
    }

    func start() async throws -> UInt16 {
        try await withCheckedThrowingContinuation { continuation in
            lock.lock()
            readyContinuation = continuation
            lock.unlock()

            listener.stateUpdateHandler = { [weak self] state in
                guard let self else { return }
                switch state {
                case .ready:
                    let port = self.listener.port?.rawValue ?? 0
                    self.lock.lock()
                    self.portValue = port
                    let continuation = self.readyContinuation
                    self.readyContinuation = nil
                    self.lock.unlock()
                    if port == 0 {
                        continuation?.resume(throwing: URLError(.cannotCreateFile))
                    } else {
                        continuation?.resume(returning: port)
                    }
                case .failed(let error):
                    self.lock.lock()
                    let continuation = self.readyContinuation
                    self.readyContinuation = nil
                    self.lock.unlock()
                    continuation?.resume(throwing: error)
                default:
                    break
                }
            }
            listener.newConnectionHandler = { [weak self] connection in
                self?.accept(connection)
            }
            listener.start(queue: queue)
            queue.asyncAfter(deadline: .now() + 3) { [weak self] in
                guard let self else { return }
                self.lock.lock()
                let continuation = self.readyContinuation
                self.readyContinuation = nil
                self.lock.unlock()
                guard let continuation else { return }
                self.listener.cancel()
                continuation.resume(throwing: URLError(.timedOut))
            }
        }
    }

    func stop() {
        listener.cancel()
        lock.lock()
        let connections = self.connections
        self.connections.removeAll()
        let continuation = readyContinuation
        readyContinuation = nil
        lock.unlock()
        connections.forEach { $0.cancel() }
        continuation?.resume(throwing: URLError(.cancelled))
    }

    var recordedEndRequestHeaders: [String: String] {
        lock.lock()
        defer { lock.unlock() }
        return endRequestHeaders
    }

    private func accept(_ connection: NWConnection) {
        lock.lock()
        connections.append(connection)
        lock.unlock()
        connection.stateUpdateHandler = { [weak self, weak connection] state in
            guard let self, let connection, case .ready = state else { return }
            self.receive(on: connection, buffered: Data())
        }
        connection.start(queue: queue)
    }

    private func receive(on connection: NWConnection, buffered: Data) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65_536) { [weak self, weak connection] data, _, isComplete, error in
            guard let self, let connection, error == nil else {
                connection?.cancel()
                return
            }
            var buffer = buffered
            if let data { buffer.append(data) }
            if let request = String(data: buffer, encoding: .utf8), request.contains("\r\n\r\n") {
                self.respond(to: connection, request: request)
            } else if !isComplete {
                self.receive(on: connection, buffered: buffer)
            } else {
                connection.cancel()
            }
        }
    }

    private func respond(to connection: NWConnection, request: String) {
        let lines = request.components(separatedBy: "\r\n")
        let path = lines.first?.split(separator: " ").dropFirst().first.map(String.init) ?? ""
        var headers: [String: String] = [:]
        for line in lines.dropFirst() {
            guard let separator = line.firstIndex(of: ":") else { continue }
            let name = String(line[..<separator]).lowercased()
            let value = String(line[line.index(after: separator)...]).trimmingCharacters(in: .whitespaces)
            headers[name] = value
        }

        let response: Data
        if path == "/start", let port = portValue {
            let location = redirectMode == .sameOrigin ? "/end" : "http://localhost:\(port)/end"
            response = httpResponse(status: 302, headers: ["Location": location], body: Data())
        } else if path == "/end" {
            lock.lock()
            endRequestHeaders = headers
            lock.unlock()
            response = httpResponse(status: 200, headers: [:], body: Data("ok".utf8))
        } else {
            response = httpResponse(status: 404, headers: [:], body: Data())
        }

        connection.send(content: response, completion: .contentProcessed { _ in
            connection.cancel()
        })
    }

    private func httpResponse(status: Int, headers: [String: String], body: Data) -> Data {
        var headerLines = ["HTTP/1.1 \(status) \(status == 200 ? "OK" : "Found")", "Content-Length: \(body.count)", "Connection: close"]
        headerLines.append(contentsOf: headers.map { "\($0.key): \($0.value)" })
        var response = Data((headerLines.joined(separator: "\r\n") + "\r\n\r\n").utf8)
        response.append(body)
        return response
    }
}
