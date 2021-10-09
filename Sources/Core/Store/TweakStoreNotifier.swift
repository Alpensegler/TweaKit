//
//  TweakStoreNotifier.swift
//  TweaKit
//
//  Created by cokile
//

import Foundation

// MARK: Notifier

final class TweakStoreNotifier {
    typealias ValueChangeHandler = (Data?, Data?, Bool) -> Void // $0: old data, $1: new data, $2: manually
    private var notifyKeys: [NotifyToken: String] = [:] // key: token, value: listened key
    private var notifyTokens: [String: Set<NotifyToken>] = [:] // key: listened key, value: tokens
    private var notifyHandlers: [NotifyToken: ValueChangeHandler] = [:] // key: token, value: handler
}

extension TweakStoreNotifier {
    func startNotifying(forKey key: String, store: TweakStore, handler: @escaping ValueChangeHandler) -> NotifyToken {
        let token = NotifyToken(store: store)
        notifyKeys[token] = key
        notifyTokens[key, default: []].insert(token)
        notifyHandlers[token] = handler
        return token
    }
    
    func stopNotifying(ForToken token: NotifyToken) {
        if let key = notifyKeys.removeValue(forKey: token) {
            notifyTokens[key]?.remove(token)
            if notifyTokens[key]?.isEmpty == true {
                notifyTokens.removeValue(forKey: key)
            }
        }
        notifyHandlers.removeValue(forKey: token)
    }
    
    func stopNotifying(forKey key: String) {
        guard let tokens = notifyTokens.removeValue(forKey: key) else { return }
        tokens.forEach {
            $0.markUnusable()
            notifyKeys.removeValue(forKey: $0)
            notifyHandlers.removeValue(forKey: $0)
        }
    }
    
    func getNotifyTokens(forKey key: String) -> Set<NotifyToken> {
        notifyTokens[key] ?? []
    }
    
    func getAllNotifyTokens() -> [String: Set<NotifyToken>] {
        notifyTokens
    }
    
    func notifiy(forTokens tokens: Set<NotifyToken>, old: Data?, new: Data?, manually: Bool) {
        if tokens.isEmpty { return }
        
        let handlers = tokens.compactMap { notifyHandlers[$0] }
        let work = {
            handlers.forEach { $0(old, new, manually) }
        }
        if DispatchQueue.isMain {
            work()
        } else {
            DispatchQueue.main.async(execute: work)
        }
    }
}

// MARK: - NotifyToken

public final class NotifyToken {
    private weak var store: TweakStore?
    private let rawValue: String
    private var isUsable = true
    
    deinit {
        if isUsable {
            invalidate()
        }
    }
    
    init(store: TweakStore, rawValue: String = UUID().uuidString) {
        self.store = store
        self.rawValue = rawValue
    }
}

public extension NotifyToken {
    func invalidate() {
        store?.stopNotifying(ForToken: self)
    }
}

fileprivate extension NotifyToken {
    func markUnusable() {
        isUsable = false
    }
}

extension NotifyToken: Hashable {
    public static func == (lhs: NotifyToken, rhs: NotifyToken) -> Bool {
        lhs.rawValue == rhs.rawValue
    }
   
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}

extension NotifyToken: CustomDebugStringConvertible {
    public var debugDescription: String {
        rawValue
    }
}
