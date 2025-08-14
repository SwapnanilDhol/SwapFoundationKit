/*****************************************************************************
 * Data+Crypto.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import Foundation
#if canImport(CommonCrypto)
import CommonCrypto
#endif

public extension Data {
    
    /// Returns the MD5 hash of the data
    var md5: String {
        #if canImport(CommonCrypto)
        var hash = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        withUnsafeBytes { buffer in
            _ = CC_MD5(buffer.baseAddress, CC_LONG(count), &hash)
        }
        return hash.map { String(format: "%02hhx", $0) }.joined()
        #else
        // Fallback for platforms without CommonCrypto
        return ""
        #endif
    }
    
    /// Returns the SHA1 hash of the data
    var sha1: String {
        #if canImport(CommonCrypto)
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        withUnsafeBytes { buffer in
            _ = CC_SHA1(buffer.baseAddress, CC_LONG(count), &hash)
        }
        return hash.map { String(format: "%02hhx", $0) }.joined()
        #else
        // Fallback for platforms without CommonCrypto
        return ""
        #endif
    }
    
    /// Returns the SHA256 hash of the data
    var sha256: String {
        #if canImport(CommonCrypto)
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        withUnsafeBytes { buffer in
            _ = CC_SHA256(buffer.baseAddress, CC_LONG(count), &hash)
        }
        return hash.map { String(format: "%02hhx", $0) }.joined()
        #else
        // Fallback for platforms without CommonCrypto
        return ""
        #endif
    }
}
