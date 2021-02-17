//
//  TweakContext.swift
//  TweaKit
//
//  Created by cokile
//

import Foundation

public extension TweakContext {
    struct Config {
        let name: String
        let appGroupID: String?
        
        public init(
            name: String = "Tweaks",
            appGroupID: String? = nil
        ) {
            self.name = name
            self.appGroupID = appGroupID
        }
    }
}

@dynamicMemberLookup
public final class TweakContext {
    private let config: Config
    private(set) weak var delegate: TweakContextDelegate?
    let store: TweakStore
    
    private(set) var trader: TweakTrader!
    
    let lists: [TweakList]
    var lastList: TweakList?
    
    public internal(set) var isShowing = false
    var showingWindow: TweakWindow?
    var floatingTransitioner: TweakFloatingTransitioner?
    
    public init(config: Config = .init(), delegate: TweakContextDelegate? = nil, @TweakContainerBuilder<TweakList> _ lists: () -> [TweakList]) {
        self.config = config
        self.delegate = delegate
        self.store = TweakStore(name: config.name.appending("_Store"), appGroupID: config.appGroupID)
        
        self.lists = lists()
        self.lists.forEach { $0.context = self }
        
        self.tweaks.forEach { $0.register(in: self) }
        
        self.trader = TweakTrader(context: self)
    }
    
    subscript<Value>(dynamicMember keyPath: KeyPath<Config, Value>) -> Value {
        config[keyPath: keyPath]
    }
}

extension TweakContext {
    var sections: [TweakSection] { lists.flatMap(\.sections) }
    var tweaks: [AnyTweak] { sections.flatMap(\.tweaks) }
}

extension TweakContext: CustomDebugStringConvertible {
    public var debugDescription: String {
        var desc = "\(self.name): {\n"
        lists.forEach { desc.append("\($0.debugDescription)\n") }
        desc.append("}")
        return desc
    }
}
