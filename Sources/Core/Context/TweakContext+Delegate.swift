//
//  TweakContext+Delegate.swift
//  TweaKit
//
//  Created by cokile
//

import Foundation
import CoreGraphics

public protocol TweakContextDelegate: AnyObject {
    // Trade
    func tradeSources(for context: TweakContext) -> [TweakTradeSource]
    func tradeDestinations(for context: TweakContext) -> [TweakTradeDestination]
    
    // Search
    func shouldFuzzySearch(for context: TweakContext) -> Bool
    func shouldSmartcaseSearch(for context: TweakContext) -> Bool
    func shouldCaseSensitiveSearch(for context: TweakContext) -> Bool
    func maxSearchHistoryCount(for context: TweakContext) -> Int
    func searchDebounceDueTime(for context: TweakContext) -> TimeInterval
    
    // UI
    func willShowTweakWindow(for context: TweakContext)
    func didShowTweakWindow(for context: TweakContext)
    func willDismissTweakWindow(for context: TweakContext)
    func didDismissTweakWindow(for context: TweakContext)
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
