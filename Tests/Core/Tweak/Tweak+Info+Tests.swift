//
//  Tweak+Info+Tests.swift
//  TweaKitTests
//
//  Created by cokile
//

@testable import TweaKit
import XCTest

class TweakAndInfoTests: XCTestCase {
    @Tweak(name: "Bool", defaultValue: false)
    var bool: Bool
    @Tweak(name: "String", defaultValue: "")
    var string: String

    var context: TweakContext?

    override func setUp() {
        super.setUp()
        $bool.testableReset()
        $string.testableReset()
    }

    // MARK: - Transient Info

    func testValueTransformers() {
        XCTAssertEqual(string, "")

        $string.addValueTransformer { $0.appending("1") }
        XCTAssertEqual(string, "1")

        $string.addValueTransformer { $0.appending("2") }
        XCTAssertEqual(string, "12")

        $string.addValueTransformer { $0.appending("3") }
        XCTAssertEqual(string, "123")
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

    func testImportedValueTrumpsManuallyChangedValue() {
        XCTAssertEqual($bool.isImportedValueTrumpsManuallyChangedValue, false)

        $bool.setImportedValueTrumpsManuallyChangedValue()
        XCTAssertEqual($bool.isImportedValueTrumpsManuallyChangedValue, true)
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
