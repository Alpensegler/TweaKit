//
//  TweakSection+Tests.swift
//  TweaKit
//
//  Created by cokile
//

@testable import TweaKit
import XCTest

class TweakSectionTests: XCTestCase {
    override class func setUp() {
        super.setUp()
        Tweaks.reset()
    }

    func testNormalInit() {
        let section = TweakSection("Test") {
            Tweaks.$bool1
            Tweaks.$normalInt1
            Tweaks.$normalInt2
        }

        XCTAssertNil(section.list)
        XCTAssertNil(section.context)

        XCTAssertEqual(section.tweaks.count, 3)
        XCTAssertTrue(section.tweaks.allSatisfy { $0.section === section })
        XCTAssertTrue(section.tweaks[0] === Tweaks.$bool1)
        XCTAssertTrue(section.tweaks[1] === Tweaks.$normalInt1)
        XCTAssertTrue(section.tweaks[2] === Tweaks.$normalInt2)
    }

    func testInitTweakOrder() {
        let section = TweakSection("Test") {
            Tweaks.$normalInt2
            Tweaks.$bool1
            Tweaks.$normalInt1
        }

        XCTAssertTrue(section.tweaks[0] === Tweaks.$bool1)
        XCTAssertTrue(section.tweaks[1] === Tweaks.$normalInt1)
        XCTAssertTrue(section.tweaks[2] === Tweaks.$normalInt2)
    }

    func testSameTweakInit() {
        let section = TweakSection("Test") {
            Tweaks.$bool1
            Tweaks.$normalInt1
            Tweaks.$normalInt1
            Tweaks.$normalInt2
        }

        XCTAssertEqual(section.tweaks.count, 3)
        XCTAssertTrue(section.tweaks[0] === Tweaks.$bool1)
        XCTAssertTrue(section.tweaks[1] === Tweaks.$normalInt1)
        XCTAssertTrue(section.tweaks[2] === Tweaks.$normalInt2)
    }

    func testCopiedTweakInit() {
        let section = TweakSection("Test") {
            Tweaks.$bool1
            Tweaks.$normalInt1
            Tweaks.$normalInt1Copy
            Tweaks.$normalInt2
        }

        XCTAssertEqual(section.tweaks.count, 3)
        XCTAssertTrue(section.tweaks[0] === Tweaks.$bool1)
        XCTAssertTrue(section.tweaks[1] === Tweaks.$normalInt1)
        XCTAssertTrue(section.tweaks[2] === Tweaks.$normalInt2)
    }
}
