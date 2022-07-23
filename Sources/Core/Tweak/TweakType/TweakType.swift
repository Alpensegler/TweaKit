//
//  TweakType.swift
//  TweaKit
//
//  Created by cokile
//

import Foundation

/// A abstract type that represents a tweak.

/// Every tweak type has its own unique logic. For example, numeric tweak need handle minimum/maximum value
/// but selection tweak need to handle the selection options.
///
/// `TweaKit` uses different types for each tweaks under the hood.
/// But we don't want to expose these types and to provide a unified API for users.
///
/// So instead of writing code like:
/// ```swift
/// NumericTweak("one tweak", defaultValue: 1, from: 1, to: 100, stride: 1)
/// SelectionTweak("another tweak" defaultValue: 1, options: [1, 2, 3])
/// ```
/// We can write code like:
/// ```swift
/// Tweak("one tweak", defaultValue: 1, from: 1, to: 100, stride: 1)
/// Tweak("another tweak" defaultValue: 1, options: [1, 2, 3])
/// ```
/// We use `TweakType` to implement a class cluster that groups a number of private,
/// concrete tweak subclasses under a public, abstract superclass ``Tweak``.
public protocol TweakType {
    /// The value type of the tweak.
    associatedtype Value
    /// the concrete tweak type.
    associatedtype Base = Self

    /// Creates and initializes a tweak with the given concrete type.
    ///
    /// - Parameters:
    ///   - base: The concrete tweak object.
    init(base: Base)
}

public extension TweakType where Base == Self {
    init(base: Base) { self = base }
}

/// A type-erased tweak.
///
/// There are some API that don't have to expose.
public protocol AnyTweak: AnyObject {
    /// The name of the tweak.
    var name: String { get }
    /// The section that the tweak belongs to.
    ///
    /// - Note: Don't set the section on your own. The setter is a ugly implementation for now.
    var section: TweakSection? { get set }
    /// The extra info of the tweak.
    ///
    /// Checkout the doc for ``TweakInfo`` for more information.
    var info: TweakInfo { get }
    /// The current value of the tweak.
    var currentValue: Storable { get }

    /// The primary view reuse id of the tweak.
    ///
    /// Every tweak must have a primary view.
    /// The primary view is used for tweaking the value.
    /// For example, tweak for `Bool` uses a switcher as its primary view.
    ///
    /// For more information about primary view please checkout ``TweakPrimaryView``.
    var primaryViewReuseID: String { get }
    /// The primary view that the tweak uses.
    ///
    /// Every tweak must have a primary view.
    /// The primary view is used for tweaking the value.
    /// For example, tweak for `Bool` uses a switcher as its primary view.
    ///
    /// For more information about primary view please checkout ``TweakPrimaryView``.
    var primaryView: TweakPrimaryView { get }
    /// A flag indicates whether the tweak has secondary view.
    ///
    /// A `Tweakable` type can opt-in a secondary view when its primary view has not enough room
    /// to display the UI for users to change the value.
    /// For example, `UIColor` uses a secondary view which uses some sliders for adjustment.
    ///
    /// For more information about secondary view please checkout ``TweakSecondaryView``.
    var hasSecondaryView: Bool { get }
    /// The secondary view that the tweak uses.
    ///
    /// A `Tweakable` type can opt-in a secondary view when its primary view has not enough room
    /// to display the UI for users to change the value.
    /// For example, `UIColor` uses a secondary view which uses some sliders for adjustment.
    ///
    /// For more information about secondary view please checkout ``TweakSecondaryView``.
    var secondaryView: TweakSecondaryView? { get }

    /// Registers the tweak in the context.
    /// - Parameters:
    ///   - context: The context in which the tweak is registered.
    func register(in context: TweakContext)
}

extension AnyTweak {
    /// The id of the tweak.
    public var id: String {
        let names: [String?] = [list?.name, section?.name, name]
        return names.compactMap { $0 }.joined(separator: Constants.idSeparator)
    }

    var list: TweakList? { section?.list }
    var context: TweakContext? { list?.context }
}

/// A type-erased tweak that can be traded.
public protocol AnyTradableTweak: AnyTweak {
    /// Converts the trade value to raw data.
    ///
    /// - Parameters:
    ///   - value: The trade value.
    /// - Returns: The conversion result. The `Success` type is `Data` and the `Failure` type is ``TweakError``.
    func rawData(from value: TweakTradeValue) -> Result<Data, TweakError>
    /// Converts current value of the tweak to trade value.
    ///
    /// - Returns: The trade value.
    func tradeValue() -> TweakTradeValue
}
