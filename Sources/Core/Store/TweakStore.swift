//
//  TweakStore.swift
//  TweaKit
//
//  Created by cokile
//

import Foundation

// The storage implementation (now is UserDefault) may be replaced in the future.

final class TweakStore {
    private let name: String
    
    private let cache = NSCache<NSString, Reference<Storable>>()
    private let persistency: UserDefaults
    
    typealias ValueChangeHandler = (Data?, Data?, Bool) -> Void
    private var notifyKeys: [NotifyToken: String] = [:] // key: token, value: listened key
    private var notifyTokens: [String: Set<NotifyToken>] = [:] // key: listened key, value: tokens
    private var notifyHandlers: [NotifyToken: ValueChangeHandler] = [:] // key: token, value: handler
    
    init(name: String, appGroupID: String? = nil) {
        self.name = name
        self.cache.name = name
        self.persistency = appGroupID.flatMap { UserDefaults(suiteName: $0) }
            ?? UserDefaults(suiteName: name)
            ?? .standard
    }
}

extension TweakStore {
    func hasValue(forKey rawKey: String) -> Bool {
        let key = _key(from: rawKey)
        return _hasCachedValue(forKey: key)
            || _hasPersistentValue(forKey: key)
    }
    
    func value<Value: Storable>(forKey rawKey: String) -> Value? {
        let key = _key(from: rawKey)
        if let cached: Value = _cachedValue(forKey: key) {
            return cached
        } else if let persistent: Value = _persistentValue(forKey: key) {
            _setCacheValue(persistent, forKey: key, manually: false)
            return persistent
        } else {
            return nil
        }
    }
    
    func setValue(_ value: Storable, forKey rawKey: String, manually: Bool = false) {
        let key = _key(from: rawKey)
        _setCacheValue(value, forKey: key, manually: manually)
        _setPersistentValue(value, forKey: key, manually: manually)
    }
    
    func removeValue(forKey rawKey: String) {
        let key = _key(from: rawKey)
        _removeCacheValue(forKey: key)
        _removePersistentValue(forKey: key)
    }
    
    func removeAll() {
        _removeAllCachedValues()
        _removeAllPersistentValues()
    }
    
    func rawData(forKey rawKey: String) -> Data? {
        let key = _key(from: rawKey)
        return _persistentData(forKey: key)
    }
    
    func setRawData(_ data: Data, forKey rawKey: String, manually: Bool = false) {
        let key = _key(from: rawKey)
        _removeCacheValue(forKey: key)
        _setPersistentData(data, forKey: key, manually: manually)
    }
    
    func startNotifying(forKey rawKey: String, handler: @escaping ValueChangeHandler) -> NotifyToken {
        let key = _key(from: rawKey)
        return _startNotifying(forKey: key, handler: handler)
    }
    
    func stopNotifying(ForToken token: NotifyToken) {
        _stopNotifying(ForToken: token)
    }
    
    func stopNotifying(forKey rawKey: String) {
        let key = _key(from: rawKey)
        _stopNotifying(forKey: key)
    }
}

private extension TweakStore {
    func _hasCachedValue(forKey key: String) -> Bool {
        cache.object(forKey: key as NSString) != nil
    }
    
    func _cachedValue<Value: Storable>(forKey key: String) -> Value? {
        cache.object(forKey: key as NSString)?.value as? Value
    }
    
    func _setCacheValue(_ value: Storable, forKey key: String, manually: Bool) {
        cache.setObject(.init(value: value), forKey: key as NSString)
    }
    
    func _removeCacheValue(forKey key: String) {
        cache.removeObject(forKey: key as NSString)
    }
    
    func _removeAllCachedValues() {
        cache.removeAllObjects()
    }
}

private extension TweakStore {
    func _hasPersistentValue(forKey key: String) -> Bool {
        persistency.data(forKey: key) != nil
    }

    func _persistentValue<Value: Storable>(forKey key: String) -> Value? {
        persistency.data(forKey: key).flatMap({ Value.convert(from: $0) })
    }
    
    func _setPersistentValue(_ value: Storable, forKey key: String, manually: Bool) {
        _setPersistentData(value.convertToData(), forKey: key, manually: manually)
    }
    
    func _removePersistentValue(forKey key: String) {
        _removePersistentData(forKey: key)
    }
    
    func _removeAllPersistentValues() {
        for key in persistency.dictionaryRepresentation().keys {
            guard key.hasPrefix(Constants.storeKeyMagicWord) else { continue }
            _removePersistentData(forKey: key)
        }
    }
    
    func _persistentData(forKey key: String) -> Data? {
        persistency.data(forKey: key)
    }
    
    func _setPersistentData(_ data: Data, forKey key: String, manually: Bool) {
        let oldData = persistency.data(forKey: key)
        if oldData == data { return }
        persistency.setValue(data, forKey: key)
        _notifiy(forKey: key, old: oldData, new: data, manually: manually)
    }
    
    func _removePersistentData(forKey key: String) {
        let old = persistency.data(forKey: key)
        if old == nil { return }
        persistency.removeObject(forKey: key)
        _notifiy(forKey: key, old: old, new: nil, manually: false)
    }
}

private extension TweakStore {
    func _startNotifying(forKey key: String, handler: @escaping ValueChangeHandler) -> NotifyToken {
        let token = NotifyToken(store: self)
        notifyKeys[token] = key
        notifyTokens[key, default: []].insert(token)
        notifyHandlers[token] = handler
        return token
    }
    
    func _stopNotifying(ForToken token: NotifyToken) {
        if let key = notifyKeys.removeValue(forKey: token) {
            notifyTokens[key, default: []].remove(token)
        }
        notifyHandlers.removeValue(forKey: token)
    }
    
    func _stopNotifying(forKey key: String) {
        guard let tokens = notifyTokens.removeValue(forKey: key) else { return }
        tokens.forEach {
            notifyKeys.removeValue(forKey: $0)
            notifyHandlers.removeValue(forKey: $0)
        }
    }
    
    func _notifiy(forKey key: String, old: Data?, new: Data?, manually: Bool) {
        guard let tokens = self.notifyTokens[key] else { return }
        tokens.forEach { notifyHandlers[$0]?(old, new, manually) }
    }
}

private extension TweakStore {
    func _key(from rawKey: String) -> String {
        if rawKey.hasPrefix(Constants.storeKeyMagicWord) { return rawKey }
        return Constants.storeKeyMagicWord.appending(rawKey)
    }
    
    func _rawKey(from key: String) -> String {
        guard key.hasPrefix(Constants.storeKeyMagicWord) else { return key }
        return String(key.utf8.dropFirst(Constants.storeKeyMagicWordCount))!
    }
}

private extension Constants {
    static let storeKeyMagicWord = "§§TweaKit§§"
    static let storeKeyMagicWordCount = storeKeyMagicWord.utf8.count
}
