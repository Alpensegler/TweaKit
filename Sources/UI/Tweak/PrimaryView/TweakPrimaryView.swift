//
//  TweakPrimaryView.swift
//  TweaKit
//
//  Created by cokile
//

import UIKit

/// A view to show/change the value of a tweak.
///
/// Primary means it is displayed alongside with the tweak name in the list UI.
///
/// Each tweak list will maintain a reuse poll of primary view,
/// so a list with hundreds of tweaks will not initialize undreds of primary views.
///
/// Every tweak must have a primary view.
/// The primary view is used for tweaking the value.
/// For example, `Bool` uses a switcher as its primary view.
public protocol TweakPrimaryView: UIView, TweakView {
    /// The reuse id of the view.
    var reuseID: String { get }
    /// The natural size for the receiving view, considering only properties of the view itself.
    ///
    /// Custom views may have content that they display of which the layout system is unaware.
    /// Setting this property allows a custom view to communicate to the layout system what size it would like to be based on its content.
    var intrinsicContentSize: CGSize { get }
    /// The extend inset for hit-testing.
    ///
    /// Custom views may want some extra area outside of their frame to be interactable.
    ///
    /// If this method is not implemented, then the return value is assumed to be `zero`.
    var extendInset: UIEdgeInsets { get }
    /// Reload the view with a tweak.
    ///
    /// - Parameters:
    ///   - tweak: the tweak to reload with.
    ///   - manually: A flag indicates whether the update operation is triggered manually by users.
    /// - Returns: Whether needs to relayout after reloading the view.
    func reload(withTweak tweak: AnyTweak, manually: Bool) -> Bool
    /// Resets the states of the view.
    ///
    /// This is a optional method.
    func reset()
}

public extension TweakPrimaryView {
    var extendInset: UIEdgeInsets { .zero }
    
    func reset() { }
}

extension TweakPrimaryView {
    func prepareForReuse() {
        reset()
        if superview != nil {
            removeFromSuperview()
        }
    }
}

extension Constants.UI {
    enum PrimaryView {
        static let disableAlpha: CGFloat = 0.3
        static let textFont = UIFont.systemFont(ofSize: 16)
    }
}
