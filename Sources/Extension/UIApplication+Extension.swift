//
//  UIApplication+Extension.swift
//  TweaKit
//
//  Created by cokile
//

import UIKit

extension UIApplication {
    static var tk_shared: UIApplication {
        UIApplication.perform(NSSelectorFromString("sharedApplication")).takeUnretainedValue() as! UIApplication
    }
}

extension UIApplication {
    var isLandscape: Bool {
        statusBarOrientation.isLandscape
    }
}
