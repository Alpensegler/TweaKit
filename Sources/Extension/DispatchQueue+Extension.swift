//
//  DispatchQueue+Extension.swift
//  TweaKit
//
//  Created by cokile
//

// swiftlint:disable line_length
/*
 The `isMain` is from
 [RxSwift](https://github.com/ReactiveX/RxSwift/blob/1a1fa37b0d08e0f99ffa41f98f340e8bc60c35c4/Platform/DispatchQueue%2BExtensions.swift)

 **The MIT License**
 **Copyright © 2015 Krunoslav Zaher, Shai Mishali**
 **All rights reserved.**

 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
// swiftlint:enable line_length

import Foundation

extension DispatchQueue {
    static var isMain: Bool {
        getSpecific(key: token) != nil
    }

    private static var token: DispatchSpecificKey<Void> = {
        let key = DispatchSpecificKey<Void>()
        main.setSpecific(key: key, value: ())
        return key
    }()
}

extension DispatchQueue {
    static func ensureInMain() {
        dispatchPrecondition(condition: .onQueue(main))
    }
}
