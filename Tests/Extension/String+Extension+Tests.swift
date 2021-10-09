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
    
    // Comparsion result from shell command: md5
        func testMD5Consistency() {
            let lhs = "TweaKit"
            let rhs = "fdf33e0888b7541550533df7676e4367"
            XCTAssertEqual(lhs.md5, rhs)
            XCTAssertEqual(lhs.md5, rhs)
            XCTAssertEqual(lhs.md5, rhs)
        }
        
        // Comparsion result from shell command: md5
        func testMD5Correctness() {
            XCTAssertEqual("TweaKit".md5, "fdf33e0888b7541550533df7676e4367")
            XCTAssertEqual("TweaKit".lowercased().md5, "03fcd11573d3428deebec36c54acf927")
            XCTAssertEqual("TweaKit".uppercased().md5, "41a5558db5ee58da097ece5a3405dd02")
        }
        
        func testShortStringMD5Performance() {
            measure {
                _ = "TweaKit".md5
            }
        }
        
        func testLongStringMD5Performance() {
            let sample = Array(repeating: "TweaKit", count: 100_000).joined()
            
            measure {
                _ = sample.md5
            }
        }
}
