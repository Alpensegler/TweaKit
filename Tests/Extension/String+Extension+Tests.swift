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
    func testSHA256Consistency() {
        let lhs = "TweaKit"
        let rhs = "17de357825fc04f8ab580087f9ceeb382c81da12b53c004760516d44dbfb6c62"
        XCTAssertEqual(lhs.sha256, rhs)
        XCTAssertEqual(lhs.sha256, rhs)
        XCTAssertEqual(lhs.sha256, rhs)
    }
    
    // Comparsion result from shell command: md5
    func testSHA256Correctness() {
        XCTAssertEqual("TweaKit".sha256, "17de357825fc04f8ab580087f9ceeb382c81da12b53c004760516d44dbfb6c62")
        XCTAssertEqual("TweaKit".lowercased().sha256, "4bf6410b193c36c62e7fc8cdec6f83a0f2d6914312636d6f54cbc2ec9f5c4995")
        XCTAssertEqual("TweaKit".uppercased().sha256, "f250dea140bebca3ec0c5fc15e3fba690a5414d10ec9d05a3ef48ef505551ab7")
    }
    
    func testShortStringSHA256Performance() {
        measure {
            _ = "TweaKit".sha256
        }
    }
    
    func testLongStringSHA256Performance() {
        let sample = Array(repeating: "TweaKit", count: 100_000).joined()
        
        measure {
            _ = sample.sha256
        }
    }
}
