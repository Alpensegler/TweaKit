//
//  TweakList.swift
//  TweaKit
//
//  Created by cokile
//

import Foundation

/// ``TweakList`` is the container of ``TweakSection``.
///
/// A list is a vertically scroll list in the UI. Each list is constructed by several sections.
///
/// You don't use TweakList directly most of the time, it is usually used to constructed the ``TweakContext`` object.
public final class TweakList {
    /// The name of the list.
    ///
    /// `name` is also the id of the list which means there are no two lists that have the same name in one context.
    public let name: String

    let sections: [TweakSection]

    weak var context: TweakContext?

    /// Creates and initializes a tweak list with the given name and the tweak sections.
    ///
    /// The sections of the list are sorted by alphabetic order and sections with duplicated names are filtered.
    ///
    /// - Parameters:
    ///   - name: The name of the list.
    ///   - sections: A builder that creates the sections of the list.
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
    public var hasBuilt: Bool { context != nil }
}

extension TweakList: CustomDebugStringConvertible {
    public var debugDescription: String {
        var desc = " \(name): {\n"
        sections.forEach { desc.append("\($0.debugDescription)\n") }
        desc.append(" }")
        return desc
    }
}
