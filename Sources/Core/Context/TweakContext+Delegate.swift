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
    func shouldSmartCaseSerch(for context: TweakContext) -> Bool
    func shouldCaseSensitiveSearch(for context: TweakContext) -> Bool
    func maxSearchHistoryCount(for context: TweakContext) -> Int
    func searchDebounceDueTime(for context: TweakContext) -> TimeInterval
    
    // UI
    func shouldRememberLastTweakList(for context: TweakContext) -> Bool
}

public extension TweakContextDelegate {
    func tradeSources(for context: TweakContext) -> [TweakTradeSource] { [] }
    func tradeDestinations(for context: TweakContext) -> [TweakTradeDestination] { [] }
}

public extension TweakContextDelegate {
    func shouldFuzzySearch(for context: TweakContext) -> Bool { true }
    func shouldSmartCaseSerch(for context: TweakContext) -> Bool { true }
    func shouldCaseSensitiveSearch(for context: TweakContext) -> Bool { false }
    func maxSearchHistoryCount(for context: TweakContext) -> Int { Constants.UI.Search.maxHistotyCount }
    func searchDebounceDueTime(for context: TweakContext) -> TimeInterval { Constants.UI.Search.debounceDueTime }
}

public extension TweakContextDelegate {
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
    
    func shouldSmartCaseSerch() -> Bool {
        delegate?.shouldSmartCaseSerch(for: self) ?? true
    }
    
    func shouldCaseSensitiveSearch() -> Bool {
        delegate?.shouldCaseSensitiveSearch(for: self) ?? false
    }
    
    func maxSearchHistoryCount() -> Int {
        delegate?.maxSearchHistoryCount(for: self) ?? Constants.UI.Search.maxHistotyCount
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
