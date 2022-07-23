//
//  TweakInfo.swift
//  TweaKit
//
//  Created by cokile
//

import Foundation

// A type with values that have extra info of a tweak.
public final class TweakInfo {
    private var transients: [Key<KeyType.Transient>: Any] = [:]
    private var persistents: [Key<KeyType.Persistent>: Storable] = [:]

    weak var tweak: AnyTweak?
}

extension TweakInfo {
    subscript<Value>(_ key: Key<KeyType.Transient>, default value: @autoclosure () -> Value) -> Value {
        get { transients[key] as? Value ?? value() }
        set { transients[key] = newValue }
    }

    subscript<Value>(_ key: Key<KeyType.Transient>) -> Value? {
        get { transients[key] as? Value }
        set { transients[key] = newValue }
    }
}

extension TweakInfo {
    func persistent<Value: Storable>(forKey key: Key<KeyType.Persistent>) -> Value? {
        if let value = persistents[key] as? Value {
            return value
        } else if let value: Value = tweak?.context?.store.value(forKey: _persistentKey(forKey: key)) {
            return value
        } else {
             return nil
        }
    }

    func setPersistent<Value: Storable>(_ value: Value?, forKey key: Key<KeyType.Persistent>, override: Bool) {
        let forceSet = (override || value == nil)
        if !forceSet, let _: Value = persistent(forKey: key) { return }

        if let store = tweak?.context?.store {
            let key = _persistentKey(forKey: key)
            if let value = value {
                store.setValue(value, forKey: key)
            } else {
                store.removeValue(forKey: key)
            }
        } else {
            persistents[key] = value
        }
    }

    func persist(in context: TweakContext) {
        if persistents.isEmpty { return }

        for (key, value) in persistents {
            context.store.setValue(value, forKey: _persistentKey(forKey: key))
        }
        persistents.removeAll()
    }
}

private extension TweakInfo {
    func _persistentKey(forKey key: Key<KeyType.Persistent>) -> String {
        (tweak?.id).map { $0.appending(Constants.idSeparator).appending(key.rawValue) } ?? key.rawValue
    }
}

extension TweakInfo {
    // InfoType acts as a phantom
    final class Key<InfoType>: RawRepresentable, ExpressibleByStringLiteral, Hashable {
        let rawValue: String

        init(rawValue value: String) {
            rawValue = value
        }

        init(stringLiteral value: String) {
            rawValue = value
        }

        static func == (lhs: TweakInfo.Key<InfoType>, rhs: TweakInfo.Key<InfoType>) -> Bool {
            lhs.rawValue == rhs.rawValue
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(rawValue)
        }
    }

    enum KeyType {
        enum Persistent { }
        enum Transient { }
    }
}
