/*****************************************************************************
 * AppMetaData.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import Foundation

public protocol AppMetaData {
    static var appID: String { get }
    static var appName: String { get }
    static var appShareDescription: String { get }
    static var appInstagramUrl: URL? { get }
    static var appTwitterUrl: URL? { get }
    static var appWebsiteUrl: URL? { get }
    static var appPrivacyPolicyUrl: URL? { get }
    static var appEULAUrl: URL? { get }
    static var appSupportEmail: String? { get }

    static var developerWebsite: URL? { get }
}
