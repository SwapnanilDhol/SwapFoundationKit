/*****************************************************************************
 * HapticsHelper.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import Foundation
import UIKit

/// A helper class for managing haptic feedback in iOS applications.
/// Provides easy-to-use methods for different types of haptic feedback.
@MainActor
public final class HapticsHelper {
    
    private let impactFeedbackGenerator = UIImpactFeedbackGenerator()
    private let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
    
    public init() {
        impactFeedbackGenerator.prepare()
        notificationFeedbackGenerator.prepare()
    }
    
    /// Triggers a light impact haptic feedback.
    public func lightImpact() {
        impactFeedbackGenerator.impactOccurred(intensity: 0.3)
    }
    
    /// Triggers a medium impact haptic feedback.
    public func mediumImpact() {
        impactFeedbackGenerator.impactOccurred(intensity: 0.6)
    }
    
    /// Triggers a heavy impact haptic feedback.
    public func heavyImpact() {
        impactFeedbackGenerator.impactOccurred(intensity: 1.0)
    }
    
    /// Triggers a success notification haptic feedback.
    public func successNotification() {
        notificationFeedbackGenerator.notificationOccurred(.success)
    }
    
    /// Triggers a warning notification haptic feedback.
    public func warningNotification() {
        notificationFeedbackGenerator.notificationOccurred(.warning)
    }
    
    /// Triggers an error notification haptic feedback.
    public func errorNotification() {
        notificationFeedbackGenerator.notificationOccurred(.error)
    }
    
    /// Triggers a custom impact haptic feedback with specified intensity.
    /// - Parameter intensity: The intensity of the haptic feedback (0.0 to 1.0).
    public func customImpact(intensity: CGFloat) {
        let clampedIntensity = max(0.0, min(1.0, intensity))
        impactFeedbackGenerator.impactOccurred(intensity: clampedIntensity)
    }
}
