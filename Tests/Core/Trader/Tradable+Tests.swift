//
//  Tradable+Tests.swift
//  TweaKitTests
//
//  Created by cokile
//

@testable import TweaKit
import XCTest

class TradableTests: XCTestCase {
    func testInt8() {
        XCTAssertEqual(Int8.unmarshal(from: .int(1)), 1)
        XCTAssertEqual(Int8.unmarshal(from: .int(-1)), -1)
        XCTAssertEqual(Int8.unmarshal(from: .int(Int(Int8.min))), Int8.min)
        XCTAssertEqual(Int8.unmarshal(from: .int(Int(Int8.max))), Int8.max)
        XCTAssertNil(Int8.unmarshal(from: .int(Int(Int8.min) - 1)))
        XCTAssertNil(Int8.unmarshal(from: .int(Int(Int8.max) + 1)))

        XCTAssertEqual(Int8.unmarshal(from: .uInt(1)), 1)
        XCTAssertEqual(Int8.unmarshal(from: .uInt(10)), 10)
        XCTAssertEqual(Int8.unmarshal(from: .uInt(UInt(Int8.max))), Int8.max)
        XCTAssertNil(Int8.unmarshal(from: .uInt(UInt(Int8.max) + 1)))

        XCTAssertNil(Int8.unmarshal(from: .double(0)))
        XCTAssertNil(Int8.unmarshal(from: .double(1)))
        XCTAssertNil(Int8.unmarshal(from: .double(-1)))

        XCTAssertEqual(Int8.unmarshal(from: .string("1")), 1)
        XCTAssertEqual(Int8.unmarshal(from: .string("-1")), -1)
        XCTAssertNil(Int8.unmarshal(from: .string("TweaKit")))

        XCTAssertNil(Int8.unmarshal(from: .bool(true)))
        XCTAssertNil(Int8.unmarshal(from: .bool(false)))

        XCTAssertNil(Int8.unmarshal(from: .array([.int(1), .int(2), .int(3)])))
    }

    func testInt16() {
        XCTAssertEqual(Int16.unmarshal(from: .int(1)), 1)
        XCTAssertEqual(Int16.unmarshal(from: .int(-1)), -1)
        XCTAssertEqual(Int16.unmarshal(from: .int(Int(Int16.min))), Int16.min)
        XCTAssertEqual(Int16.unmarshal(from: .int(Int(Int16.max))), Int16.max)
        XCTAssertNil(Int16.unmarshal(from: .int(Int(Int16.min) - 1)))
        XCTAssertNil(Int16.unmarshal(from: .int(Int(Int16.max) + 1)))

        XCTAssertEqual(Int16.unmarshal(from: .uInt(1)), 1)
        XCTAssertEqual(Int16.unmarshal(from: .uInt(10)), 10)
        XCTAssertEqual(Int16.unmarshal(from: .uInt(UInt(Int16.max))), Int16.max)
        XCTAssertNil(Int16.unmarshal(from: .uInt(UInt(Int16.max) + 1)))

        XCTAssertNil(Int16.unmarshal(from: .double(0)))
        XCTAssertNil(Int16.unmarshal(from: .double(1)))
        XCTAssertNil(Int16.unmarshal(from: .double(-1)))

        XCTAssertEqual(Int16.unmarshal(from: .string("1")), 1)
        XCTAssertEqual(Int16.unmarshal(from: .string("-1")), -1)
        XCTAssertNil(Int16.unmarshal(from: .string("TweaKit")))

        XCTAssertNil(Int16.unmarshal(from: .bool(true)))
        XCTAssertNil(Int16.unmarshal(from: .bool(false)))

        XCTAssertNil(Int16.unmarshal(from: .array([.int(1), .int(2), .int(3)])))
    }

    func testInt32() {
        XCTAssertEqual(Int32.unmarshal(from: .int(1)), 1)
        XCTAssertEqual(Int32.unmarshal(from: .int(-1)), -1)
        XCTAssertEqual(Int32.unmarshal(from: .int(Int(Int32.min))), Int32.min)
        XCTAssertEqual(Int32.unmarshal(from: .int(Int(Int32.max))), Int32.max)
        XCTAssertNil(Int32.unmarshal(from: .int(Int(Int32.min) - 1)))
        XCTAssertNil(Int32.unmarshal(from: .int(Int(Int32.max) + 1)))

        XCTAssertEqual(Int32.unmarshal(from: .uInt(1)), 1)
        XCTAssertEqual(Int32.unmarshal(from: .uInt(10)), 10)
        XCTAssertEqual(Int32.unmarshal(from: .uInt(UInt(Int32.max))), Int32.max)
        XCTAssertNil(Int32.unmarshal(from: .uInt(UInt(Int32.max) + 1)))

        XCTAssertNil(Int32.unmarshal(from: .double(0)))
        XCTAssertNil(Int32.unmarshal(from: .double(1)))
        XCTAssertNil(Int32.unmarshal(from: .double(-1)))

        XCTAssertEqual(Int32.unmarshal(from: .string("1")), 1)
        XCTAssertEqual(Int32.unmarshal(from: .string("-1")), -1)
        XCTAssertNil(Int32.unmarshal(from: .string("TweaKit")))

        XCTAssertNil(Int32.unmarshal(from: .bool(true)))
        XCTAssertNil(Int32.unmarshal(from: .bool(false)))

        XCTAssertNil(Int32.unmarshal(from: .array([.int(1), .int(2), .int(3)])))
    }

    func testInt() {
        XCTAssertEqual(Int.unmarshal(from: .int(1)), 1)
        XCTAssertEqual(Int.unmarshal(from: .int(-1)), -1)
        XCTAssertEqual(Int.unmarshal(from: .int(.min)), Int.min)
        XCTAssertEqual(Int.unmarshal(from: .int(.max)), Int.max)

        XCTAssertEqual(Int.unmarshal(from: .uInt(1)), 1)
        XCTAssertEqual(Int.unmarshal(from: .uInt(10)), 10)
        XCTAssertEqual(Int.unmarshal(from: .uInt(UInt(Int.max))), Int.max)
        XCTAssertNil(Int.unmarshal(from: .uInt(UInt(Int.max) + 1)))

        XCTAssertNil(Int.unmarshal(from: .double(0)))
        XCTAssertNil(Int.unmarshal(from: .double(1)))
        XCTAssertNil(Int.unmarshal(from: .double(-1)))

        XCTAssertEqual(Int.unmarshal(from: .string("1")), 1)
        XCTAssertEqual(Int.unmarshal(from: .string("-1")), -1)
        XCTAssertNil(Int.unmarshal(from: .string("TweaKit")))

        XCTAssertNil(Int.unmarshal(from: .bool(true)))
        XCTAssertNil(Int.unmarshal(from: .bool(false)))

        XCTAssertNil(Int.unmarshal(from: .array([.int(1), .int(2), .int(3)])))
    }

    func testUInt8() {
        XCTAssertEqual(UInt8.unmarshal(from: .int(1)), 1)
        XCTAssertNil(UInt8.unmarshal(from: .int(-1)))
        XCTAssertEqual(UInt8.unmarshal(from: .int(Int(UInt8.min))), UInt8.min)
        XCTAssertNil(UInt8.unmarshal(from: .int(Int(UInt8.min) - 1)))
        XCTAssertEqual(UInt8.unmarshal(from: .int(Int(UInt8.max))), UInt8.max)
        XCTAssertNil(UInt8.unmarshal(from: .int(Int(UInt8.max) + 1)))

        XCTAssertEqual(UInt8.unmarshal(from: .uInt(1)), 1)
        XCTAssertEqual(UInt8.unmarshal(from: .uInt(10)), 10)
        XCTAssertEqual(UInt8.unmarshal(from: .uInt(UInt(UInt8.max))), UInt8.max)
        XCTAssertNil(UInt8.unmarshal(from: .uInt(UInt(UInt8.max) + 1)))

        XCTAssertNil(UInt8.unmarshal(from: .double(0)))
        XCTAssertNil(UInt8.unmarshal(from: .double(1)))
        XCTAssertNil(UInt8.unmarshal(from: .double(-1)))

        XCTAssertEqual(UInt8.unmarshal(from: .string("1")), 1)
        XCTAssertNil(UInt8.unmarshal(from: .string("TweaKit")))

        XCTAssertNil(UInt8.unmarshal(from: .bool(true)))
        XCTAssertNil(UInt8.unmarshal(from: .bool(false)))

        XCTAssertNil(UInt8.unmarshal(from: .array([.int(1), .int(2), .int(3)])))
    }

    func testUInt16() {
        XCTAssertEqual(UInt16.unmarshal(from: .int(1)), 1)
        XCTAssertNil(UInt16.unmarshal(from: .int(-1)))
        XCTAssertEqual(UInt16.unmarshal(from: .int(Int(UInt16.min))), UInt16.min)
        XCTAssertNil(UInt16.unmarshal(from: .int(Int(UInt16.min) - 1)))
        XCTAssertEqual(UInt16.unmarshal(from: .int(Int(UInt16.max))), UInt16.max)
        XCTAssertNil(UInt16.unmarshal(from: .int(Int(UInt16.max) + 1)))

        XCTAssertEqual(UInt16.unmarshal(from: .uInt(1)), 1)
        XCTAssertEqual(UInt16.unmarshal(from: .uInt(10)), 10)
        XCTAssertEqual(UInt16.unmarshal(from: .uInt(UInt(UInt16.max))), UInt16.max)
        XCTAssertNil(UInt16.unmarshal(from: .uInt(UInt(UInt16.max) + 1)))

        XCTAssertNil(UInt16.unmarshal(from: .double(0)))
        XCTAssertNil(UInt16.unmarshal(from: .double(1)))
        XCTAssertNil(UInt16.unmarshal(from: .double(-1)))

        XCTAssertEqual(UInt16.unmarshal(from: .string("1")), 1)
        XCTAssertNil(UInt16.unmarshal(from: .string("TweaKit")))

        XCTAssertNil(UInt16.unmarshal(from: .bool(true)))
        XCTAssertNil(UInt16.unmarshal(from: .bool(false)))

        XCTAssertNil(UInt16.unmarshal(from: .array([.int(1), .int(2), .int(3)])))
    }

    func testUInt32() {
        XCTAssertEqual(UInt32.unmarshal(from: .int(1)), 1)
        XCTAssertNil(UInt32.unmarshal(from: .int(-1)))
        XCTAssertEqual(UInt32.unmarshal(from: .int(Int(UInt32.min))), UInt32.min)
        XCTAssertNil(UInt32.unmarshal(from: .int(Int(UInt32.min) - 1)))
        XCTAssertEqual(UInt32.unmarshal(from: .int(Int(UInt32.max))), UInt32.max)
        XCTAssertNil(UInt32.unmarshal(from: .int(Int(UInt32.max) + 1)))

        XCTAssertEqual(UInt32.unmarshal(from: .uInt(1)), 1)
        XCTAssertEqual(UInt32.unmarshal(from: .uInt(10)), 10)
        XCTAssertEqual(UInt32.unmarshal(from: .uInt(UInt(UInt32.max))), UInt32.max)
        XCTAssertNil(UInt32.unmarshal(from: .uInt(UInt(UInt32.max) + 1)))

        XCTAssertNil(UInt32.unmarshal(from: .double(0)))
        XCTAssertNil(UInt32.unmarshal(from: .double(1)))
        XCTAssertNil(UInt32.unmarshal(from: .double(-1)))

        XCTAssertEqual(UInt32.unmarshal(from: .string("1")), 1)
        XCTAssertNil(UInt32.unmarshal(from: .string("TweaKit")))

        XCTAssertNil(UInt32.unmarshal(from: .bool(true)))
        XCTAssertNil(UInt32.unmarshal(from: .bool(false)))

        XCTAssertNil(UInt32.unmarshal(from: .array([.int(1), .int(2), .int(3)])))
    }

    func testUInt() {
        XCTAssertEqual(UInt.unmarshal(from: .int(1)), 1)
        XCTAssertNil(UInt.unmarshal(from: .int(-1)))

        XCTAssertEqual(UInt.unmarshal(from: .uInt(1)), 1)
        XCTAssertEqual(UInt.unmarshal(from: .uInt(10)), 10)
        XCTAssertEqual(UInt.unmarshal(from: .uInt(.max)), UInt.max)
        XCTAssertEqual(UInt.unmarshal(from: .uInt(.min)), UInt.min)

        XCTAssertNil(UInt.unmarshal(from: .double(0)))
        XCTAssertNil(UInt.unmarshal(from: .double(1)))
        XCTAssertNil(UInt.unmarshal(from: .double(-1)))

        XCTAssertEqual(UInt.unmarshal(from: .string("1")), 1)
        XCTAssertNil(UInt.unmarshal(from: .string("TweaKit")))

        XCTAssertNil(UInt.unmarshal(from: .bool(true)))
        XCTAssertNil(UInt.unmarshal(from: .bool(false)))

        XCTAssertNil(UInt.unmarshal(from: .array([.int(1), .int(2), .int(3)])))
    }

    func testFloat() {
        XCTAssertEqual(Float.unmarshal(from: .int(1)), 1)
        XCTAssertEqual(Float.unmarshal(from: .int(-1)), -1)
        XCTAssertEqual(Float.unmarshal(from: .int(.max)), Float(Int.max))
        XCTAssertEqual(Float.unmarshal(from: .int(.min)), Float(Int.min))

        XCTAssertEqual(Float.unmarshal(from: .uInt(1)), 1)
        XCTAssertEqual(Float.unmarshal(from: .uInt(10)), 10)
        XCTAssertEqual(Float.unmarshal(from: .uInt(.max)), Float(UInt.max))
        XCTAssertEqual(Float.unmarshal(from: .uInt(.min)), Float(UInt.min))

        XCTAssertEqual(Float.unmarshal(from: .double(0)), 0)
        XCTAssertEqual(Float.unmarshal(from: .double(1)), 1)
        XCTAssertEqual(Float.unmarshal(from: .double(-1)), -1)
        XCTAssertEqual(Float.unmarshal(from: .double(Double(Float.greatestFiniteMagnitude))), .greatestFiniteMagnitude)
        XCTAssertEqual(Float.unmarshal(from: .double(-Double(Float.greatestFiniteMagnitude))), -.greatestFiniteMagnitude)
        XCTAssertNil(Float.unmarshal(from: .double(.greatestFiniteMagnitude)))
        XCTAssertNil(Float.unmarshal(from: .double(-.greatestFiniteMagnitude)))

        XCTAssertEqual(Float.unmarshal(from: .string("1")), 1)
        XCTAssertNil(Float.unmarshal(from: .string("TweaKit")))

        XCTAssertNil(Float.unmarshal(from: .bool(true)))
        XCTAssertNil(Float.unmarshal(from: .bool(false)))

        XCTAssertNil(Float.unmarshal(from: .array([.int(1), .int(2), .int(3)])))
    }

    func testDouble() {
        XCTAssertEqual(Double.unmarshal(from: .int(1)), 1)
        XCTAssertEqual(Double.unmarshal(from: .int(-1)), -1)
        XCTAssertEqual(Double.unmarshal(from: .int(.max)), Double(Int.max))
        XCTAssertEqual(Double.unmarshal(from: .int(.min)), Double(Int.min))

        XCTAssertEqual(Double.unmarshal(from: .uInt(1)), 1)
        XCTAssertEqual(Double.unmarshal(from: .uInt(10)), 10)
        XCTAssertEqual(Double.unmarshal(from: .uInt(.max)), Double(UInt.max))
        XCTAssertEqual(Double.unmarshal(from: .uInt(.min)), Double(UInt.min))

        XCTAssertEqual(Double.unmarshal(from: .double(0)), 0)
        XCTAssertEqual(Double.unmarshal(from: .double(1)), 1)
        XCTAssertEqual(Double.unmarshal(from: .double(-1)), -1)
        XCTAssertEqual(Double.unmarshal(from: .double(.greatestFiniteMagnitude)), .greatestFiniteMagnitude)
        XCTAssertEqual(Double.unmarshal(from: .double(-.greatestFiniteMagnitude)), -.greatestFiniteMagnitude)

        XCTAssertEqual(Double.unmarshal(from: .string("1")), 1)
        XCTAssertNil(Double.unmarshal(from: .string("TweaKit")))

        XCTAssertNil(Double.unmarshal(from: .bool(true)))
        XCTAssertNil(Double.unmarshal(from: .bool(false)))

        XCTAssertNil(Double.unmarshal(from: .array([.int(1), .int(2), .int(3)])))
    }

    func testCGFloat() {
        XCTAssertEqual(CGFloat.unmarshal(from: .int(1)), 1)
        XCTAssertEqual(CGFloat.unmarshal(from: .int(-1)), -1)
        XCTAssertEqual(CGFloat.unmarshal(from: .int(.max)), CGFloat(Int.max))
        XCTAssertEqual(CGFloat.unmarshal(from: .int(.min)), CGFloat(Int.min))

        XCTAssertEqual(CGFloat.unmarshal(from: .uInt(1)), 1)
        XCTAssertEqual(CGFloat.unmarshal(from: .uInt(10)), 10)
        XCTAssertEqual(CGFloat.unmarshal(from: .uInt(.max)), CGFloat(UInt.max))
        XCTAssertEqual(CGFloat.unmarshal(from: .uInt(.min)), CGFloat(UInt.min))

        XCTAssertEqual(CGFloat.unmarshal(from: .double(0)), 0)
        XCTAssertEqual(CGFloat.unmarshal(from: .double(1)), 1)
        XCTAssertEqual(CGFloat.unmarshal(from: .double(-1)), -1)
        XCTAssertEqual(CGFloat.unmarshal(from: .double(.greatestFiniteMagnitude)), .greatestFiniteMagnitude)
        XCTAssertEqual(CGFloat.unmarshal(from: .double(-.greatestFiniteMagnitude)), -.greatestFiniteMagnitude)

        XCTAssertEqual(CGFloat.unmarshal(from: .string("1")), 1)
        XCTAssertNil(CGFloat.unmarshal(from: .string("TweaKit")))

        XCTAssertNil(CGFloat.unmarshal(from: .bool(true)))
        XCTAssertNil(CGFloat.unmarshal(from: .bool(false)))

        XCTAssertNil(CGFloat.unmarshal(from: .array([.int(1), .int(2), .int(3)])))
    }

    func testBool() {
        XCTAssertEqual(Bool.unmarshal(from: .int(1)), true)
        XCTAssertEqual(Bool.unmarshal(from: .int(0)), false)
        XCTAssertNil(Bool.unmarshal(from: .int(-1)))
        XCTAssertNil(Bool.unmarshal(from: .int(2)))

        XCTAssertEqual(Bool.unmarshal(from: .uInt(1)), true)
        XCTAssertEqual(Bool.unmarshal(from: .uInt(0)), false)

        XCTAssertNil(Bool.unmarshal(from: .double(1)))
        XCTAssertNil(Bool.unmarshal(from: .double(0)))

        XCTAssertEqual(Bool.unmarshal(from: .bool(true)), true)
        XCTAssertEqual(Bool.unmarshal(from: .bool(false)), false)

        XCTAssertEqual(Bool.unmarshal(from: .string("1")), true)
        XCTAssertEqual(Bool.unmarshal(from: .string("0")), false)
        XCTAssertEqual(Bool.unmarshal(from: .string("true")), true)
        XCTAssertEqual(Bool.unmarshal(from: .string("false")), false)
        XCTAssertNil(Bool.unmarshal(from: .string("TweaKit")))

        XCTAssertNil(Bool.unmarshal(from: .array([.int(1), .int(2), .int(3)])))
    }

    func testString() {
        XCTAssertNil(String.unmarshal(from: .int(0)))
        XCTAssertNil(String.unmarshal(from: .int(1)))

        XCTAssertNil(String.unmarshal(from: .uInt(0)))
        XCTAssertNil(String.unmarshal(from: .uInt(1)))

        XCTAssertNil(String.unmarshal(from: .double(0)))
        XCTAssertNil(String.unmarshal(from: .double(1)))

        XCTAssertNil(String.unmarshal(from: .bool(true)))
        XCTAssertNil(String.unmarshal(from: .bool(false)))

        XCTAssertEqual(String.unmarshal(from: .string("TweaKit")), "TweaKit")
        XCTAssertEqual(String.unmarshal(from: .string("Test")), "Test")

        XCTAssertNil(String.unmarshal(from: .array([.int(1), .int(2), .int(3)])))
    }

    func testUIColor() {
        XCTAssertNil(UIColor.unmarshal(from: .int(0)))
        XCTAssertNil(UIColor.unmarshal(from: .int(1)))

        XCTAssertNil(UIColor.unmarshal(from: .uInt(0)))
        XCTAssertNil(UIColor.unmarshal(from: .uInt(1)))

        XCTAssertNil(UIColor.unmarshal(from: .double(0)))
        XCTAssertNil(UIColor.unmarshal(from: .double(1)))

        XCTAssertNil(UIColor.unmarshal(from: .bool(true)))
        XCTAssertNil(UIColor.unmarshal(from: .bool(false)))

        XCTAssertEqual(UIColor.unmarshal(from: .string("#FF0000")), UIColor.red)
        XCTAssertEqual(UIColor.unmarshal(from: .string("#00FF00")), UIColor.green)
        XCTAssertEqual(UIColor.unmarshal(from: .string("#0000FF")), UIColor.blue)
    }

    func testArray() {
        XCTAssertNil([Int].unmarshal(from: .int(0)))
        XCTAssertNil([Int].unmarshal(from: .int(1)))

        XCTAssertNil([Int].unmarshal(from: .uInt(0)))
        XCTAssertNil([Int].unmarshal(from: .uInt(1)))

        XCTAssertNil([Int].unmarshal(from: .double(0)))
        XCTAssertNil([Int].unmarshal(from: .double(1)))

        XCTAssertNil([Int].unmarshal(from: .bool(true)))
        XCTAssertNil([Int].unmarshal(from: .bool(false)))

        XCTAssertNil([Int].unmarshal(from: .string("TweaKit")))
        XCTAssertNil([Int].unmarshal(from: .string("Test")))

        XCTAssertEqual([Int].unmarshal(from: .array([.int(1), .int(2), .int(3)])), [1, 2, 3] as [Int])
        XCTAssertEqual([Int].unmarshal(from: .array([.uInt(1), .uInt(2), .uInt(3)])), [1, 2, 3] as [Int])
        XCTAssertEqual([Int].unmarshal(from: .array([.int(1), .uInt(2), .string("3")])), [1, 2, 3] as [Int])
        XCTAssertNil([Int].unmarshal(from: .array([.int(1), .uInt(2), .double(3)])))
    }

    func testEnum() {
        for (index, position) in Position.allCases.enumerated() {
            XCTAssertEqual(Position.unmarshal(from: .int(index)), position)
            XCTAssertNotEqual(Position.unmarshal(from: .int(index + 1)), position)

            XCTAssertEqual(Position.unmarshal(from: .uInt(UInt(index))), position)
            XCTAssertNotEqual(Position.unmarshal(from: .uInt(UInt(index) + 1)), position)

            XCTAssertNil(Position.unmarshal(from: .double(Double(index))))
            XCTAssertNil(Position.unmarshal(from: .double(Double(index + 1))))

            XCTAssertEqual(Position.unmarshal(from: .string(index.description)), position)
            XCTAssertNotEqual(Position.unmarshal(from: .string((index + 1).description)), position)

            XCTAssertNil(Position.unmarshal(from: .bool(true)))
            XCTAssertNil(Position.unmarshal(from: .bool(false)))

            XCTAssertNil(Position.unmarshal(from: .array([.int(index)])))
        }
    }
}

private extension TradableTests {
    enum Position: Int, CaseIterable, TradedTweakable {
        case top, down, left, right
    }
}
