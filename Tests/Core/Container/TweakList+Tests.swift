//
//  TweakList+Tests.swift
//  TweaKitTests
//
//  Created by cokile
//

import XCTest
@testable import TweaKit

class TweakListTests: XCTestCase {
    override class func setUp() {
        super.setUp()
        Tweaks.reset()
    }
    
    func testNormalInit() {
        let section1 = TweakSection("Section1") {
            Tweaks.$normalInt1
        }
        
        let section2 = TweakSection("Section2") {
            Tweaks.$bool1
            Tweaks.$normalInt2
        }
        
        let list = TweakList("List") {
            section1
            section2
        }
        
        XCTAssertNil(list.context)
        
        XCTAssertEqual(list.sections.count, 2)
        XCTAssertTrue(list.sections[0] === section1)
        XCTAssertTrue(list.sections[1] === section2)
        
        XCTAssertEqual(list.tweaks.count, section1.tweaks.count + section2.tweaks.count)
        XCTAssertTrue(list.tweaks[0] === Tweaks.$normalInt1)
        XCTAssertTrue(list.tweaks[1] === Tweaks.$bool1)
        XCTAssertTrue(list.tweaks[2] === Tweaks.$normalInt2)
    }
    
    func testInitSectionOrder() {
        let section1 = TweakSection("Section1") {
            Tweaks.$normalInt1
        }
        
        let section2 = TweakSection("Section2") {
            Tweaks.$bool1
            Tweaks.$normalInt2
        }
        
        let list = TweakList("List") {
            section2
            section1
        }
        
        XCTAssertTrue(list.sections[0] === section1)
        XCTAssertTrue(list.sections[1] === section2)
        
        XCTAssertEqual(list.tweaks.count, section1.tweaks.count + section2.tweaks.count)
        XCTAssertTrue(list.tweaks[0] === Tweaks.$normalInt1)
        XCTAssertTrue(list.tweaks[1] === Tweaks.$bool1)
        XCTAssertTrue(list.tweaks[2] === Tweaks.$normalInt2)
    }
    
    func testSameSectionInit() {
        let section1 = TweakSection("Section1") {
            Tweaks.$normalInt1
        }
        
        let section2 = TweakSection("Section2") {
            Tweaks.$bool1
            Tweaks.$normalInt2
        }
        
        let list = TweakList("List") {
            section1
            section1
            section2
        }
        
        XCTAssertEqual(list.sections.count, 2)
        XCTAssertTrue(list.sections[0] === section1)
        XCTAssertTrue(list.sections[1] === section2)
        
        XCTAssertEqual(list.tweaks.count, section1.tweaks.count + section2.tweaks.count)
        XCTAssertTrue(list.tweaks[0] === Tweaks.$normalInt1)
        XCTAssertTrue(list.tweaks[1] === Tweaks.$bool1)
        XCTAssertTrue(list.tweaks[2] === Tweaks.$normalInt2)
    }
    
    func testCopiedSectionInit() {
        let section1 = TweakSection("Section1") {
            Tweaks.$normalInt1
        }
        
        let section1Copy = TweakSection("Section1") {
            Tweaks.$normalInt1
        }
        
        let section2 = TweakSection("Section2") {
            Tweaks.$bool1
            Tweaks.$normalInt2
        }
        
        let list = TweakList("List") {
            section1
            section1Copy
            section2
        }
        
        XCTAssertEqual(list.sections.count, 2)
        XCTAssertTrue(list.sections[0] === section1)
        XCTAssertTrue(list.sections[1] === section2)
        
        XCTAssertEqual(list.tweaks.count, section1.tweaks.count + section2.tweaks.count)
        XCTAssertTrue(list.tweaks[0] === Tweaks.$normalInt1)
        XCTAssertTrue(list.tweaks[1] === Tweaks.$bool1)
        XCTAssertTrue(list.tweaks[2] === Tweaks.$normalInt2)
    }
}
