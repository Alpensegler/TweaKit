//
//  TweakContext.swift
//  TweaKit
//
//  Created by cokile
//

import Foundation

public extension TweakContext {
    /// A model represents the meta data of a ``TweakContext`` object.
    struct Config {
        /// The name of the the tweak context.
        let name: String
        /// The app group id of the adopting project.
        ///
        /// You can specify the app group id if you want to use TweaKit in both the host app and app extensions.
        /// A non-empty value will instruct TweaKit to persist tweak value in the app group container rather than in the app sandbox directory.
        let appGroupID: String?

        /// Creates and initializes a tweak context config with the given name and app group id.
        ///
        /// - Parameters:
        ///   - name: The name of the tweak context. The default is "Tweaks".
        ///   - appGroupID: The app group id of the adopting project. The default is `nil`.
        public init(
            name: String = "Tweaks",
            appGroupID: String? = nil
        ) {
            self.name = name
            self.appGroupID = appGroupID
        }
    }
}

/// The context in which tweaks live.
///
/// A `TweakContext` object provides a facade to interact with tweaks, like showing tweaks and import tweaks.
///
/// You can create as many `TweakContext` objects as you like. But one context is sufficient in most cases.
@dynamicMemberLookup
public final class TweakContext {
    private let config: Config
    private(set) weak var delegate: TweakContextDelegate?

    let store: TweakStore

    private(set) var trader: TweakTrader!

    let lists: [TweakList]
    var lastShowingList: TweakList?

    /// A flag indicates whether the context is showing the tweak window.
    public internal(set) var isShowing = false
    var showingWindow: TweakWindow?
    var floatingTransitioner: TweakFloatingTransitioner?

    /// Creates and initializes a tweak context with the given config, delegate and the tweak lists.
    ///
    /// - Parameters:
    ///   - config: The meta data of the context. The default is a default config object.
    ///   - delegate: The object that acts as the delegate of the context. The delegate is not retained. The default is `nil`.
    ///   - lists: The lists of tweaks of the context. The lists and the sections/tweaks in them are sorted by their names in alphabetic order.
    public init(config: Config = .init(), delegate: TweakContextDelegate? = nil, @TweakContainerBuilder<TweakList> _ lists: () -> [TweakList]) {
        self.config = config
        self.delegate = delegate
        self.store = TweakStore(name: config.name.appending("_Store"), appGroupID: config.appGroupID)

        self.lists = lists()
        self.lists.forEach { $0.context = self }

        self.tweaks.forEach { $0.register(in: self) }

        self.trader = TweakTrader(context: self)
    }

    public subscript<Value>(dynamicMember keyPath: KeyPath<Config, Value>) -> Value {
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
