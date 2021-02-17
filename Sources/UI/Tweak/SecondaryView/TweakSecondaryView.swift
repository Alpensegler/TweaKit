//
//  TweakSecondaryView.swift
//  TweaKit
//
//  Created by cokile
//

import UIKit

public protocol TweakSecondaryView: UIViewController, TweakView {
    var estimatedHeight: CGFloat { get }
    
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
