//
//  TweakContext+Tests.swift
//  TweaKit
//
//  Created by cokile
//

import XCTest
@testable import TweaKit

class TweakContextTests: XCTestCase {
    override class func setUp() {
        super.setUp()
        Tweaks.reset()
    }
    
    func testNormalInit() {
        let section1 = TweakSection("Section1") {
            Tweaks.$normalInt1
        }
        
        let section2 = TweakSection("Section2") {
            Tweaks.$normalInt2
        }
        
        let list1 = TweakList("List1") {
            section1
        }
        
        let list2 = TweakList("List2") {
            section2
        }
        
        let context = TweakContext {
            list1
            list2
        }
        
        XCTAssertEqual(context.lists.count, 2)
        XCTAssertTrue(context.lists[0] === list1)
        XCTAssertTrue(context.lists[1] === list2)
        
        XCTAssertEqual(context.sections.count, 2)
        XCTAssertTrue(context.sections[0] === section1)
        XCTAssertTrue(context.sections[1] === section2)
        
        XCTAssertEqual(context.tweaks.count, 2)
        XCTAssertTrue(context.tweaks[0] === Tweaks.$normalInt1)
        XCTAssertTrue(context.tweaks[1] === Tweaks.$normalInt2)
    }
    
    func testInitListOrder() {
        let section1 = TweakSection("Section1") {
            Tweaks.$normalInt1
        }
        
        let section2 = TweakSection("Section2") {
            Tweaks.$normalInt2
        }
        
        let list1 = TweakList("List1") {
            section1
        }
        
        let list2 = TweakList("List2") {
            section2
        }
        
        let context = TweakContext {
            list2
            list1
        }
        
        XCTAssertEqual(context.lists.count, 2)
        XCTAssertTrue(context.lists[0] === list1)
        XCTAssertTrue(context.lists[1] === list2)
        
        XCTAssertEqual(context.sections.count, 2)
        XCTAssertTrue(context.sections[0] === section1)
        XCTAssertTrue(context.sections[1] === section2)
        
        XCTAssertEqual(context.tweaks.count, 2)
        XCTAssertTrue(context.tweaks[0] === Tweaks.$normalInt1)
        XCTAssertTrue(context.tweaks[1] === Tweaks.$normalInt2)
    }
    
    func testSameListInit() {
        let section1 = TweakSection("Section1") {
            Tweaks.$normalInt1
        }
        
        let section2 = TweakSection("Section2") {
            Tweaks.$normalInt2
        }
        
        let list1 = TweakList("List1") {
            section1
        }
        
        let list2 = TweakList("List2") {
            section2
        }
        
        let context = TweakContext {
            list1
            list1
            list2
        }
        
        XCTAssertEqual(context.lists.count, 2)
        XCTAssertTrue(context.lists[0] === list1)
        XCTAssertTrue(context.lists[1] === list2)
        
        XCTAssertEqual(context.sections.count, 2)
        XCTAssertTrue(context.sections[0] === section1)
        XCTAssertTrue(context.sections[1] === section2)
        
        XCTAssertEqual(context.tweaks.count, 2)
        XCTAssertTrue(context.tweaks[0] === Tweaks.$normalInt1)
        XCTAssertTrue(context.tweaks[1] === Tweaks.$normalInt2)
    }
    
    func testCopiedListInit() {
        let section1 = TweakSection("Section1") {
            Tweaks.$normalInt1
        }
        
        let section2 = TweakSection("Section2") {
            Tweaks.$normalInt2
        }
        
        let list1 = TweakList("List1") {
            section1
        }
        
        let list1Copy = TweakList("List1") {
            section1
        }
        
        let list2 = TweakList("List2") {
            section2
        }
        
        let context = TweakContext {
            list1
            list1Copy
            list2
        }
        
        XCTAssertEqual(context.lists.count, 2)
        XCTAssertTrue(context.lists[0] === list1)
        XCTAssertTrue(context.lists[1] === list2)
        
        XCTAssertEqual(context.sections.count, 2)
        XCTAssertTrue(context.sections[0] === section1)
        XCTAssertTrue(context.sections[1] === section2)
        
        XCTAssertEqual(context.tweaks.count, 2)
        XCTAssertTrue(context.tweaks[0] === Tweaks.$normalInt1)
        XCTAssertTrue(context.tweaks[1] === Tweaks.$normalInt2)
    }
}
