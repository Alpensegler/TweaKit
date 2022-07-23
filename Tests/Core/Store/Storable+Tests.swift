//
//  Storable+Tests.swift
//  TweaKitTests
//
//  Created by cokile
//

@testable import TweaKit
import XCTest

class DataConvertibleTests: XCTestCase {
    func testSignedInteger() {
        XCTAssertEqual(_integer(value: 0, type: Int.self), 0)
        XCTAssertEqual(_integer(value: 10, type: Int.self), 10)
        XCTAssertEqual(_integer(value: -10, type: Int.self), -10)
        XCTAssertEqual(_integer(value: Int.max, type: Int.self), Int.max)
        XCTAssertEqual(_integer(value: Int.min, type: Int.self), Int.min)

        XCTAssertEqual(_integer(value: 0, type: Int8.self), 0)
        XCTAssertEqual(_integer(value: 10, type: Int8.self), 10)
        XCTAssertEqual(_integer(value: -10, type: Int8.self), -10)
        XCTAssertEqual(_integer(value: Int8.max, type: Int8.self), Int8.max)
        XCTAssertEqual(_integer(value: Int8.min, type: Int8.self), Int8.min)

        XCTAssertEqual(_integer(value: 0, type: Int16.self), 0)
        XCTAssertEqual(_integer(value: 10, type: Int16.self), 10)
        XCTAssertEqual(_integer(value: -10, type: Int16.self), -10)
        XCTAssertEqual(_integer(value: Int16.max, type: Int16.self), Int16.max)
        XCTAssertEqual(_integer(value: Int16.min, type: Int16.self), Int16.min)

        XCTAssertEqual(_integer(value: 0, type: Int32.self), 0)
        XCTAssertEqual(_integer(value: 10, type: Int32.self), 10)
        XCTAssertEqual(_integer(value: -10, type: Int32.self), -10)
        XCTAssertEqual(_integer(value: Int32.max, type: Int32.self), Int32.max)
        XCTAssertEqual(_integer(value: Int32.min, type: Int32.self), Int32.min)

        XCTAssertEqual(_integer(value: 0, type: Int64.self), 0)
        XCTAssertEqual(_integer(value: 10, type: Int64.self), 10)
        XCTAssertEqual(_integer(value: -10, type: Int64.self), -10)
        XCTAssertEqual(_integer(value: Int64.max, type: Int64.self), Int64.max)
        XCTAssertEqual(_integer(value: Int64.min, type: Int64.self), Int64.min)
    }

    func testUnsignedInteger() {
        XCTAssertEqual(_integer(value: 10, type: UInt.self), 10)
        XCTAssertEqual(_integer(value: 0, type: UInt.self), 0)
        XCTAssertEqual(_integer(value: UInt.max, type: UInt.self), UInt.max)
        XCTAssertEqual(_integer(value: UInt.min, type: UInt.self), UInt.min)

        XCTAssertEqual(_integer(value: 10, type: UInt8.self), 10)
        XCTAssertEqual(_integer(value: 0, type: UInt8.self), 0)
        XCTAssertEqual(_integer(value: UInt8.max, type: UInt8.self), UInt8.max)
        XCTAssertEqual(_integer(value: UInt8.min, type: UInt8.self), UInt8.min)

        XCTAssertEqual(_integer(value: 10, type: Int16.self), 10)
        XCTAssertEqual(_integer(value: 0, type: UInt16.self), 0)
        XCTAssertEqual(_integer(value: UInt16.max, type: UInt16.self), UInt16.max)
        XCTAssertEqual(_integer(value: UInt16.min, type: UInt16.self), UInt16.min)

        XCTAssertEqual(_integer(value: 10, type: Int32.self), 10)
        XCTAssertEqual(_integer(value: 0, type: UInt32.self), 0)
        XCTAssertEqual(_integer(value: UInt32.max, type: UInt32.self), UInt32.max)
        XCTAssertEqual(_integer(value: UInt32.min, type: UInt32.self), UInt32.min)

        XCTAssertEqual(_integer(value: 10, type: Int64.self), 10)
        XCTAssertEqual(_integer(value: 0, type: UInt64.self), 0)
        XCTAssertEqual(_integer(value: UInt64.max, type: UInt64.self), UInt64.max)
        XCTAssertEqual(_integer(value: UInt64.min, type: UInt64.self), UInt64.min)
    }

    func testFloat() {
        XCTAssertEqual(_float(value: 0, type: Float.self), 0)
        XCTAssertEqual(_float(value: 0.005, type: Float.self), 0.005)
        XCTAssertEqual(_float(value: Float.pi, type: Float.self), Float.pi)
        XCTAssertEqual(_float(value: Float.greatestFiniteMagnitude, type: Float.self), .greatestFiniteMagnitude)
        XCTAssertEqual(_float(value: Float.leastNonzeroMagnitude, type: Float.self), .leastNonzeroMagnitude)
        XCTAssertTrue(_float(value: Float.nan, type: Float.self)?.isNaN == true)

        XCTAssertEqual(_float(value: 0, type: Double.self), 0)
        XCTAssertEqual(_float(value: 0.005, type: Double.self), 0.005)
        XCTAssertEqual(_float(value: Double.pi, type: Double.self), Double.pi)
        XCTAssertEqual(_float(value: Double.greatestFiniteMagnitude, type: Double.self), .greatestFiniteMagnitude)
        XCTAssertEqual(_float(value: Double.leastNonzeroMagnitude, type: Double.self), .leastNonzeroMagnitude)
        XCTAssertTrue(_float(value: Double.nan, type: Double.self)?.isNaN == true)

        XCTAssertEqual(_float(value: 0, type: CGFloat.self), 0)
        XCTAssertEqual(_float(value: 0.005, type: CGFloat.self), 0.005)
        XCTAssertEqual(_float(value: CGFloat.pi, type: CGFloat.self), CGFloat.pi)
        XCTAssertEqual(_float(value: CGFloat.greatestFiniteMagnitude, type: CGFloat.self), .greatestFiniteMagnitude)
        XCTAssertEqual(_float(value: CGFloat.leastNonzeroMagnitude, type: CGFloat.self), .leastNonzeroMagnitude)
        XCTAssertTrue(_float(value: CGFloat.nan, type: CGFloat.self)?.isNaN == true)
    }

    func testBool() {
        XCTAssertEqual(Bool.convert(from: true.convertToData()), true)
        XCTAssertEqual(Bool.convert(from: false.convertToData()), false)
    }

    func testString() {
        var string = "TweaKit"
        XCTAssertEqual(String.convert(from: string.convertToData()), string)
        string = "String"
        XCTAssertEqual(String.convert(from: string.convertToData()), string)
        string = "Test"
        XCTAssertEqual(String.convert(from: string.convertToData()), string)
    }

    func testUIColor() {
        var color = UIColor.red
        XCTAssertTrue(UIColor.convert(from: color.convertToData())!.isEqual(to: color))
        color = UIColor.red.withAlphaComponent(0.3)
        XCTAssertTrue(UIColor.convert(from: color.convertToData())!.isEqual(to: color))
    }

    func testArray() {
        XCTAssertEqual(_array(value: 1, count: 10, type: [Int].self), Array(repeating: 1 as Int, count: 10))
        XCTAssertEqual(_array(value: 1, count: 10, type: [Float].self), Array(repeating: 1 as Float, count: 10))
        XCTAssertEqual(_array(value: "1", count: 10, type: [String].self), Array(repeating: "1", count: 10))
        XCTAssertEqual([Position].self.convert(from: Position.allCases.convertToData()), Position.allCases)
    }

    func testEnum() {
        for pos in Position.allCases {
            XCTAssertEqual(Position.convert(from: pos.convertToData()), pos)
        }
    }
}

private extension DataConvertibleTests {
    func _integer<I: Storable & FixedWidthInteger>(value: I, type: I.Type) -> I? {
        type.convert(from: value.convertToData())
    }

    func _float<F: Storable & BinaryFloatingPoint>(value: F, type: F.Type) -> F? {
        type.convert(from: value.convertToData())
    }

    func _array<E: Storable & Equatable>(value: E, count: Int, type: [E].Type) -> [E]? {
        let array = Array(repeating: value, count: count)
        return type.convert(from: array.convertToData())
    }

    enum Position: Int, CaseIterable, Storable {
        case top, down, left, right
    }
}
