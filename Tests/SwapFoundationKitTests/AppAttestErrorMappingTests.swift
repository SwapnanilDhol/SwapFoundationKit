/****************************************************************************
 * AppAttestErrorMappingTests.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import DeviceCheck
import Foundation
import Testing
@testable import SwapFoundationKit
@testable import SwapFoundationKitAuthentication

struct AppAttestErrorMappingTests {
    @Test(arguments: [
        (DCError.invalidKey.rawValue, AppAttestError.keyInvalid),
        (DCError.serverUnavailable.rawValue, AppAttestError.transientAppleFailure),
        (DCError.unknownSystemFailure.rawValue, AppAttestError.transientAppleFailure),
        (DCError.featureUnsupported.rawValue, AppAttestError.unsupported),
        (DCError.invalidInput.rawValue, AppAttestError.invalidClientData)
    ])
    func mapsAppleCodes(input: (Int, AppAttestError)) {
        let error = NSError(domain: DCErrorDomain, code: input.0)
        #expect(AppAttestService.mapAppleError(error, fallback: .assertionFailed) == input.1)
    }

    @Test
    func preservesUnknownFallbackAndExistingAppAttestErrors() {
        let unknown = NSError(domain: DCErrorDomain, code: 99)
        #expect(AppAttestService.mapAppleError(unknown, fallback: .assertionFailed) == .assertionFailed)
        #expect(AppAttestService.mapAppleError(AppAttestError.keyInvalid, fallback: .assertionFailed) == .keyInvalid)
    }
}
