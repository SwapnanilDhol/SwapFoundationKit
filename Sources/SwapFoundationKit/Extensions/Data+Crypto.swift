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
import CryptoKit
import CommonCrypto

public extension Data {
    
    /// Returns the MD5 hash of the data
    var md5: String {
        let digest = Insecure.MD5.hash(data: self)
        return digest.map { String(format: "%02hhx", $0) }.joined()
    }
    
    /// Returns the SHA1 hash of the data
    var sha1: String {
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        withUnsafeBytes { buffer in
            _ = CC_SHA1(buffer.baseAddress, CC_LONG(count), &hash)
        }
        return hash.map { String(format: "%02hhx", $0) }.joined()
    }
    
    /// Returns the SHA256 hash of the data
    var sha256: String {
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        withUnsafeBytes { buffer in
            _ = CC_SHA256(buffer.baseAddress, CC_LONG(count), &hash)
        }
        return hash.map { String(format: "%02hhx", $0) }.joined()
    }
}
