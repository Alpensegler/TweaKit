//
//  TweakView.swift
//  TweaKit
//
//  Created by cokile
//

import Foundation

public protocol TweakView {
}

public extension TweakView {
    func updateTweak(_ tweak: AnyTweak, withValue value: Storable, manually: Bool) {
        tweak.context?.store.setValue(value, forKey: tweak.id, manually: manually)
        if manually {
            tweak.didChangeManually = true
        }
    }
}
