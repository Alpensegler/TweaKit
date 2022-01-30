//
//  NumericTweak.swift
//  TweaKit
//
//  Created by cokile
//

import Foundation
import CoreGraphics

/// A type with values that support addition and subtraction.
///
/// Use Numbered as the name to avoid name conflict with Swift.Numeric.
public typealias Numbered = TweakPrimaryViewStrideable

public extension TweakType where Base == Tweak<Value>, Value: Numbered {
    /// Creates and initializes a tweak for ``Numbered`` type.
    ///
    /// - Parameters:
    ///   - name: The name of the tweak.
    ///   - defaultValue: The default value of the tweak.
    ///   - from: The maximum value of the tweaks.
    ///           This value must be greater than the minimum value.
    ///   - to: The minimum value of the tweak.
    ///         This value must be less than the maximum value.
    ///   - stride: The stride when changing value of the tweak.
    init(name: String, defaultValue: Value, from: Value, to: Value, stride: Value) {
        let base = NumberedTweak(name: name, defaultValue: defaultValue, from: from, to: to, stride: stride)
        self.init(base: base)
    }
}

final class NumberedTweak<Value: Numbered>: Tweak<Value> {
    let from: Value
    let to: Value
    let stride: Value
    
    override var primaryViewReuseID: String {
        TweakPrimaryViewStrider<Value>.reuseID
    }
    override var primaryView: TweakPrimaryView {
        TweakPrimaryViewStrider<Value>()
    }
    override var hasSecondaryView: Bool {
        false
    }
    override var secondaryView: TweakSecondaryView? {
        nil
    }
    
    override var rawValue: Value {
        super.rawValue.clamped(from: from, to: to)
    }
    
    init(name: String, defaultValue: Value, from: Value, to: Value, stride: Value) {
        assert(from < to, "Stride from: \(from) to: \(to) is invalid")
        assert(stride > 0, "Stride must larger than 0, while current stride is \(stride)")
        
        self.from = from
        self.to = to
        self.stride = stride
        super.init(name: name, default: defaultValue)
    }
    
    override func validate(unmarshaled: Value) -> Bool where Value: TradedTweakable {
        from <= unmarshaled && unmarshaled <= to
    }
}

// MARK: - Conformance of Numbered

public extension Numbered where Self: SignedInteger {
    var needDecimalPoint: Bool {
        false
    }
    func needSign(between min: Self, and max: Self) -> Bool {
        min < 0
    }
    
    func substracting(by amount: Self) -> Self {
        self - amount
    }
    func adding(by amount: Self) -> Self {
        self + amount
    }
}
extension Int8: Numbered {
    public func toText() -> String? {
        Constants.integerFormatter.string(from: NSNumber(value: self))
    }
    public static func fromText(_ text: String) -> Int8? {
        Int8(text)
    }
}
extension Int16: Numbered {
    public func toText() -> String? {
        Constants.integerFormatter.string(from: NSNumber(value: self))
    }
    public static func fromText(_ text: String) -> Int16? {
        Int16(text)
    }
}
extension Int32: Numbered {
    public func toText() -> String? {
        Constants.integerFormatter.string(from: NSNumber(value: self))
    }
    public static func fromText(_ text: String) -> Int32? {
        Int32(text)
    }
}
extension Int64: Numbered {
    public func toText() -> String? {
        Constants.integerFormatter.string(from: NSNumber(value: self))
    }
    public static func fromText(_ text: String) -> Int64? {
        Int64(text)
    }
}
extension Int: Numbered {
    public func toText() -> String? {
        Constants.integerFormatter.string(from: NSNumber(value: self))
    }
    public static func fromText(_ text: String) -> Int? {
        Int(text)
    }
}

public extension Numbered where Self: UnsignedInteger {
    var needDecimalPoint: Bool {
        false
    }
    func needSign(between min: Self, and max: Self) -> Bool {
        false
    }
    func substracting(by amount: Self) -> Self {
        self - amount
    }
    func adding(by amount: Self) -> Self {
        self + amount
    }
}
extension UInt8: Numbered {
    public func toText() -> String? {
        Constants.integerFormatter.string(from: NSNumber(value: self))
    }
    public static func fromText(_ text: String) -> UInt8? {
        UInt8(text)
    }
}
extension UInt16: Numbered {
    public func toText() -> String? {
        Constants.integerFormatter.string(from: NSNumber(value: self))
    }
    public static func fromText(_ text: String) -> UInt16? {
        UInt16(text)
    }
}
extension UInt32: Numbered {
    public func toText() -> String? {
        Constants.integerFormatter.string(from: NSNumber(value: self))
    }
    public static func fromText(_ text: String) -> UInt32? {
        UInt32(text)
    }
}
extension UInt64: Numbered {
    public func toText() -> String? {
        Constants.integerFormatter.string(from: NSNumber(value: self))
    }
    public static func fromText(_ text: String) -> UInt64? {
        UInt64(text)
    }
}
extension UInt: Numbered {
    public func toText() -> String? {
        Constants.integerFormatter.string(from: NSNumber(value: self))
    }
    public static func fromText(_ text: String) -> UInt? {
        UInt(text)
    }
}

public extension Numbered where Self: BinaryFloatingPoint {
    var needDecimalPoint: Bool {
        true
    }
    func needSign(between min: Self, and max: Self) -> Bool {
        min < 0
    }
}
extension Float: Numbered {
    public func toText() -> String? {
        let string = Constants.floatFormatter.string(from: NSNumber(value: self))
        return string == "-0" ? "0" : string
    }
    public static func fromText(_ text: String) -> Float? {
        Float(text)?.rounded(to: .thousandth)
    }
    public func substracting(by amount: Float) -> Float {
        (self - amount).rounded(to: .thousandth)
    }
    public func adding(by amount: Float) -> Float {
        (self + amount).rounded(to: .thousandth)
    }
}
extension Double: Numbered {
    public func toText() -> String? {
        let string = Constants.floatFormatter.string(from: NSNumber(value: self))
        return string == "-0" ? "0" : string
    }
    public static func fromText(_ text: String) -> Double? {
        Double(text)?.rounded(to: .thousandth)
    }
    public func substracting(by amount: Double) -> Double {
        (self - amount).rounded(to: .thousandth)
    }
    public func adding(by amount: Double) -> Double {
        (self + amount).rounded(to: .thousandth)
    }
}
extension CGFloat: Numbered {
    public func toText() -> String? {
        let string = Constants.floatFormatter.string(from: NSNumber(value: Double(self)))
        return string == "-0" ? "0" : string
    }
    public static func fromText(_ text: String) -> CGFloat? {
        Double(text).map { CGFloat($0).rounded(to: .thousandth) }
    }
    public func substracting(by amount: CGFloat) -> CGFloat {
        (self - amount).rounded(to: .thousandth)
    }
    public func adding(by amount: CGFloat) -> CGFloat {
        (self + amount).rounded(to: .thousandth)
    }
}

private extension Constants {
    static let integerFormatter: NumberFormatter = {
        let ft = NumberFormatter()
        ft.locale = Locale(identifier: "en_US_POSIX")
        ft.numberStyle = .decimal
        ft.minimumIntegerDigits = 1
        ft.maximumFractionDigits = 0
        return ft
    }()
    
    static let floatFormatter: NumberFormatter = {
        let ft = NumberFormatter()
        ft.locale = Locale(identifier: "en_US_POSIX")
        ft.numberStyle = .decimal
        ft.minimumIntegerDigits = 1
        ft.minimumFractionDigits = 0
        ft.maximumFractionDigits = 3
        return ft
    }()
}
