//
//  TweakContext+Facade.swift
//  TweaKit
//
//  Created by cokile on 2021/6/27.
//  Copyright © 2021 daycam. All rights reserved.
//

import Foundation

public extension TweakContext {
    func show(locateAt tweak: AnyTweak? = nil, completion: ((Bool) -> Void)? = nil) {
        showWindow(locateAt: tweak, completion: completion)
    }
    
    func dismiss(completion: ((Bool) -> Void)? = nil) {
        dismissWindow(completion: completion)
    }
}

public extension TweakContext {
    func `import`(from source: TweakTradeSource, completion: ((TweakError?) -> Void)? = nil) {
        trader.import(from: source, completion: completion)
    }
}

public extension TweakContext {
    func reset() {
        store.removeAll()
    }
}
