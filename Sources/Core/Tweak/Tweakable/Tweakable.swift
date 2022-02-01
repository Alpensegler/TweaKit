//
//  Tweakable.swift
//  TweaKit
//
//  Created by cokile
//

import UIKit

/// A type whose value can be tweaked.
public protocol Tweakable: Storable {
    /// The reuse id of the primary view.
    ///
    /// This is like the reuseIdentifier of `UITableViewCell`.
    ///
    /// Every `Tweakable` type must have a primary view.
    /// The primary view is used for tweaking the value.
    /// For example, `Bool` uses a switcher as its primary view.
    ///
    /// If this method is not implemented, then the return value is assumed to be the id of blank placeholder primary view.
    ///
    /// For more information about primary view please checkout ``TweakPrimaryView``.
    static var primaryViewReuseID: String { get }
    /// The primary view.
    ///
    /// Every `Tweakable` type must have a primary view.
    /// The primary view is used for tweaking the value.
    /// For example, `Bool` uses a switcher as its primary view.
    ///
    /// If this method is not implemented, then the return value is assumed to be a blank placeholder primary view.
    ///
    /// For more information about primary view please checkout ``TweakPrimaryView``.
    static var primaryView: TweakPrimaryView { get }
    /// A flag indicates whether the `Tweakable` type has a secondary view.
    ///
    /// A `Tweakable` type can opt-in a secondary view when its primary view has not enough room
    /// to display the UI for users to change the value.
    /// For example, `UIColor` uses a secondary view which uses some sliders for adjustment.
    ///
    /// If this method is not implemented, then the return value is assumed to be false.
    ///
    /// - Note: The value of `hasSecondaryView` should be the same as `secondaryView != nil`.
    ///         The reason why we use a separated property is to avoid unnecessary initialization of a secondary.
    ///         Sometimes we just need to know whether the type has a secondary view.
    ///
    /// For more information about secondary view please checkout ``TweakSecondaryView``.
    static var hasSecondaryView: Bool { get }
    /// The secondary view.
    ///
    /// A `Tweakable` type can opt-in a secondary view when its primary view has not enough room
    /// to display the UI for users to change the value.
    /// For example, `UIColor` uses a secondary view which uses some sliders for adjustment.
    ///
    /// If this method is not implemented, then the return value is assumed to be nil.
    ///
    /// For more information about secondary view please checkout ``TweakSecondaryView``.
    static var secondaryView: TweakSecondaryView? { get }
    
    /// Validates the receiver can be the default value of the tweak.
    ///
    /// Not every value is a valid default value for a tweak. For example, It's meaningless to tweak a empty array.
    ///
    /// If this method is not implemented, then the return value is assumed to be true.
    ///
    /// - Returns: True if the receiver can be the default value of the tweak; otherwise, false.
    func validateAsDefaultValue() -> Bool
}

public extension Tweakable {
    static var primaryViewReuseID: String {
        TweakPrimaryViewPlaceholder.reuseID
    }
    static var primaryView: TweakPrimaryView {
        TweakPrimaryViewPlaceholder()
    }
    static var hasSecondaryView: Bool {
        false
    }
    static var secondaryView: TweakSecondaryView? {
        nil
    }
    
    func validateAsDefaultValue() -> Bool { true }
}

// MARK: - Conformance

extension Bool: Tweakable {
    public static var primaryViewReuseID: String {
        TweakPrimaryViewSwitcher.reuseID
    }
    public static var primaryView: TweakPrimaryView {
        TweakPrimaryViewSwitcher()
    }
}

extension String: Tweakable {
    public static var primaryViewReuseID: String {
        TweakPrimaryViewTextField.reuseID
    }
    public static var primaryView: TweakPrimaryView {
        TweakPrimaryViewTextField()
    }
}

extension UIColor: Tweakable {
    public static var primaryViewReuseID: String {
        TweakPrimaryViewColorPicker.reuseID
    }
    public static var primaryView: TweakPrimaryView {
        TweakPrimaryViewColorPicker()
    }
    public static var hasSecondaryView: Bool {
        true
    }
    public static var secondaryView: TweakSecondaryView? {
        TweakSecondaryViewColorPicker()
    }
}

extension Array: Tweakable where Element: TweakSecondaryViewItemConvertible {
    public static var primaryViewReuseID: String {
        TweakPrimaryViewDisclosurer.reuseID
    }
    public static var primaryView: TweakPrimaryView {
        TweakPrimaryViewDisclosurer()
    }
    public static var hasSecondaryView: Bool {
        true
    }
    public static var secondaryView: TweakSecondaryView? {
        TweakSecondaryViewReorderer<Element>()
    }
    
    public func validateAsDefaultValue() -> Bool {
        !isEmpty
    }
}
