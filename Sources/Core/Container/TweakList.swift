//
//  TweakList.swift
//  TweaKit
//
//  Created by cokile
//

import Foundation

public final class TweakList {
    public let name: String
    let sections: [TweakSection]
    
    weak var context: TweakContext?
    
    public init(_ name: String, @TweakContainerBuilder<TweakSection> _ sections: () -> [TweakSection]) {
        assert(!name.contains(Constants.idSeparator), "TweakList name should not have \(Constants.idSeparator)")
        
        self.name = name
        self.sections = sections()
        self.sections.forEach { $0.list = self }
    }
}

extension TweakList {
    var tweaks: [AnyTweak] { sections.flatMap(\.tweaks) }
}

extension TweakList: TweakBuildable {
    public var constrainKey: String { name }
    
    public func hasBuilt() -> Bool {
        context != nil
    }
}

extension TweakList: CustomDebugStringConvertible {
    public var debugDescription: String {
        var desc = " \(name): {\n"
        sections.forEach { desc.append("\($0.debugDescription)\n") }
        desc.append(" }")
        return desc
    }
}
