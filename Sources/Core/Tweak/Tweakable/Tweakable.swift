//
//  Tweakable.swift
//  TweaKit
//
//  Created by cokile
//

import UIKit

public protocol Tweakable: Storable {
    static var primaryViewReuseID: String { get }
    static var primaryView: TweakPrimaryView { get }
    static var hasSecondaryView: Bool { get }
    static var secondaryView: TweakSecondaryView? { get }

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
