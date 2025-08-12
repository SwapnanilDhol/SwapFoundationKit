/*****************************************************************************
 * FeedbackGenerators.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import Foundation

#if canImport(UIKit) && os(iOS)
import UIKit
#endif

/// A helper class for managing haptic feedback in iOS applications.
/// Provides easy-to-use methods for different types of haptic feedback.
@MainActor
public final class HapticsHelper {
    
    #if canImport(UIKit) && os(iOS)
    private let impactFeedbackGenerator = UIImpactFeedbackGenerator()
    private let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
    #endif
    
    public init() {
        #if canImport(UIKit) && os(iOS)
        impactFeedbackGenerator.prepare()
        notificationFeedbackGenerator.prepare()
        #endif
    }
    
    /// Triggers a light impact haptic feedback.
    public func lightImpact() {
        #if canImport(UIKit) && os(iOS)
        impactFeedbackGenerator.impactOccurred(intensity: 0.3)
        #endif
    }
    
    /// Triggers a medium impact haptic feedback.
    public func mediumImpact() {
        #if canImport(UIKit) && os(iOS)
        impactFeedbackGenerator.impactOccurred(intensity: 0.6)
        #endif
    }
    
    /// Triggers a heavy impact haptic feedback.
    public func heavyImpact() {
        #if canImport(UIKit) && os(iOS)
        impactFeedbackGenerator.impactOccurred(intensity: 1.0)
        #endif
    }
    
    /// Triggers a success notification haptic feedback.
    public func successNotification() {
        #if canImport(UIKit) && os(iOS)
        notificationFeedbackGenerator.notificationOccurred(.success)
        #endif
    }
    
    /// Triggers a warning notification haptic feedback.
    public func warningNotification() {
        #if canImport(UIKit) && os(iOS)
        notificationFeedbackGenerator.notificationOccurred(.warning)
        #endif
    }
    
    /// Triggers an error notification haptic feedback.
    public func errorNotification() {
        #if canImport(UIKit) && os(iOS)
        notificationFeedbackGenerator.notificationOccurred(.error)
        #endif
    }
    
    /// Triggers a custom impact haptic feedback with specified intensity.
    /// - Parameter intensity: The intensity of the haptic feedback (0.0 to 1.0).
    public func customImpact(intensity: CGFloat) {
        #if canImport(UIKit) && os(iOS)
        let clampedIntensity = max(0.0, min(1.0, intensity))
        impactFeedbackGenerator.impactOccurred(intensity: clampedIntensity)
        #endif
    }
}
