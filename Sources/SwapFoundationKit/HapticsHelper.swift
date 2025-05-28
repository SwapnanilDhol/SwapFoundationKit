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

import UIKit

@MainActor
public final class HapticsHelper {

    public enum HapticsIntensity: CGFloat {
        case buttonTapLight = 0.3
        case buttonTapMedium = 0.4
        case buttonTapHard = 0.5
        case cellTap = 0.35
        case barButtonTap = 0.31
        case segmentValueChange = 0.45
        case tabBarButtonTap = 0.41
    }

    private let impactFeedbackGenerator = UIImpactFeedbackGenerator()
    private let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
    public static let shared = HapticsHelper()

    public init() {
        impactFeedbackGenerator.prepare()
        notificationFeedbackGenerator.prepare()
    }

    public func lightButtonTap() {
        impactFeedbackGenerator.impactOccurred(intensity: HapticsIntensity.buttonTapLight.rawValue)
    }

    public func mediumButtonTap() {
        impactFeedbackGenerator.impactOccurred(intensity: HapticsIntensity.buttonTapMedium.rawValue)
    }

    public func hardButtonTap() {
        impactFeedbackGenerator.impactOccurred(intensity: HapticsIntensity.buttonTapHard.rawValue)
    }

    public func cellTap() {
        impactFeedbackGenerator.impactOccurred(intensity: HapticsIntensity.cellTap.rawValue)
    }

    public func barButtonTap() {
        impactFeedbackGenerator.impactOccurred(intensity: HapticsIntensity.barButtonTap.rawValue)
    }

    public func segmentChangedValue() {
        impactFeedbackGenerator.impactOccurred(intensity: HapticsIntensity.segmentValueChange.rawValue)
    }

    public func success() {
        notificationFeedbackGenerator.notificationOccurred(.success)
    }

    public func warning() {
        notificationFeedbackGenerator.notificationOccurred(.warning)
    }

    public func error() {
        notificationFeedbackGenerator.notificationOccurred(.error)
    }
}
