//
//  TradeTweakable.swift
//  TweaKit
//
//  Created by cokile
//

import UIKit

/// A type whose value can be tweaked and traded.
///
/// It's a combination of ``Tweakable`` and ``Tradable``.
public protocol TradedTweakable: Tweakable, Tradable {
    /// Validates whether the value unmarshaled from ``TweakTradeValue`` is compatible with the tweak's default value.
    ///
    /// If this method is not implemented, then the return value is assumed to be true.
    ///
    /// - Parameters:
    ///   - defaultValue: The tweak's default value.
    /// - Returns: Ture if the value unmarshaled from ``TweakTradeValue`` is compatible with the tweak's default value;
    ///            otherwise, false.
    func validate(with defaultValue: Self) -> Bool
}

extension TradedTweakable {
    public func validate(with defaultValue: Self) -> Bool { true }
}

extension Int8: TradedTweakable { }
extension Int16: TradedTweakable { }
extension Int32: TradedTweakable { }
extension Int64: TradedTweakable { }
extension Int: TradedTweakable { }
extension UInt8: TradedTweakable { }
extension UInt16: TradedTweakable { }
extension UInt32: TradedTweakable { }
extension UInt64: TradedTweakable { }
extension UInt: TradedTweakable { }
extension Float: TradedTweakable { }
extension Double: TradedTweakable { }
extension CGFloat: TradedTweakable { }
extension Bool: TradedTweakable { }
extension String: TradedTweakable { }
extension UIColor: TradedTweakable { }

public extension TradedTweakable where Self: RawRepresentable, RawValue: TradedTweakable { }

extension Array: TradedTweakable where Element: Tradable & TweakSecondaryViewItemConvertible {
    public func validate(with defaultValue: Self) -> Bool {
        guard !isEmpty, count == defaultValue.count else { return false }
        return allSatisfy(defaultValue.contains)
    }
}
