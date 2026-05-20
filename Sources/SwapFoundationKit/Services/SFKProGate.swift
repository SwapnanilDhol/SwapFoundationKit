#if canImport(UIKit) && os(iOS)
import UIKit
import SwiftUI

/// A feature-gating pattern that checks Pro/entitlement status and automatically
/// presents an upsell sheet when a gated feature is accessed without Pro.
///
/// SFK does not manage subscription state itself — you supply the `isProEnabled`
/// and `presentProSheet` closures. This allows integration with any IAP framework
/// (RevenueCat, StoreKit, SwapProKit, etc.).
///
/// ## Usage
/// ```swift
/// // Configure once at app launch:
/// SFKProGate.isProEnabled = { ProManager.shared.isProEnabled }
/// SFKProGate.presentProSheet = { reason in
///     ProManager.shared.presentProSheet(for: reason)
/// }
///
/// // Guard a feature:
/// SFKProGate.require("exportCSV") {
///     exportCSV()
/// }
///
/// // As a condition:
/// guard SFKProGate.check("addNote") else { return }
/// addNoteToTransaction()
/// ```
@MainActor
public enum SFKProGate {

    /// Closure that returns `true` when the user has Pro access.
    /// Set this at app launch before any gate checks.
    public static var isProEnabled: (() -> Bool)?

    /// Closure that presents the Pro upsell sheet for a given reason key.
    /// Set this at app launch before any gate checks.
    public static var presentProSheet: ((String) -> Void)?

    /// Checks Pro status and presents the upsell sheet if not enabled.
    /// - Parameter reason: A short key identifying the gated feature (e.g., `"exportCSV"`).
    /// - Returns: `true` if the feature is accessible, `false` if Pro is required.
    @discardableResult
    public static func check(_ reason: String) -> Bool {
        guard !SFKLaunchArguments.isAutomationMode else { return true }
        guard isProEnabled?() != true else { return true }
        presentProSheet?(reason)
        return false
    }

    /// Guards execution of an action behind Pro. If the user does not have Pro,
    /// the upsell sheet is presented and the action is skipped.
    /// - Parameters:
    ///   - reason: A short key identifying the gated feature.
    ///   - action: The closure to execute if Pro is enabled.
    public static func require(_ reason: String, action: () -> Void) {
        if check(reason) {
            action()
        }
    }
}
#endif
