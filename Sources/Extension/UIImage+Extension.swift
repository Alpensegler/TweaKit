//
//  UIImage+Extension.swift
//  TweaKit
//
//  Created by cokile
//

import UIKit

private class Dummy { }

extension UIImage {
    convenience init?(asset: String) {
        self.init(named: asset, in: Constants.Assets.bundle, compatibleWith: nil)
    }
}

private extension Constants.Assets {
    static let bundle: Bundle = {
        #if SWIFT_PACKAGE
        return Bundle.module
        #elseif COCOAPODS
        let podSpecBundleKey = "Assets" // must be in sync with TweaKit.podspec
        return Bundle(path: Bundle(for: Dummy.self).resourcePath!.appending("/\(podSpecBundleKey).bundle"))!
        #else
        return Bundle(for: Dummy.self)
        #endif
    }()
}
