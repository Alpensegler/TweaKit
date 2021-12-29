//
//  TweakSearcher.swift
//  TweaKit
//
//  Created by cokile
//

import UIKit

protocol TweakSearcherDelegate: AnyObject {
    var currentKeyword: String? { get }
}

final class TweakSearcher {
    weak var delegate: TweakSearcherDelegate?
    
    private let retriever: Retriever
    private let recorder: Recorder
    private let debouncer: Debouncer
    private var eventHandler: ((Event) -> Void)?
    
    deinit {
        _cancelSearch()
    }
    
    init(context: TweakContext) {
        retriever = .init(context: context)
        recorder = .init(context: context)
        debouncer = .init(context: context)
    }
}

extension TweakSearcher {
    func bootstrap(async: Bool) {
        let histories = _getCurrentHistories()
        if histories.isEmpty { return }
        
        let work = { [weak self] in
            self?._activateEvent(.showLoading)
            self?._activateEvent(.updateHistories(histories))
            self?._activateEvent(.showHistory)
        }
        
        if async {
            DispatchQueue.main.async(execute: work)
        } else {
            work()
        }
    }
    
    func deactivate() {
        _cancelSearch()
        _persistHistories()
    }
    
    func search(with keyword: String, debounce: Bool) {
        _cancelSearch()
        
        if keyword.isEmpty || keyword.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            _activateEvent(.showHistory)
            return
        }
        
        let job = { [weak self] in
            guard let self = self else { return }
            guard !debounce || self.delegate?.currentKeyword == keyword else {
                // different keywords means the job is for a legacy search, simply ignore it
                Logger.log("ignore legacy search with keyword: \(keyword), current keyword: \(String(describing: self.delegate?.currentKeyword))")
                return
            }
            self._activateEvent(.updateTweakResults(self._search(with: keyword), keyword))
            self._activateEvent(.showResult)
            self._activateEvent(.updateHistories(self._upsertingHistory(keyword)))
        }
        _activateEvent(.showLoading)
        if debounce {
            _debounceSearch(job: job)
        } else {
            job()
        }
    }
    
    func removeHistory(_ history: String) {
        _activateEvent(.updateHistories(_removingHistory(history)))
    }
    
    func cancel() {
        _cancelSearch()
    }
    
    func reset(unbind: Bool) {
        if unbind {
            _removeEventHandler()
        }
        _cancelSearch()
        _removeAllHistories()
    }
}

extension TweakSearcher {
    enum Event {
        case showLoading
        case showHistory
        case showResult
        
        case updateHistories([String])
        case updateTweakResults([[AnyTweak]], String)
    }
    
    func bind(eventHandler: @escaping (Event) -> Void) {
        self.eventHandler = eventHandler
    }
}

private extension TweakSearcher {
    func _search(with keyword: String) -> [[AnyTweak]] {
        retriever.retrieveTweaks(with: keyword)
    }
    
    func _debounceSearch(job: @escaping () -> Void) {
        debouncer.call(job: job)
    }
    
    func _cancelSearch() {
        debouncer.cancel()
    }
    
    func _upsertingHistory(_ history: String) -> [String] {
        recorder.upserting(history)
    }
    
    func _removingHistory(_ history: String) -> [String] {
        recorder.removing(history)
    }
    
    func _getCurrentHistories() -> [String] {
        recorder.getCurrentHistories()
    }
    
    func _removeAllHistories() {
        recorder.removeAllHistories()
    }
    
    func _persistHistories() {
        recorder.persistHistories()
    }
    
    func _activateEvent(_ event: Event) {
        eventHandler?(event)
    }
    
    func _removeEventHandler() {
        eventHandler = nil
    }
}

// MARK: - Retriever

private extension TweakSearcher {
    final class Retriever {
        private unowned let context: TweakContext
        
        init(context: TweakContext) {
            self.context = context
        }
    }
}

extension TweakSearcher.Retriever {
    func retrieveTweaks(with keyword: String) -> [[AnyTweak]] {
        let isFuzzy = context.shouldFuzzySearch()
        let isSmartcase = context.shouldSmartcaseSearch()
        let isCaseSensitive = context.shouldCaseSensitiveSearch()
        
        var sections: [String: Section] = [:]
        
        for tweak in context.tweaks {
            guard let sectionName = tweak.section?.name else { continue }
            
            // ignore list name since it has way less weight in search
            let sectionMatch = Matcher.match(haystack: sectionName, with: keyword, isFuzzy: isFuzzy, isSmartcase: isSmartcase, isCaseSensitive: isCaseSensitive)
            let tweakMatch = Matcher.match(haystack: tweak.name, with: keyword, isFuzzy: isFuzzy, isSmartcase: isSmartcase, isCaseSensitive: isCaseSensitive)
            guard sectionMatch.isMatched || tweakMatch.isMatched else { continue }
            
            let score = max(sectionMatch.score, tweakMatch.score)
            if let section = sections[sectionName] {
                section.add(tweak, score: score)
            } else {
                sections[sectionName] = .init(score: score, tweak: tweak)
            }
        }
        
        return sections.keys
            .sorted()
            .compactMap { sections[$0] }
            .sorted { $0.score > $1.score }
            .map { $0.tweaks }
    }
}

private extension TweakSearcher.Retriever {
    final class Section {
        private(set) var score: Matcher.Score
        private(set) var tweaks: [AnyTweak]
        
        init(score: Matcher.Score, tweak: AnyTweak) {
            self.score = score
            self.tweaks = [tweak]
        }
        
        func add(_ tweak: AnyTweak, score: Matcher.Score) {
            if score > self.score {
                self.score = score
            }
            tweaks.append(tweak)
        }
    }
}

// MARK: - Recorder

private extension TweakSearcher {
    final class Recorder {
        private let contextName: String
        private let maxCount: Int
        private var records: [String: [Record]] = [:]
        
        init(context: TweakContext) {
            self.contextName = context.name
            self.maxCount = context.delegate?.maxSearchHistoryCount(for: context) ?? Constants.UI.Search.maxHistoryCount
            _retrieveHistories()
        }
    }
}

extension TweakSearcher.Recorder {
    func upserting(_ history: String) -> [String] {
        _upsert(history)
        return _getHistories()
    }
    
    func removing(_ history: String) -> [String] {
        _remove(history)
        return _getHistories()
    }
    
    func getCurrentHistories() -> [String] {
        _getHistories()
    }
    
    func removeAllHistories() {
        _removeAllHistories()
    }
    
    func persistHistories() {
        _persistentHistories()
    }
    
    private func _upsert(_ history: String) {
        if history.isEmpty { return }
        if let records = records[contextName], let index = records.firstIndex(where: { $0.keyword == history }) {
            records[index].updatedAt = .init()
        } else {
            records[contextName, default: []].append(.init(keyword: history))
        }
    }
    
    private func _remove(_ history: String) {
        if history.isEmpty { return }
        records[contextName, default: []].removeAll { $0.keyword == history }
    }
    
    private func _getHistories() -> [String] {
        records[contextName, default: []]
            .sorted { $0.updatedAt > $1.updatedAt }
            .prefix(maxCount)
            .map(\.keyword)
    }
    
    private func _removeAllHistories() {
        records.removeValue(forKey: contextName)
    }
    
    private func _retrieveHistories() {
        guard let data = UserDefaults.standard.data(forKey: Constants.Keys.searchHistories) else { return }
        do {
            records = try JSONDecoder().decode([String: [Record]].self, from: data)
        } catch {
            Logger.log("failed to retrieve histories: \(error.localizedDescription)")
        }
    }
    
    private func _persistentHistories() {
        if records.isEmpty {
            UserDefaults.standard.removeObject(forKey: Constants.Keys.searchHistories)
            return
        }
        
        do {
            let data = try JSONEncoder().encode(records.mapValues { Array($0.prefix(maxCount)) })
            UserDefaults.standard.setValue(data, forKey: Constants.Keys.searchHistories)
        } catch {
            Logger.log("failed to persist histories: \(error.localizedDescription)")
        }
    }
}

private extension TweakSearcher.Recorder {
    final class Record: Codable {
        let keyword: String
        var updatedAt: Date
        
        init(keyword: String) {
            self.keyword = keyword
            updatedAt = .init()
        }
    }
}

// MARK: Debouncer

private extension Debouncer {
    convenience init(context: TweakContext) {
        self.init(dueTime: context.delegate?.searchDebounceDueTime(for: context) ?? Constants.UI.Search.debounceDueTime)
    }
}

extension Constants.UI {
    enum Search {
        static let maxHistoryCount = 10
        static let debounceDueTime: TimeInterval = 0.3
    }
}
