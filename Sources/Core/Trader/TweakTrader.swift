//
//  TweakTrader.swift
//  TweaKit
//
//  Created by cokile
//

import Foundation

public typealias TweakTradeCargo = Data

final class TweakTrader {
    private(set) weak var context: TweakContext?
    
    private var importer: TweakImporter!
    private var exporter: TweakExporter!
    
    init(context: TweakContext) {
        self.context = context
        self.importer = TweakImporter(trader: self)
        self.exporter = TweakExporter(trader: self)
    }
}

extension TweakTrader {
    func `import`(from source: TweakTradeSource, completion: ((TweakError?) -> Void)? = nil) {
        importer.import(from: source, completion: completion)
    }
    
    func export(tweaks: [AnyTradableTweak], to destination: TweakTradeDestination, completion: ((TweakError?) -> Void)? = nil) {
        exporter.export(tweaks: tweaks, to: destination, completion: completion)
    }
}
