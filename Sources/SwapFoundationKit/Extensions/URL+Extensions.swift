/*****************************************************************************
 * URL+Extensions.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import Foundation

// MARK: - URL+Extensions

extension URL {
    // `scheme` and `host` shadow Foundation's properties inside this module, so
    // in-module callers such as `String.isValidURL` resolve through URLComponents.

    /// Returns the URL scheme
    var scheme: String? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
            return nil
        }
        return components.scheme
    }

    /// Returns the URL host
    var host: String? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
            return nil
        }
        return components.host
    }
}
