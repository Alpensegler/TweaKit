//
//  TweakType.swift
//  TweaKit
//
//  Created by cokile
//

import Foundation

public protocol TweakType {
    associatedtype Value
    associatedtype Base = Self
    
    init(base: Base)
}

public extension TweakType where Base == Self {
    init(base: Base) { self = base }
}

public protocol AnyTweak: AnyObject {
    var name: String { get }
    var section: TweakSection? { get set }
    var info: TweakInfo { get }
    var currentValue: Storable { get }
    
    var primaryViewReuseID: String { get }
    var primaryView: TweakPrimaryView { get }
    var hasSecondaryView: Bool { get }
    var secondaryView: TweakSecondaryView? { get }
    
    func register(in context: TweakContext)
}

extension AnyTweak {
    public var id: String {
        let names: [String?] = [list?.name, section?.name, name]
        return names.compactMap { $0 }.joined(separator: Constants.idSeparator)
    }
    
    var list: TweakList? { section?.list }
    var context: TweakContext? { list?.context }
}

public protocol AnyTradableTweak: AnyTweak {
    func rawData(from value: TweakTradeValue) -> Result<Data, TweakError>
    func tradeValue() -> TweakTradeValue
}
