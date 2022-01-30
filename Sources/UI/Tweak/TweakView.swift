//
//  TweakView.swift
//  TweaKit
//
//  Created by cokile
//

import Foundation

/// A view to show/change the value of a tweak.
public protocol TweakView {
}

public extension TweakView {
    /// Update value of the tweak.
    ///
    /// - Parameters:
    ///   - tweak: The tweak to update value.
    ///   - value: The new tweak value.
    ///   - manually: A flag indicates whether the update operation is triggered manually by users.
    func updateTweak(_ tweak: AnyTweak, withValue value: Storable, manually: Bool) {
        tweak.context?.store.setValue(value, forKey: tweak.id, manually: manually)
        if manually {
            tweak.didChangeManually = true
        }
    }
}
