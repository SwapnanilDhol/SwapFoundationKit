import Combine
import Foundation
import Network

/// Observable reachability state for features that do not need HTTP execution.
@MainActor
public final class NetworkMonitor: ObservableObject {
    public enum ConnectionType: Sendable {
        case wifi
        case cellular
        case ethernet
        case unknown
    }

    @Published public private(set) var isConnected = false
    @Published public private(set) var connectionType: ConnectionType = .unknown

    private let pathMonitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "SwapFoundationKit.NetworkMonitor")

    public init() {
        pathMonitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.isConnected = path.status == .satisfied
                self.connectionType = Self.connectionType(for: path)
            }
        }
        pathMonitor.start(queue: queue)
    }

    deinit {
        pathMonitor.cancel()
    }

    public func waitForConnection(timeout: TimeInterval = 10) async -> Bool {
        guard !Task.isCancelled else { return false }
        if isConnected { return true }
        let deadline = Date().addingTimeInterval(max(0, timeout))
        while !isConnected && Date() < deadline && !Task.isCancelled {
            try? await Task.sleep(for: .milliseconds(100))
        }
        return isConnected && !Task.isCancelled
    }

    private static func connectionType(for path: NWPath) -> ConnectionType {
        if path.usesInterfaceType(.wifi) { return .wifi }
        if path.usesInterfaceType(.cellular) { return .cellular }
        if path.usesInterfaceType(.wiredEthernet) { return .ethernet }
        return .unknown
    }
}
