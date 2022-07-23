//
//  TweakSearcher+Tests.swift
//  TweaKitTests
//
//  Created by cokile
//

@testable import TweaKit
import XCTest

// swiftlint:disable weak_delegate

class TweakSearcherTests: XCTestCase, TweakSearcherDelegate {
    private let delegate = SearcherTestContextDelegate()
    private lazy var context = TweakContext(delegate: delegate) {
        TweakList("List") {
            TweakSection("Section") {
                Tweak(name: "ABC", default: 1)
                Tweak(name: "BCD", default: 1)
                Tweak(name: "CDE", default: 1)
                Tweak(name: "DEF", default: 1)
            }
        }
    }
    private lazy var searcher: TweakSearcher = {
        let searcher = TweakSearcher(context: context)
        searcher.delegate = self
        return searcher
    }()
    private(set) var currentKeyword: String?

    override func setUp() {
        super.setUp()
        currentKeyword = nil
        searcher.reset(unbind: true)
    }

    func testSearchInstantly() {
        var didShowLoading = false
        var tweakResults: [String] = []
        var searchingKeyword: String = ""
        searcher.bind { event in
            switch event {
            case .showLoading:
                didShowLoading = true
            case let .updateTweakResults(tweaks, keyword):
                tweakResults = tweaks.flatMap { $0.map(\.name) }
                searchingKeyword = keyword
            default:
                break
            }
        }

        didShowLoading = false
        tweakResults = ["PLACEHOLDER"]
        search(with: "BC", debounce: false)
        XCTAssertTrue(didShowLoading)
        XCTAssertEqual(tweakResults, ["ABC", "BCD"])
        XCTAssertEqual(searchingKeyword, "BC")

        didShowLoading = false
        tweakResults = ["PLACEHOLDER"]
        search(with: "XYZ", debounce: false)
        XCTAssertTrue(didShowLoading)
        XCTAssertTrue(tweakResults.isEmpty)
        XCTAssertEqual(searchingKeyword, "XYZ")
    }

    func testSearchDebounced() {
        let exp = XCTestExpectation(description: "debounced search")
        var didShowLoading = false
        var tweakResults: [String] = []
        searcher.bind { event in
            switch event {
            case .showLoading:
                didShowLoading = true
            case let .updateTweakResults(tweaks, keyword):
                tweakResults = tweaks.flatMap { $0.map(\.name) }
                XCTAssertTrue(didShowLoading)
                XCTAssertEqual(tweakResults, ["ABC", "BCD"])
                XCTAssertEqual(keyword, "BC")
                exp.fulfill()
            default:
                break
            }
        }

        search(with: "AB", debounce: true)
        search(with: "BC", debounce: true)
        XCTAssertTrue(didShowLoading)
        XCTAssertTrue(tweakResults.isEmpty)

        wait(for: [exp], timeout: debounceDueTime + 0.1)
    }

    func testSearchCancel() {
        let exp = XCTestExpectation(description: "cancel search")
        exp.isInverted = true
        searcher.bind { event in
            switch event {
            case .updateTweakResults:
                exp.fulfill()
            default:
                break
            }
        }

        search(with: "BC", debounce: true)
        searcher.cancel()
        wait(for: [exp], timeout: debounceDueTime * 4)
    }

    func testSearchHistoryRecordedForInstantSearch() {
        var historyResult: [String] = []
        searcher.bind { event in
            switch event {
            case .updateHistories(let histories):
                historyResult = histories
            default:
                break
            }
        }

        XCTAssertTrue(historyResult.isEmpty)
        search(with: "AB", debounce: false)
        XCTAssertEqual(historyResult, ["AB"])
        search(with: "BC", debounce: false)
        XCTAssertEqual(historyResult, ["BC", "AB"])
    }

    func testSearchHistoryRecordedForDebouncedSearch() {
        var historyResult: [String] = []
        let exp = XCTestExpectation(description: "search histories")
        exp.expectedFulfillmentCount = 2
        searcher.bind { event in
            switch event {
            case .updateHistories(let histories):
                historyResult = histories
            default:
                break
            }
        }

        search(with: "AB", debounce: true)
        search(with: "BC", debounce: true)
        XCTAssertTrue(historyResult.isEmpty)

        DispatchQueue.main.asyncAfter(deadline: .now() + debounceDueTime + 0.1) {
            XCTAssertEqual(historyResult, ["BC"])
            self.search(with: "CD", debounce: true)
            exp.fulfill()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + (debounceDueTime + 0.1) * 2) {
            XCTAssertEqual(historyResult, ["CD", "BC"])
            exp.fulfill()
        }

        wait(for: [exp], timeout: debounceDueTime * 5)
    }

    func testSearchHistoryOrderLatestFirst() {
        var historyResult: [String] = []
        searcher.bind { event in
            switch event {
            case .updateHistories(let histories):
                historyResult = histories
            default:
                break
            }
        }

        XCTAssertTrue(historyResult.isEmpty)
        search(with: "AB", debounce: false)
        XCTAssertEqual(historyResult, ["AB"])
        search(with: "BC", debounce: false)
        XCTAssertEqual(historyResult, ["BC", "AB"])
        search(with: "AB", debounce: false)
        XCTAssertEqual(historyResult, ["AB", "BC"])
    }

    func testSearchHistoryMaxCount() {
        var historyResult: [String] = []
        searcher.bind { event in
            switch event {
            case .updateHistories(let histories):
                historyResult = histories
            default:
                break
            }
        }

        XCTAssertTrue(historyResult.isEmpty)
        search(with: "AB", debounce: false)
        XCTAssertLessThanOrEqual(historyResult.count, historyMaxCount)
        XCTAssertEqual(historyResult, ["AB"])
        search(with: "BC", debounce: false)
        XCTAssertLessThanOrEqual(historyResult.count, historyMaxCount)
        XCTAssertEqual(historyResult, ["BC", "AB"])
        search(with: "CD", debounce: false)
        XCTAssertLessThanOrEqual(historyResult.count, historyMaxCount)
        XCTAssertEqual(historyResult, ["CD", "BC", "AB"])
        search(with: "DE", debounce: false)
        XCTAssertLessThanOrEqual(historyResult.count, historyMaxCount)
        XCTAssertEqual(historyResult, ["DE", "CD", "BC"])
        search(with: "EF", debounce: false)
        XCTAssertLessThanOrEqual(historyResult.count, historyMaxCount)
        XCTAssertEqual(historyResult, ["EF", "DE", "CD"])
    }
}

private extension TweakSearcherTests {
    func search(with keyword: String, debounce: Bool) {
        currentKeyword = keyword
        searcher.search(with: keyword, debounce: debounce)
    }
}

private let debounceDueTime: TimeInterval = 0.3
private let historyMaxCount: Int = 3

private class SearcherTestContextDelegate: TweakContextDelegate {
    func searchDebounceDueTime(for context: TweakContext) -> TimeInterval {
        debounceDueTime
    }

    func maxSearchHistoryCount(for context: TweakContext) -> Int {
        historyMaxCount
    }
}
