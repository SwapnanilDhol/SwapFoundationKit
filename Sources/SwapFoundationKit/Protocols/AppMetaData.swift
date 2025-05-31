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
    var appID: String { get }
    var appName: String { get }
    var appShareDescription: String { get }
    var appInstagramUrl: URL? { get }
    var appTwitterUrl: URL? { get }
    var appWebsiteUrl: URL? { get }
    var appPrivacyPolicyUrl: URL? { get }
    var appEULAUrl: URL? { get }
    var appSupportEmail: String? { get }

    var developerWebsite: URL? { get }
 }