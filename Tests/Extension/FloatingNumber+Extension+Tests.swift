//
//  FloatingNumber+Extension+Tests.swift
//  TweaKit
//
//  Created by cokile
//

import XCTest
@testable import TweaKit

class FloatingNumberExtensionTests: XCTestCase {
    func testFloatRound() {
        var number: Float = 0.1
        XCTAssertEqual(number.rounded(to: .integer), 0, accuracy: Float.ulpOfOne)
        number = 0.499
        XCTAssertEqual(number.rounded(to: .integer), 0, accuracy: Float.ulpOfOne)
        number = 0.5
        XCTAssertEqual(number.rounded(to: .integer), 1, accuracy: Float.ulpOfOne)
        number = 0.55
        XCTAssertEqual(number.rounded(to: .integer), 1, accuracy: Float.ulpOfOne)

        number = 0.01
        XCTAssertEqual(number.rounded(to: .tenth), 0, accuracy: Float.ulpOfOne)
        number = 0.499
        XCTAssertEqual(number.rounded(to: .tenth), 0.5, accuracy: Float.ulpOfOne)
        number = 0.55
        XCTAssertEqual(number.rounded(to: .tenth), 0.6, accuracy: Float.ulpOfOne)

        number = 0.0001
        XCTAssertEqual(number.rounded(to: .hundredth), 0, accuracy: Float.ulpOfOne)
        number = 0.499
        XCTAssertEqual(number.rounded(to: .hundredth), 0.5, accuracy: Float.ulpOfOne)
        number = 0.555
        XCTAssertEqual(number.rounded(to: .hundredth), 0.56, accuracy: Float.ulpOfOne)
        
        number = 0.00001
        XCTAssertEqual(number.rounded(to: .thousandth), 0, accuracy: Float.ulpOfOne)
        number = 0.0001
        XCTAssertEqual(number.rounded(to: .thousandth), 0, accuracy: Float.ulpOfOne)
        number = 0.001
        XCTAssertEqual(number.rounded(to: .thousandth), 0.001, accuracy: Float.ulpOfOne)
        number = 0.44451
        XCTAssertEqual(number.rounded(to: .thousandth), 0.445, accuracy: Float.ulpOfOne)
        number = 0.499
        XCTAssertEqual(number.rounded(to: .thousandth), 0.499, accuracy: Float.ulpOfOne)
        number = 0.4999
        XCTAssertEqual(number.rounded(to: .thousandth), 0.5, accuracy: Float.ulpOfOne)
        number = 0.49999999
        XCTAssertEqual(number.rounded(to: .thousandth), 0.5, accuracy: Float.ulpOfOne)
    }
    
    func testDoubleRound() {
        var number: Double = 0.1
        XCTAssertEqual(number.rounded(to: .integer), 0, accuracy: Double.ulpOfOne)
        number = 0.499
        XCTAssertEqual(number.rounded(to: .integer), 0, accuracy: Double.ulpOfOne)
        number = 0.5
        XCTAssertEqual(number.rounded(to: .integer), 1, accuracy: Double.ulpOfOne)
        number = 0.55
        XCTAssertEqual(number.rounded(to: .integer), 1, accuracy: Double.ulpOfOne)

        number = 0.01
        XCTAssertEqual(number.rounded(to: .tenth), 0, accuracy: Double.ulpOfOne)
        number = 0.499
        XCTAssertEqual(number.rounded(to: .tenth), 0.5, accuracy: Double.ulpOfOne)
        number = 0.55
        XCTAssertEqual(number.rounded(to: .tenth), 0.6, accuracy: Double.ulpOfOne)

        number = 0.0001
        XCTAssertEqual(number.rounded(to: .hundredth), 0, accuracy: Double.ulpOfOne)
        number = 0.499
        XCTAssertEqual(number.rounded(to: .hundredth), 0.5, accuracy: Double.ulpOfOne)
        number = 0.555
        XCTAssertEqual(number.rounded(to: .hundredth), 0.56, accuracy: Double.ulpOfOne)
        
        number = 0.00001
        XCTAssertEqual(number.rounded(to: .thousandth), 0, accuracy: Double.ulpOfOne)
        number = 0.0001
        XCTAssertEqual(number.rounded(to: .thousandth), 0, accuracy: Double.ulpOfOne)
        number = 0.001
        XCTAssertEqual(number.rounded(to: .thousandth), 0.001, accuracy: Double.ulpOfOne)
        number = 0.44451
        XCTAssertEqual(number.rounded(to: .thousandth), 0.445, accuracy: Double.ulpOfOne)
        number = 0.499
        XCTAssertEqual(number.rounded(to: .thousandth), 0.499, accuracy: Double.ulpOfOne)
        number = 0.4999
        XCTAssertEqual(number.rounded(to: .thousandth), 0.5, accuracy: Double.ulpOfOne)
        number = 0.49999999
        XCTAssertEqual(number.rounded(to: .thousandth), 0.5, accuracy: Double.ulpOfOne)
    }
    
    func testCGFloatRound() {
        var number: CGFloat = 0.1
        XCTAssertEqual(number.rounded(to: .integer), 0, accuracy: CGFloat.ulpOfOne)
        number = 0.499
        XCTAssertEqual(number.rounded(to: .integer), 0, accuracy: CGFloat.ulpOfOne)
        number = 0.5
        XCTAssertEqual(number.rounded(to: .integer), 1, accuracy: CGFloat.ulpOfOne)
        number = 0.55
        XCTAssertEqual(number.rounded(to: .integer), 1, accuracy: CGFloat.ulpOfOne)

        number = 0.01
        XCTAssertEqual(number.rounded(to: .tenth), 0, accuracy: CGFloat.ulpOfOne)
        number = 0.499
        XCTAssertEqual(number.rounded(to: .tenth), 0.5, accuracy: CGFloat.ulpOfOne)
        number = 0.55
        XCTAssertEqual(number.rounded(to: .tenth), 0.6, accuracy: CGFloat.ulpOfOne)

        number = 0.0001
        XCTAssertEqual(number.rounded(to: .hundredth), 0, accuracy: CGFloat.ulpOfOne)
        number = 0.499
        XCTAssertEqual(number.rounded(to: .hundredth), 0.5, accuracy: CGFloat.ulpOfOne)
        number = 0.555
        XCTAssertEqual(number.rounded(to: .hundredth), 0.56, accuracy: CGFloat.ulpOfOne)
        
        number = 0.00001
        XCTAssertEqual(number.rounded(to: .thousandth), 0, accuracy: CGFloat.ulpOfOne)
        number = 0.0001
        XCTAssertEqual(number.rounded(to: .thousandth), 0, accuracy: CGFloat.ulpOfOne)
        number = 0.001
        XCTAssertEqual(number.rounded(to: .thousandth), 0.001, accuracy: CGFloat.ulpOfOne)
        number = 0.44451
        XCTAssertEqual(number.rounded(to: .thousandth), 0.445, accuracy: CGFloat.ulpOfOne)
        number = 0.499
        XCTAssertEqual(number.rounded(to: .thousandth), 0.499, accuracy: CGFloat.ulpOfOne)
        number = 0.4999
        XCTAssertEqual(number.rounded(to: .thousandth), 0.5, accuracy: CGFloat.ulpOfOne)
        number = 0.49999999
        XCTAssertEqual(number.rounded(to: .thousandth), 0.5, accuracy: CGFloat.ulpOfOne)
    }
}
