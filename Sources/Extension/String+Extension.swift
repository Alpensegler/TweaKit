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
    
    var md5: String {
        let data = Data(utf8)
        var hash = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        
        data.withUnsafeBytes { buffer in
            _ = CC_MD5(buffer.baseAddress, CC_LONG(buffer.count), &hash)
        }
        
        return hash.map { String(format: "%02hhx", $0) }.joined()
    }
}
