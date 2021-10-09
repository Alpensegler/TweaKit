//
//  TweakStoreCache.swift
//  TweaKit
//
//  Created by cokile
//

import UIKit

final class TweakStoreCache {
    var contents: [String: Storable] = [:]
}

extension TweakStoreCache {
    func hasValue(forKey key: String) -> Bool {
        _hasContent(forKey: key)
    }
    
    func value<Value: Storable>(forKey key: String) -> Value? {
        if let value = _content(forKey: key) as? Value {
            return value
        } else {
            return nil
        }
    }
    
    func data(forkey key: String) -> Data? {
        _content(forKey: key)?.convertToData()
    }
    
    func setValue(_ value: Storable, forKey key: String) {
        _upsertContent(value, forKey: key)
    }
    
    func removeValue(forKey key: String) {
        _removeContent(forKey: key)
    }
    
    func removeAll() {
        _removeAllContents()
    }
}

private extension TweakStoreCache {
    func _hasContent(forKey key: String) -> Bool {
        contents[key] != nil
    }
    
    func _content(forKey key: String) -> Storable? {
        contents[key]
    }
    
    func _upsertContent(_ value: Storable, forKey key: String) {
        contents[key] = value
    }
    
    func _removeContent(forKey key: String) {
        contents.removeValue(forKey: key)
    }
    
    func _removeAllContents() {
        contents.removeAll(keepingCapacity: true)
    }
}
