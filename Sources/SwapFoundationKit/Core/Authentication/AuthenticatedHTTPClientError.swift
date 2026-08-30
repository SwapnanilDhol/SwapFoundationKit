/****************************************************************************
 * AuthenticatedHTTPClientError.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/
public enum AuthenticatedHTTPClientError: Error, Equatable, Sendable {
    case invalidOrigin
    case identityChanged
    case missingIdentity
}
