//
//  TweakSecondaryView.swift
//  TweaKit
//
//  Created by cokile
//

import UIKit

/// A view to show/change the value of a tweak.
///
/// A tweak can opt-in a secondary view when its primary view has not enough room
/// to display the UI for users to change the value.
/// For example, `UIColor` uses a secondary view  which uses some sliders for adjustment.
///
/// `TweKit` shows a senondary view in a bottom panel sheet.
public protocol TweakSecondaryView: UIViewController, TweakView {
    /// The estimated height of the view.
    ///
    /// `TweaKit` uses this height to calculate the height of the bottom panel sheet for the view.
    ///
    /// If this method is not implemented, then the return value is assumed to be a default height.
    var estimatedHeight: CGFloat { get }
    
    /// Reload the view with a tweak.
    ///
    /// - Parameters:
    ///   - tweak: the tweak to reload with.
    ///   - manually: A flag indicates whether the update operation is triggered manually by users.
    func reload(withTweak tweak: AnyTweak, manually: Bool)
}

public extension TweakSecondaryView {
    var estimatedHeight: CGFloat {
        Constants.UI.SecondaryView.defaultEstimatedHeight
    }
}

public extension TweakSecondaryView {
    var horizontalPadding: CGFloat {
        Constants.UI.SecondaryView.horizontalPadding
    }
}
