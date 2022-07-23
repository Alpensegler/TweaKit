//
//  UIColor+Extension+Tests.swift
//  TweaKitTests
//
//  Created by cokile
//

@testable import TweaKit
import XCTest

class UIColorExtensionTests: XCTestCase {
    func testRGBA() {
        let trials: [(UIColor.RGBA, RGBA)] = [
            (UIColor.red.rgba, (255, 0, 0, 1)),
            (UIColor.red.withAlphaComponent(0.1).rgba, (255, 0, 0, 0.1)),
            (UIColor.green.rgba, (0, 255, 0, 1)),
            (UIColor.green.withAlphaComponent(0.3).rgba, (0, 255, 0, 0.3)),
            (UIColor.blue.rgba, (0, 0, 255, 1)),
            (UIColor.blue.withAlphaComponent(0.5).rgba, (0, 0, 255, 0.5)),
            (UIColor.white.rgba, (255, 255, 255, 1)),
            (UIColor.white.withAlphaComponent(0.7).rgba, (255, 255, 255, 0.7)),
            (UIColor.black.rgba, (0, 0, 0, 1)),
            (UIColor.black.withAlphaComponent(0.9).rgba, (0, 0, 0, 0.9)),
        ]
        for trial in trials {
            XCTAssertEqual(trial.0.r, trial.1.r)
            XCTAssertEqual(trial.0.g, trial.1.g)
            XCTAssertEqual(trial.0.b, trial.1.b)
            XCTAssertEqual(trial.0.a, trial.1.a, accuracy: CGFloat.ulpOfOne)
        }
    }

    func testInitFromHex() {
        var hexString = "#FF0000"
        XCTAssertTrue(UIColor(hexString: hexString)!.isEqual(to: .red))
        hexString = "0xFF0000"
        XCTAssertTrue(UIColor(hexString: hexString)!.isEqual(to: .red))
        hexString = "FF0000"
        XCTAssertTrue(UIColor(hexString: hexString)!.isEqual(to: .red))

        hexString = "1AFF0000"
        XCTAssertTrue(UIColor(hexString: hexString)!.isEqual(to: UIColor.red.withAlphaComponent(0.1)))
        hexString = "4DFF0000"
        XCTAssertTrue(UIColor(hexString: hexString)!.isEqual(to: UIColor.red.withAlphaComponent(0.3)))
        hexString = "80FF0000"
        XCTAssertTrue(UIColor(hexString: hexString)!.isEqual(to: UIColor.red.withAlphaComponent(0.5)))
        hexString = "B3FF0000"
        XCTAssertTrue(UIColor(hexString: hexString)!.isEqual(to: UIColor.red.withAlphaComponent(0.7)))
        hexString = "E6FF0000"
        XCTAssertTrue(UIColor(hexString: hexString)!.isEqual(to: UIColor.red.withAlphaComponent(0.9)))

        hexString = "@FF0000"
        XCTAssertNil(UIColor(hexString: hexString))
        hexString = "FF000"
        XCTAssertNil(UIColor(hexString: hexString))
        hexString = "GG0000"
        XCTAssertNil(UIColor(hexString: hexString))
    }

    func testToRGBHex() {
        let trials: [(color: UIColor, baseHex: String, alphaHex: String)] = [
            (UIColor.red, "FF0000", "FF"),
            (UIColor.red.withAlphaComponent(0.1), "FF0000", "1A"),
            (UIColor.green, "00FF00", "FF"),
            (UIColor.green.withAlphaComponent(0.3), "00FF00", "4D"),
            (UIColor.blue, "0000FF", "FF"),
            (UIColor.blue.withAlphaComponent(0.5), "0000FF", "80"),
            (UIColor.white, "FFFFFF", "FF"),
            (UIColor.white.withAlphaComponent(0.7), "FFFFFF", "B3"),
            (UIColor.black, "000000", "FF"),
            (UIColor.black.withAlphaComponent(0.9), "000000", "E6"),
        ]

        for trial in trials {
            XCTAssertEqual(trial.color.toRGBHexString(includeAlpha: true, includePrefix: true), "#" + trial.alphaHex + trial.baseHex)
            XCTAssertEqual(trial.color.toRGBHexString(includeAlpha: true, includePrefix: false), trial.alphaHex + trial.baseHex)
            XCTAssertEqual(trial.color.toRGBHexString(includeAlpha: false, includePrefix: true), "#" + trial.baseHex)
            XCTAssertEqual(trial.color.toRGBHexString(includeAlpha: false, includePrefix: false), trial.baseHex)
        }
    }
}

private extension UIColorExtensionTests {
    typealias RGBA = (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat)
}

// A tolerant comparison rather than UIColor's exact Equatable implementation
// A UIColor instance's alpha component may has some deviation if initialized from hexString with alpha
// e.g. 0x1A is not exactly 0.1
extension UIColor {
    func isEqual(to other: UIColor) -> Bool {
        rgba == other.rgba
    }
}
