//
//  NotifyToken.swift
//  TweaKit
//
//  Created by cokile
//

import Foundation

public final class NotifyToken {
    private weak var store: TweakStore?
    private let rawValue: String
    
    deinit {
        invalidate()
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
