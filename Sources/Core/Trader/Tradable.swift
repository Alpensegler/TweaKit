//
//  Tradable.swift
//  TweaKit
//
//  Created by cokile
//

import UIKit

/// A type with value that can be converted from/to ``TweakTradeValue`` value.
///
/// Trade is the combination of import and export.
public protocol Tradable {
    /// Converts trade value to the concrete type object.
    ///
    /// Implementers should try their best to achieve the conversion.
    ///
    /// - Parameters:
    ///   - value: The trade value that the conversion performs from.
    /// - Returns: The concrete type object.
    static func unmarshal(from value: TweakTradeValue) -> Self?
    /// Converts the receiver to ``TweakTradeValue`` object.
    ///
    /// - Returns: The `TweakTradeValue` object that the receiver converts to.
    func marshalToValue() -> TweakTradeValue
}

// since the deployment target is iOS 13, all the supported devices use 64-bit CPU
// which means (U)Int has same size with (U)Int64

extension Tradable where Self: SignedInteger & FixedWidthInteger {
    public static func unmarshal(from value: TweakTradeValue) -> Self? {
        switch value {
        case .int(let v):
            if v.clamped(from: Int(min), to: Int(max)) == v {
                return Self(v)
            } else {
                return nil
            }
        case .uInt(let v):
            if v.clamped(from: 0, to: UInt(max)) == v {
                return Self(v)
            } else {
                return nil
            }
        case .string(let v):
            return Self(v)
        default:
            return nil
        }
    }

    public func marshalToValue() -> TweakTradeValue {
        .int(Int(self))
    }
}
extension Int8: Tradable { }
extension Int16: Tradable { }
extension Int32: Tradable { }
extension Int64: Tradable { }
extension Int: Tradable { }

extension Tradable where Self: UnsignedInteger & FixedWidthInteger {
    public static func unmarshal(from value: TweakTradeValue) -> Self? {
        switch value {
        case .int(let v):
            if v >= 0, UInt(v) <= UInt(max) {
                return Self(v)
            } else {
                return nil
            }
        case .uInt(let v):
            if v.clamped(from: 0, to: UInt(max)) == v {
                return Self(v)
            } else {
                return nil
            }
        case .string(let v):
            return Self(v)
        default:
            return nil
        }
    }

    public func marshalToValue() -> TweakTradeValue {
        .uInt(UInt(self))
    }
}
extension UInt8: Tradable { }
extension UInt16: Tradable { }
extension UInt32: Tradable { }
extension UInt64: Tradable { }
extension UInt: Tradable { }

extension Tradable where Self: BinaryFloatingPoint & LosslessStringConvertible {
    public static func unmarshal(from value: TweakTradeValue) -> Self? {
        switch value {
        case .int(let v):
            return Self(v)
        case .uInt(let v):
            return Self(v)
        case .double(let v):
            let ret = Self(v)
            if abs(ret).isEqual(to: .infinity) || ret.isEqual(to: .nan) || ret.isEqual(to: .signalingNaN) {
                return nil
            }
            return ret
        case .string(let v):
            return Self(v)
        default:
            return nil
        }
    }

    public func marshalToValue() -> TweakTradeValue {
        .double(Double(self))
    }
}
extension Float: Tradable { }
extension Double: Tradable { }

extension CGFloat: Tradable {
    public static func unmarshal(from value: TweakTradeValue) -> Self? {
        switch value {
        case .int(let v):
            return Self(v)
        case .uInt(let v):
            return Self(v)
        case .double(let v):
            return Self(v)
        case .string(let v):
            return Double(v).map { Self($0) }
        default:
            return nil
        }
    }

    public func marshalToValue() -> TweakTradeValue {
        .double(Double(self))
    }
}

extension Bool: Tradable {
    public static func unmarshal(from value: TweakTradeValue) -> Bool? {
        switch value {
        case .bool(let v):
            return v
        case .int(let v):
            return v == 1 ? true : (v == 0 ? false : nil)
        case .uInt(let v):
            return v == 1 ? true : (v == 0 ? false : nil)
        case .string(let v):
            switch v {
            case "1", "true": return true
            case "0", "false": return false
            default: return nil
            }
        default:
            return nil
        }
    }

    public func marshalToValue() -> TweakTradeValue {
        .bool(self)
    }
}

extension String: Tradable {
    public static func unmarshal(from value: TweakTradeValue) -> String? {
        guard case .string(let v) = value else { return nil }
        return v
    }

    public func marshalToValue() -> TweakTradeValue {
        .string(self)
    }
}

extension UIColor: Tradable {
    public static func unmarshal(from value: TweakTradeValue) -> Self? {
        String.unmarshal(from: value).flatMap { UIColor(hexString: $0) as? Self }
    }

    public func marshalToValue() -> TweakTradeValue {
        .string(toRGBHexString(includeAlpha: true, includePrefix: true))
    }
}

extension Array: Tradable where Element: Tradable & Equatable {
    public static func unmarshal(from value: TweakTradeValue) -> [Element]? {
        guard case .array(let v) = value else { return nil }
        let array = v.compactMap { Element.unmarshal(from: $0) }
        return array.count == v.count ? array : nil
    }

    public func marshalToValue() -> TweakTradeValue {
        .array(map { $0.marshalToValue() })
    }

    public func validate(with defaultValue: [Element]) -> Bool {
        guard !isEmpty, count == defaultValue.count else { return false }
        return allSatisfy(defaultValue.contains)
    }
}

public extension Tradable where Self: RawRepresentable, RawValue: Tradable {
    static func unmarshal(from value: TweakTradeValue) -> Self? {
        RawValue.unmarshal(from: value).flatMap { Self.init(rawValue: $0) }
    }
    func marshalToValue() -> TweakTradeValue {
        rawValue.marshalToValue()
    }
}
