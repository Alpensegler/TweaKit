//
//  TweakSection.swift
//  TweaKit
//
//  Created by cokile
//

import Foundation

/// ``TweakSection`` is the container of tweaks.
///
/// A section is a "card" in the list UI. Each section is constructed by several ``AnyTweak`` objects.
///
/// You don't use TweakSection directly most of the time, it is usually used to constructed the ``TweakList`` object.
public final class TweakSection {
    /// The name of the section.
    ///
    /// `name` is also the id of the section which means there are no two sections that have the same name in one list.
    public let name: String
    
    let tweaks: [AnyTweak]

    weak var list: TweakList?
    
    /// Creates and initializes a tweak section with the given name and the tweaks.
    ///
    /// The tweaks of the sections are sorted by alphabetic order and tweaks with duplicated names are filtered.
    ///
    /// - Parameters:
    ///   - name: The name of the section.
    ///   - sections: A builder that creates the tweaks of the section.
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
    public var hasBuilt: Bool { list != nil }
}

extension TweakSection: CustomDebugStringConvertible {
    public var debugDescription: String {
        var desc = "  \(name): {\n"
        tweaks.forEach { desc.append("   \($0.name)\n") }
        desc.append("  }")
        return desc
    }
}
