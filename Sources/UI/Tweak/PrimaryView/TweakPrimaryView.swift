//
//  TweakPrimaryView.swift
//  TweaKit
//
//  Created by cokile
//

import UIKit

public protocol TweakPrimaryView: UIView, TweakView {
    var reuseID: String { get }
    var intrinsicContentSize: CGSize { get }
    var extendInset: UIEdgeInsets { get }
    
    /// return: whether needs to relayout
    func reload(withTweak tweak: AnyTweak, manually: Bool) -> Bool
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
