//
//  Tweaks.swift
//  TweaKitTests
//
//  Created by cokile
//

@testable import TweaKit

enum Tweaks {
    @Tweak(name: "NormalInt1", defaultValue: 0, from: 0, to: 10, stride: 1)
    static var normalInt1: Int
    @Tweak(name: "NormalInt1", defaultValue: 0, from: 0, to: 10, stride: 1)
    static var normalInt1Copy: Int
    @Tweak(name: "NormalInt2", defaultValue: 1, from: 0, to: 10, stride: 1)
    static var normalInt2: Int
    
    @Tweak(name: "Bool1", defaultValue: false)
    static var bool1: Bool
    
    // Don't forget to invoke testableReset method for newly added tweaks
    static func reset() {
        $normalInt1.testableReset()
        $normalInt1Copy.testableReset()
        $normalInt2.testableReset()
        
        $bool1.testableReset()
    }
}

extension AnyTweak {
    func testableReset() {
        resetInfo()
        resetStoredValue()
        section?.list = nil
        section = nil
    }
}
