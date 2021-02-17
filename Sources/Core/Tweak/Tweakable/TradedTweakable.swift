//
//  TradeTweakable.swift
//  TweaKit
//
//  Created by cokile
//

import UIKit

public protocol TradedTweakable: Tweakable, Tradable {
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
