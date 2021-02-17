//
//  Tweak+Info+Tests.swift
//  TweaKitTests
//
//  Created by cokile
//

import XCTest
@testable import TweaKit

class TweakAndInfoTests: XCTestCase {
    @Tweak(name: "Bool", defaultValue: false)
    var bool: Bool
    
    var context: TweakContext?
    
    override func setUp() {
        super.setUp()
        $bool.testableReset()
    }
    
    // MARK: - Transisent Info
    
    func testValueTransformer() {
        XCTAssertEqual(bool, false)
        
        $bool.setValueTransformer { $0 ? false : true }
        XCTAssertEqual(bool, true)
        
        $bool.setValueTransformer { $0 }
        XCTAssertEqual(bool, false)
    }
    
    func testUserInteractionEnabled() {
        XCTAssertEqual($bool.isUserInteractionEnabled, true)
        
        $bool.disableUserInteraction()
        XCTAssertEqual($bool.isUserInteractionEnabled, false)
    }
    
    func testExportPresets() {
        XCTAssertEqual($bool.exportPresets, [])
        
        $bool.addExportPreset("p1")
        XCTAssertEqual($bool.exportPresets, ["p1"])
        
        $bool.addExportPreset("p2")
        XCTAssertEqual($bool.exportPresets, ["p1", "p2"])
        
        $bool.addExportPreset("p3")
        XCTAssertEqual($bool.exportPresets, ["p1", "p2", "p3"])
    }
    
    func testTrumpOverImport() {
        XCTAssertEqual($bool.isTrumpOverImport, false)
        
        $bool.trumpOverImport()
        XCTAssertEqual($bool.isTrumpOverImport, true)
    }
    
    // MARK: - Persistent Info
    
    func testDidChangeManually() {
        XCTAssertEqual($bool.didChangeManually, false)
        
        $bool.didChangeManually.toggle()
        XCTAssertEqual($bool.didChangeManually, true)
        
        context = TweakContext {
            TweakList("List") {
                TweakSection("Section") {
                    $bool
                }
            }
        }
        
        XCTAssertEqual($bool.didChangeManually, true)
        
        $bool.didChangeManually.toggle()
        XCTAssertEqual($bool.didChangeManually, false)
    }
}
