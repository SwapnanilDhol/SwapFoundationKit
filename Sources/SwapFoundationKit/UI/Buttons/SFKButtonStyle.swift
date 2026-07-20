/****************************************************************************
 * SFKButtonStyle.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2026 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI

/// The semantic role of an ``SFKButton``.
///
/// Choose a role based on hierarchy rather than a specific glass implementation:
///
/// - ``primary``: The main action in a flow.
/// - ``secondary``: A supporting or alternative action.
/// - ``toolbar``: A compact control placed in a system toolbar.
public enum SFKButtonStyle: Sendable {
    case primary
    case secondary
    case toolbar

    var defaultTitleColor: Color {
        switch self {
        case .primary:
            .white
        case .secondary, .toolbar:
            .primary
        }
    }

    var defaultSubtitleColor: Color {
        switch self {
        case .primary:
            Color.white.opacity(0.8)
        case .secondary, .toolbar:
            .secondary
        }
    }
}
