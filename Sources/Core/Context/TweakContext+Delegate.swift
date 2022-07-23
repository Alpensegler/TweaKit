//
//  TweakContext+Delegate.swift
//  TweaKit
//
//  Created by cokile
//

import CoreGraphics
import Foundation

/// Methods for configuring trade, search and UI related behaviors in a context.
public protocol TweakContextDelegate: AnyObject {
    // MARK: - Trade

    /// Asks the delegate for the trade sources of the context during import.
    ///
    /// If this method is not implemented, then the return value is assumed to be no sources.
    ///
    /// - Parameters:
    ///   - context: The context asking the trade source.
    /// - Returns: An array of the ``TweakTradeSource`` objects.
    func tradeSources(for context: TweakContext) -> [TweakTradeSource]
    /// Asks the delegate for the trade destinations of the context during export.
    ///
    /// If this method is not implemented, then the return value is assumed to be no destinations.
    ///
    /// - Parameters:
    ///   - context: The context asking the trade destinations.
    /// - Returns: An array of ``TweakTradeDestination`` objects.
    func tradeDestinations(for context: TweakContext) -> [TweakTradeDestination]

    // MARK: - Search

    /// Asks the delegate whether performs fuzzy search when searching tweaks.
    ///
    /// If this method is not implemented, then the return value is assumed to be true.
    ///
    /// - Parameters:
    ///   - context: The context requesting this information.
    /// - Returns: True if performs fuzzy search; otherwise, false.
    func shouldFuzzySearch(for context: TweakContext) -> Bool
    /// Ask the delegate whether uses smartcase when searching tweaks.
    ///
    /// When using smartcase, if the keyword contains an uppercase letter, it is case sensitive, otherwise, it is not.
    ///
    /// If this method is not implemented, then the return value is assumed to be false.
    ///
    /// - Parameters:
    ///   - context: The context requesting this information.
    /// - Returns: True if uses smartcase; otherwise, false.
    func shouldSmartcaseSearch(for context: TweakContext) -> Bool
    /// Asks the delegate whether ignores cases when searching tweaks.
    ///
    /// If this method is not implemented, then the return value is assumed to be false.
    ///
    /// - Parameters:
    ///   - context: The context requesting this information.
    /// - Returns: True if respects case in the search keyword; otherwise, false.
    func shouldCaseSensitiveSearch(for context: TweakContext) -> Bool
    /// Asks the delegate for the max display search history count.
    ///
    /// If this method is not implemented, then the return value is assumed to be 10.
    ///
    /// - Parameters:
    ///   - context: The context requesting this information.
    /// - Returns: The max display search history count.
    func maxSearchHistoryCount(for context: TweakContext) -> Int
    /// Asks the delegate for the debounce due time (in seconds) to perform search when inputting keywords.
    ///
    /// If this method is not implemented, then the return value is assumed to be 0.3s.
    ///
    /// - Parameters:
    ///   - context: The context requesting this information.
    /// - Returns: The debounce due time (in seconds) to perform search when inputting keywords.
    func searchDebounceDueTime(for context: TweakContext) -> TimeInterval

    // MARK: - UI

    /// Informs the delegate when the window of the context will show.
    ///
    /// - Parameters:
    ///   - context: The context informing the delegate of this event.
    func willShowTweakWindow(for context: TweakContext)
    /// Informs the delegate when the window of the context did show.
    ///
    /// - Parameters:
    ///   - context: The context informing the delegate of this event.
    func didShowTweakWindow(for context: TweakContext)
    /// Informs the delegate when the window of the context will dismiss.
    ///
    /// - Parameters:
    ///   - context: The context informing the delegate of this event.
    func willDismissTweakWindow(for context: TweakContext)
    /// Informs the delegate when the window of the context did dismiss.
    ///
    /// - Parameters:
    ///   - context: The context informing the delegate of this event.
    func didDismissTweakWindow(for context: TweakContext)
    /// Asks the delegate whether remembers the tweak list shown in the UI when dismiss the tweak window.
    ///
    /// If this method returns true, then the tweak window will show the last shown list first at the next time.
    ///
    /// If this method is not implemented, then the return value is assumed to be true.
    ///
    /// - Parameters:
    ///   - context: The context requesting this information.
    /// - Returns: True if the tweak window will show the last shown list first at the next time; otherwise, false.
    func shouldRememberLastTweakList(for context: TweakContext) -> Bool
}

public extension TweakContextDelegate {
    func tradeSources(for context: TweakContext) -> [TweakTradeSource] { [] }
    func tradeDestinations(for context: TweakContext) -> [TweakTradeDestination] { [] }
}

public extension TweakContextDelegate {
    func shouldFuzzySearch(for context: TweakContext) -> Bool { true }
    func shouldSmartcaseSearch(for context: TweakContext) -> Bool { false }
    func shouldCaseSensitiveSearch(for context: TweakContext) -> Bool { false }
    func maxSearchHistoryCount(for context: TweakContext) -> Int { Constants.UI.Search.maxHistoryCount }
    func searchDebounceDueTime(for context: TweakContext) -> TimeInterval { Constants.UI.Search.debounceDueTime }
}

public extension TweakContextDelegate {
    func willShowTweakWindow(for context: TweakContext) { }
    func didShowTweakWindow(for context: TweakContext) { }
    func willDismissTweakWindow(for context: TweakContext) { }
    func didDismissTweakWindow(for context: TweakContext) { }
    func shouldRememberLastTweakList(for context: TweakContext) -> Bool { true }
}

// MARK: - TweakContext + Delegate

extension TweakContext {
    func tradeSources() -> [TweakTradeSource] {
        delegate?.tradeSources(for: self) ?? []
    }

    func tradeDestinations() -> [TweakTradeDestination] {
        delegate?.tradeDestinations(for: self) ?? []
    }
}

extension TweakContext {
    func shouldFuzzySearch() -> Bool {
        delegate?.shouldFuzzySearch(for: self) ?? true
    }

    func shouldSmartcaseSearch() -> Bool {
        delegate?.shouldSmartcaseSearch(for: self) ?? false
    }

    func shouldCaseSensitiveSearch() -> Bool {
        delegate?.shouldCaseSensitiveSearch(for: self) ?? false
    }

    func maxSearchHistoryCount() -> Int {
        delegate?.maxSearchHistoryCount(for: self) ?? Constants.UI.Search.maxHistoryCount
    }

    func searchDebounceDueTime() -> TimeInterval {
        delegate?.searchDebounceDueTime(for: self) ?? Constants.UI.Search.debounceDueTime
    }
}

extension TweakContext {
    func shouldRememberLastTweakList() -> Bool {
        delegate?.shouldRememberLastTweakList(for: self) ?? true
    }
}
