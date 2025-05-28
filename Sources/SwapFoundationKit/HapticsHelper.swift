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
    static let shared = HapticsHelper()

    public init() {
        impactFeedbackGenerator.prepare()
        notificationFeedbackGenerator.prepare()
    }

    func lightButtonTap() {
        impactFeedbackGenerator.impactOccurred(intensity: HapticsIntensity.buttonTapLight.rawValue)
    }

    func mediumButtonTap() {
        impactFeedbackGenerator.impactOccurred(intensity: HapticsIntensity.buttonTapMedium.rawValue)
    }

    func hardButtonTap() {
        impactFeedbackGenerator.impactOccurred(intensity: HapticsIntensity.buttonTapHard.rawValue)
    }

    func cellTap() {
        impactFeedbackGenerator.impactOccurred(intensity: HapticsIntensity.cellTap.rawValue)
    }

    func barButtonTap() {
        impactFeedbackGenerator.impactOccurred(intensity: HapticsIntensity.barButtonTap.rawValue)
    }

    func segmentChangedValue() {
        impactFeedbackGenerator.impactOccurred(intensity: HapticsIntensity.segmentValueChange.rawValue)
    }

    func success() {
        notificationFeedbackGenerator.notificationOccurred(.success)
    }

    func warning() {
        notificationFeedbackGenerator.notificationOccurred(.warning)
    }

    func error() {
        notificationFeedbackGenerator.notificationOccurred(.error)
    }
}
