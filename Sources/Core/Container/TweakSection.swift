//
//  TweakSection.swift
//  TweaKit
//
//  Created by cokile
//

import Foundation

public final class TweakSection {
    public let name: String
    let tweaks: [AnyTweak]
    
    weak var list: TweakList?
    
    public init(_ name: String, @AnyTweakBuilder _ tweaks: () -> [AnyTweak]) {
        assert(!name.contains(Constants.idSeparator), "TweakSection name should not have \(Constants.idSeparator)")
        
        self.name = name
        self.tweaks = tweaks()
        self.tweaks.forEach { $0.section = self }
    }
}

extension TweakSection {
    var context: TweakContext? { list?.context }
}

extension TweakSection: TweakBuildable {
    public var constrainKey: String { name }
    
    public func hasBuilt() -> Bool {
        list != nil
    }
}

extension TweakSection: CustomDebugStringConvertible {
    public var debugDescription: String {
        var desc = "  \(name): {\n"
        tweaks.forEach { desc.append("   \($0.name)\n") }
        desc.append("  }")
        return desc
    }
}
