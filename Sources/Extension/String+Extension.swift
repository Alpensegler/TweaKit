//
//  String+Extension.swift
//  TweaKit
//
//  Created by cokile
//

import Foundation
import CommonCrypto

extension String {
    // From: https://gist.github.com/kharrison/2355182ac03b481921073c5cf6d77a73#file-country-swift-L31
    var djb2hash: Int {
        unicodeScalars.map(\.value).reduce(5381) {
            ($0 << 5) &+ $0 &+ Int($1)
        }
    }
    
    var sha256: String {
        let data = Data(utf8)
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        
        data.withUnsafeBytes { buffer in
            _ = CC_SHA256(buffer.baseAddress, CC_LONG(data.count), &hash)
        }
        
        return hash.map { String(format: "%02hhx", $0) }.joined()
    }
}
