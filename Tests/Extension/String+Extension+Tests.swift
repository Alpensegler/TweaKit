//
//  String+MD5+Tests.swift
//  TweaKit
//
//  Created by cokile
//

import XCTest
@testable import TweaKit

class StringExtensionTests: XCTestCase {
    func testDJB2HashConsistency() {
        let lhs = "TweaKit"
        let rhs = 229443105429566
        XCTAssertEqual(lhs.djb2hash, rhs)
        XCTAssertEqual(lhs.djb2hash, rhs)
        XCTAssertEqual(lhs.djb2hash, rhs)
    }
    
    func testDJB2HashCorrectness() {
        XCTAssertEqual("TweaKit".djb2hash, 229443105429566)
        XCTAssertEqual("TweaKit".lowercased().djb2hash, 229484432439422)
        XCTAssertEqual("TweaKit".uppercased().djb2hash, 229441813996446)
    }
    
    func testShortStringDJB2HashPerformance() {
        measure {
            _ = "TweaKit".djb2hash
        }
    }
    
    func testLongStringDJB2HashPerformance() {
        let sample = Array(repeating: "TweaKit", count: 100_000).joined()
        
        measure {
            _ = sample.djb2hash
        }
    }
}
