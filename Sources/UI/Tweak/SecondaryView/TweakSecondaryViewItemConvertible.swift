//
//  TweakSecondaryViewItemConvertible.swift
//  TweaKit
//
//  Created by cokile
//

import UIKit

/// A type with values that can be displayed in tweak secondary view.
public protocol TweakSecondaryViewItemConvertible: Storable, Equatable {
    /// The text to be displayed in tweak secondary view.
    var displayText: String { get }
}

extension Int: TweakSecondaryViewItemConvertible { }
extension Int8: TweakSecondaryViewItemConvertible { }
extension Int16: TweakSecondaryViewItemConvertible { }
extension Int32: TweakSecondaryViewItemConvertible { }
extension Int64: TweakSecondaryViewItemConvertible { }
extension UInt: TweakSecondaryViewItemConvertible { }
extension UInt8: TweakSecondaryViewItemConvertible { }
extension UInt16: TweakSecondaryViewItemConvertible { }
extension UInt32: TweakSecondaryViewItemConvertible { }
extension UInt64: TweakSecondaryViewItemConvertible { }
extension Float: TweakSecondaryViewItemConvertible { }
extension Double: TweakSecondaryViewItemConvertible { }
extension CGFloat: TweakSecondaryViewItemConvertible { }
extension String: TweakSecondaryViewItemConvertible { }
extension Bool: TweakSecondaryViewItemConvertible { }

extension UIColor: TweakSecondaryViewItemConvertible {
    public var displayText: String { toRGBHexString(includeAlpha: true, includePrefix: true) }
}

extension TweakSecondaryViewItemConvertible where Self: CustomStringConvertible {
    public var displayText: String { description }
}

extension TweakSecondaryViewItemConvertible where Self: RawRepresentable, RawValue: TweakSecondaryViewItemConvertible {
    public var displayText: String { rawValue.displayText }
}
