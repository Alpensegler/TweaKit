//
//  TweakableTweak.swift
//  TweaKit
//
//  Created by cokile
//

import Foundation

public extension TweakType where Base == Tweak<Value>, Value: Tweakable {
    /// Creates and initializes a tweak with the given name and default value.
    ///
    /// - Parameters:
    ///   - name: The name of the tweak.
    ///   - defaultValue: The default value of the tweak.
    init(name: String, defaultValue: Value) {
        let base = TweakableTweak(name: name, default: defaultValue)
        self.init(base: base)
    }
}

class TweakableTweak<Value: Tweakable>: Tweak<Value> {
    override var primaryViewReuseID: String {
        Value.primaryViewReuseID
    }
    override var primaryView: TweakPrimaryView {
        Value.primaryView
    }
    override var hasSecondaryView: Bool {
        Value.hasSecondaryView
    }
    override var secondaryView: TweakSecondaryView? {
        Value.secondaryView
    }
    
    override init(name: String, default: Value) {
        assert(`default`.validateAsDefaultValue(), "Invalid default value: \(`default`) for \(name)")
        
        super.init(name: name, default: `default`)
    }
}
