//
//  TweakContext+Facade.swift
//  TweaKit
//
//  Created by cokile on 2021/6/27.
//  Copyright © 2021 daycam. All rights reserved.
//

import Foundation

public extension TweakContext {
    /// Shows the tweak widow of the context.
    ///
    /// This method will do nothing:
    ///   1. if there is a showing window.
    ///   2. If the context has no list at all.
    ///
    /// - Note: You should only call this method in main thread.
    ///
    /// - Parameters:
    ///   - tweak: The tweak that should be located at when window is shown.
    ///
    ///     The default is `nil`, which means showing the first tweak of the initially shown list.
    ///   - completion: A block that TweaKit calls after showing the context window.
    ///
    ///     The block takes the following parameter:
    ///
    ///     **success**: true if TweaKit successfully shown the window; otherwise, false.
    func show(locateAt tweak: AnyTweak? = nil, completion: ((Bool) -> Void)? = nil) {
        showWindow(locateAt: tweak, completion: completion)
    }
    
    /// Dismisses the current showing tweak window of the context.
    ///
    /// 1. This method will do nothing if there is no showing window.
    /// 2. You cannot dismiss the window when it is floating.
    ///
    /// - Note: You should only call this method in main thread.
    ///
    /// - Parameters:
    ///   - completion: A block that TweaKit calls after dismissing the context window.
    ///
    ///     The block takes the following parameter:
    ///
    ///     **success**: true if TweaKit successfully dismissed the window; otherwise, false.
    func dismiss(completion: ((Bool) -> Void)? = nil) {
        dismissWindow(completion: completion)
    }
}

public extension TweakContext {
    /// Imports tweaks for the source.
    ///
    /// Tweaks that not in the context will be ignored.
    ///
    /// - Note: You should only call this method in main thread.
    ///
    /// - Parameters:
    ///   - source: The source of the tweaks to be imported.
    ///   - completion: A block that TweaKit calls after the source has been import.
    ///
    ///     The block takes the following parameter:
    ///
    ///     **error**: If an error occurs, an TweakError object describing the error; otherwise, nil.
    func `import`(from source: TweakTradeSource, completion: ((TweakError?) -> Void)? = nil) {
        trader.import(from: source, completion: completion)
    }
}

public extension TweakContext {
    /// Reset all the tweaks' values and info to the default ones.
    func reset() {
        store.removeAll()
    }
}

public extension TweakContext {
    /// Search tweaks in the current context.
    ///
    /// This method will use the same search strategies specified in ``TweakContextDelegate``.
    ///
    /// \
    /// You should get the same results as searching with the tweak UI.
    /// Calling this method will also contribute to search history in the tweak UI.
    ///
    /// - Parameters:
    ///   - keyword: The keyword to search. An empty keyword means searching nothing.
    /// - Returns: Tweaks that match the given keyord. Tweaks from the same section are grouped together.
    func search(with keyword: String) -> [[AnyTweak]] {
        if keyword.isEmpty { return [] }
        
        let searcher = TweakSearcher(context: self)
        var results: [[AnyTweak]] = []
        searcher.bind { event in
            guard case let .updateTweakResults(searchingResults, searchingKeyword) = event, keyword == searchingKeyword else { return }
            results = searchingResults
        }
        // we don't do debounce here since this is a synchronous method
        searcher.search(with: keyword, debounce: false)
        return results
    }
}
