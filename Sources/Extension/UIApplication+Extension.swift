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
        if let orientation = windows.first(where: \.isKeyWindow)?.windowScene?.interfaceOrientation {
            return orientation.isLandscape
        } else {
            return false
        }
    }
    
    var statusBarHeight: CGFloat {
        if let manager = windows.first(where: \.isKeyWindow)?.windowScene?.statusBarManager {
            return manager.statusBarFrame.height
        } else {
            return 0
        }
    }
}
