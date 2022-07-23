//
//  SelectableTweak.swift
//  TweaKit
//
//  Created by cokile
//

import UIKit

/// A type with values that support selection.
public typealias Selectable = TweakSecondaryViewItemConvertible

public extension TweakType where Base == Tweak<Value>, Value: Selectable {
    /// Creates and initializes a tweak for ``Selectable`` type.
    ///
    /// - Parameters:
    ///   - name: The name of the tweak.
    ///   - defaultValue: The default value of the tweak.
    ///   - options: The selection options.
    ///              The options must not be empty and must contain the default value.
    init(name: String, defaultValue: Value, options: [Value]) {
        let base = SelectableTweak(name: name, defaultValue: defaultValue, options: options)
        self.init(base: base)
    }
}

final class SelectableTweak<Value: Selectable>: Tweak<Value> {
    let options: [Value]

    override var primaryViewReuseID: String {
        TweakPrimaryViewDisclosurer.reuseID
    }
    override var primaryView: TweakPrimaryView {
        TweakPrimaryViewDisclosurer { tweak in
            guard let tweak = tweak as? Self, let value = tweak.currentValue as? Value else {
                return nil
            }
            return value.displayText
        }
    }
    override var hasSecondaryView: Bool {
        true
    }
    override var secondaryView: TweakSecondaryView? {
        TweakSecondaryViewSelector<Value>()
    }

    init(name: String, defaultValue: Value, options: [Value]) {
        assert(!options.isEmpty, "Must have at least 1 option for selection")
        assert(options.contains(defaultValue), "Options does not contains default value")

        self.options = options
        super.init(name: name, default: defaultValue)
    }

    override var rawValue: Value {
        if let storedValue = super.storedValue, options.contains(storedValue) {
            return storedValue
        } else {
            return defaultValue
        }
    }

    override func validate(unmarshaled: Value) -> Bool where Value: TradedTweakable {
        options.contains(unmarshaled)
    }
}
