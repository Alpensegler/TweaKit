//
//  TweakStore.swift
//  TweaKit
//
//  Created by cokile
//

import Foundation

final class TweakStore {
    private let cache: TweakStoreCache
    private let persistency: TweakStorePersistency
    private let notifier: TweakStoreNotifier

    private let lock: Lock

    init(name: String, appGroupID: String? = nil) {
        self.cache = TweakStoreCache()
        self.persistency = TweakStorePersistency(name: name, appGroupID: appGroupID)
        self.notifier = TweakStoreNotifier()

        self.lock = Lock()
    }
}

extension TweakStore {
    func hasValue(forKey key: String) -> Bool {
        _lock(); defer { _unlock() }

        return _hasCachedValue(forKey: key)
            || _hasPersistentValue(forKey: key)
    }

    func value<Value: Storable>(forKey key: String) -> Value? {
        _lock(); defer { _unlock() }

        if let cached: Value = _cachedValue(forKey: key) {
            return cached
        } else if let persistent = _persistentData(forKey: key).flatMap(Value.convert(from:)) {
            _setCacheValue(persistent, forKey: key)
            return persistent
        } else {
            return nil
        }
    }

    func setValue(_ value: Storable, forKey key: String, manually: Bool = false) {
        _lock()

        let tokens = _getNotifyTokens(forKey: key)
        var needNotify = false
        var oldData: Data?
        if !tokens.isEmpty {
            needNotify = true
            oldData = _rawData(forKey: key)
        }

        let newData = value.convertToData()
        guard _setPersistentData(newData, forKey: key) else {
            _unlock()
            return
        }

        _setCacheValue(value, forKey: key)

        _unlock()

        if needNotify {
            _notify(tokens: tokens, old: oldData, new: newData, manually: manually)
        }
    }

    func removeValue(forKey key: String, manually: Bool = false) {
        _lock()

        let tokens = _getNotifyTokens(forKey: key)
        var needNotify = false
        var oldData: Data?
        if !tokens.isEmpty {
            needNotify = true
            oldData = _rawData(forKey: key)
        }

        guard _removePersistentValue(forKey: key) else {
            _unlock()
            return
        }

        _removeCacheValue(forKey: key)

        _unlock()

        if needNotify, oldData != nil {
            _notify(tokens: tokens, old: oldData, new: nil, manually: manually)
        }
    }

    func removeAll() {
        _lock()

        let tokens = _getAllNotifyTokens()
        var oldData: [String: Data] = [:]
        for key in tokens.keys {
            guard let oldRawData = _rawData(forKey: key) else { continue }
            oldData[key] = oldRawData
        }

        guard _removeAllPersistentValues() else {
            _unlock()
            return
        }

        _removeAllCachedValues()
        _unlock()

        for (key, data) in oldData {
            _notify(tokens: tokens[key, default: []], old: data, new: nil, manually: false)
        }
    }

    func rawData(forKey key: String) -> Data? {
        _lock(); defer { _unlock() }

        return _rawData(forKey: key)
    }

    func setRawData(_ data: Data, forKey key: String, manually: Bool = false) {
        _lock()

        let oldData = _rawData(forKey: key)
        guard _setPersistentData(data, forKey: key) else {
            _unlock()
            return
        }

        _removeCacheValue(forKey: key)
        let tokens = _getNotifyTokens(forKey: key)

        _unlock()

        _notify(tokens: tokens, old: oldData, new: data, manually: manually)
    }

    func startNotifying(forKey key: String, handler: @escaping TweakStoreNotifier.ValueChangeHandler) -> NotifyToken {
        _lock(); defer { _unlock() }

        return _startNotifying(forKey: key, handler: handler)
    }

    func stopNotifying(ForToken token: NotifyToken) {
        _lock(); defer { _unlock() }

        _stopNotifying(ForToken: token)
    }

    func stopNotifying(forKey key: String) {
        _lock(); defer { _unlock() }

        _stopNotifying(forKey: key)
    }
}

private extension TweakStore {
    func _lock() {
        lock.lock()
    }

    func _unlock() {
        lock.unlock()
    }
}

private extension TweakStore {
    func _rawData(forKey key: String) -> Data? {
        _cachedData(forKey: key) ?? _persistentData(forKey: key)
    }
}

private extension TweakStore {
    func _hasCachedValue(forKey key: String) -> Bool {
        cache.hasValue(forKey: key)
    }

    func _cachedValue<Value: Storable>(forKey key: String) -> Value? {
        cache.value(forKey: key)
    }

    func _setCacheValue(_ value: Storable, forKey key: String) {
        cache.setValue(value, forKey: key)
    }

    func _removeCacheValue(forKey key: String) {
        cache.removeValue(forKey: key)
    }

    func _removeAllCachedValues() {
        cache.removeAll()
    }

    func _cachedData(forKey key: String) -> Data? {
        cache.data(forKey: key)
    }
}

private extension TweakStore {
    func _hasPersistentValue(forKey key: String) -> Bool {
        persistency.hasData(forKey: key)
    }

    func _removePersistentValue(forKey key: String) -> Bool {
        do {
            try persistency.removeData(forKey: key)
            return true
        } catch {
            Logger.log("fail to remove persistent value for \(key), error: \(error)")
            return false
        }
    }

    func _removeAllPersistentValues() -> Bool {
        do {
            try persistency.removeAll()
            return true
        } catch {
            Logger.log("fail to remove all persistent values, error: \(error)")
            return false
        }
    }

    func _persistentData(forKey key: String) -> Data? {
        do {
            return try persistency.data(forKey: key)
        } catch {
            Logger.log("fail to get persistent value for \(key), error: \(error)")
            return nil
        }
    }

    func _setPersistentData(_ data: Data, forKey key: String) -> Bool {
        do {
            try persistency.setData(data, forKey: key)
            return true
        } catch {
            Logger.log("fail to persist value for \(key), error: \(error)")
            return false
        }
    }
}

private extension TweakStore {
    func _startNotifying(forKey key: String, handler: @escaping TweakStoreNotifier.ValueChangeHandler) -> NotifyToken {
        notifier.startNotifying(forKey: key, store: self, handler: handler)
    }

    func _stopNotifying(ForToken token: NotifyToken) {
        notifier.stopNotifying(ForToken: token)
    }

    func _stopNotifying(forKey key: String) {
        notifier.stopNotifying(forKey: key)
    }

    func _getNotifyTokens(forKey key: String) -> Set<NotifyToken> {
        notifier.getNotifyTokens(forKey: key)
    }

    func _getAllNotifyTokens() -> [String: Set<NotifyToken>] {
        notifier.getAllNotifyTokens()
    }

    func _notify(tokens: Set<NotifyToken>, old: Data?, new: Data?, manually: Bool) {
        notifier.notify(forTokens: tokens, old: old, new: new, manually: manually)
    }
}
