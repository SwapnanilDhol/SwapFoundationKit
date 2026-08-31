/// Injectable entitlement policy used by feature code that needs an access decision.
///
/// The foundation does not own subscription state. Hosts provide the policy from their
/// StoreKit, RevenueCat, or other entitlement source and decide how an upgrade is presented.
@MainActor
public protocol SFKAccessPolicy: AnyObject {
    var isProEnabled: Bool { get }
    func presentUpgrade(for reason: String)
}

/// Instance-based access gate for feature code. The gate has no global mutable state.
@MainActor
public final class SFKAccessGate {
    private let policy: any SFKAccessPolicy

    public init(policy: any SFKAccessPolicy) {
        self.policy = policy
    }

    @discardableResult
    public func check(_ reason: String) -> Bool {
        guard policy.isProEnabled else {
            policy.presentUpgrade(for: reason)
            return false
        }
        return true
    }

    public func require(_ reason: String, action: () -> Void) {
        if check(reason) { action() }
    }
}
