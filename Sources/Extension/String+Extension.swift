//
//  String+Extension.swift
//  TweaKit
//
//  Created by cokile
//

import Foundation

extension String {
    // From: https://gist.github.com/kharrison/2355182ac03b481921073c5cf6d77a73#file-country-swift-L31
    var djb2hash: Int {
        unicodeScalars.map(\.value).reduce(5381) {
            ($0 << 5) &+ $0 &+ Int($1)
        }
    }
}
