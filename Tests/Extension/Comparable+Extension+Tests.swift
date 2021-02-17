//
//  Comparable+Extension+Tests.swift
//  TweaKit
//
//  Created by cokile
//

import XCTest
@testable import TweaKit

class ComparableExtensionTests: XCTestCase {
    func testNormalIntClamp() {
        let from: Int = 10
        let to: Int = 15
        
        var value: Int = 11
        XCTAssertEqual(value.clamped(from: from, to: to), 11)
        value = 12
        XCTAssertEqual(value.clamped(from: from, to: to), 12)
        
        value = from
        XCTAssertEqual(value.clamped(from: from, to: to), from)
        value = from - 1
        XCTAssertEqual(value.clamped(from: from, to: to), from)
        
        value = to
        XCTAssertEqual(value.clamped(from: from, to: to), to)
        value = to + 1
        XCTAssertEqual(value.clamped(from: from, to: to), to)
    }
    
    func testSameBoundIntClamp() {
        let from: Int = 10
        let to: Int = 10
        
        var value: Int = 11
        XCTAssertEqual(value.clamped(from: from, to: to), from)
        value = 12
        XCTAssertEqual(value.clamped(from: from, to: to), from)
        
        value = from
        XCTAssertEqual(value.clamped(from: from, to: to), from)
        value = from - 1
        XCTAssertEqual(value.clamped(from: from, to: to), from)
        
        value = to
        XCTAssertEqual(value.clamped(from: from, to: to), from)
        value = to + 1
        XCTAssertEqual(value.clamped(from: from, to: to), from)
    }
    
    func testNormalFloatClamp() {
        let from: Float = 10
        let to: Float = 15
        
        var value: Float = 11
        XCTAssertEqual(value.clamped(from: from, to: to), 11)
        value = 12
        XCTAssertEqual(value.clamped(from: from, to: to), 12)
        
        value = from
        XCTAssertEqual(value.clamped(from: from, to: to), from)
        value = from - 1
        XCTAssertEqual(value.clamped(from: from, to: to), from)
        
        value = to
        XCTAssertEqual(value.clamped(from: from, to: to), to)
        value = to + 1
        XCTAssertEqual(value.clamped(from: from, to: to), to)
    }
    
    func testSameBoundFloatClamp() {
        let from: Float = 10
        let to: Float = 10
        
        var value: Float = 11
        XCTAssertEqual(value.clamped(from: from, to: to), from)
        value = 12
        XCTAssertEqual(value.clamped(from: from, to: to), from)
        
        value = from
        XCTAssertEqual(value.clamped(from: from, to: to), from)
        value = from - 1
        XCTAssertEqual(value.clamped(from: from, to: to), from)
        
        value = to
        XCTAssertEqual(value.clamped(from: from, to: to), from)
        value = to + 1
        XCTAssertEqual(value.clamped(from: from, to: to), from)
    }
}
