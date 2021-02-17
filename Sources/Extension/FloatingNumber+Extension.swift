//
//  FloatingNumber+Extension.swift
//  TweaKit
//
//  Created by cokile
//

// The Roundable implementation is a modification base on SwiftTweak
// https://github.com/Khan/SwiftTweaks/blob/master/SwiftTweaks/Precision.swift
/*
 The MIT License (MIT)

 Copyright (c) 2016 Khan Academy

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import Foundation
import CoreGraphics

enum RoundlLevel: Int {
    case integer
    case tenth
    case hundredth
    case thousandth
}

protocol Roundable: BinaryFloatingPoint {
    func rounded() -> Self
}

extension Roundable {
    func rounded(to level: RoundlLevel) -> Self {
        let precision = pow(10, -Double(level.rawValue))
        let base = (Double(self) / precision).rounded()
        return Self(Double(base) * precision)
    }
}

extension Float: Roundable { }
extension Double: Roundable { }
extension CGFloat: Roundable { }
