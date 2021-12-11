//
//  Matcher+Tests.swift
//  TweaKit
//
//  Created by cokile
//

import XCTest
@testable import TweaKit

class MatcherTests: XCTestCase {
    func testEmptyKeywordSearch() {
        let trials: [SearchTrail] = [
            ("", false, false, false, false),
            ("", true, false, false, false),
            ("", false, true, false, false),
            ("", true, true, false, false),
            ("", false, false, true, false),
            ("", true, false, true, false),
            ("", false, true, true, false),
            ("", true, true, true, false),
        ]
        for trial in trials {
            let result = Matcher.match(haystack: haystack, with: trial.needle, isFuzzy: trial.isFuzzy, isSmartcase: trial.isSmartcase, isCaseSensitive: trial.isCaseSensitive)
            XCTAssertEqual(result.isMatched, trial.matched)
        }
    }
    
    func testMatchCaseSearch() {
        let trials: [SearchTrail] = [
            ("AbC", false, false, false, true),
            ("AbC", true, false, false, true),
            ("AbC", false, true, false, true),
            ("AbC", true, true, false, true),
            ("AbC", false, false, true, true),
            ("AbC", true, false, true, true),
            ("AbC", false, true, true, true),
            ("AbC", true, true, true, true),
        ]
        for trial in trials {
            let result = Matcher.match(haystack: haystack, with: trial.needle, isFuzzy: trial.isFuzzy, isSmartcase: trial.isSmartcase, isCaseSensitive: trial.isCaseSensitive)
            XCTAssertEqual(result.isMatched, trial.matched)
        }
    }
    
    func testLowerCaseSearch() {
        let trials: [SearchTrail] = [
            ("abc", false, false, false, true),
            ("abc", true, false, false, true),
            ("abc", false, true, false, true),
            ("abc", true, true, false, true),
            ("abc", false, false, true, false),
            ("abc", true, false, true, false),
            ("abc", false, true, true, false),
            ("abc", true, true, true, false),
        ]
        for trial in trials {
            let result = Matcher.match(haystack: haystack, with: trial.needle, isFuzzy: trial.isFuzzy, isSmartcase: trial.isSmartcase, isCaseSensitive: trial.isCaseSensitive)
            XCTAssertEqual(result.isMatched, trial.matched)
        }
    }
    
    func testUpperCaseSearch() {
        let trials: [SearchTrail] = [
            ("ABC", false, false, false, true),
            ("ABC", true, false, false, true),
            ("ABC", false, true, false, false),
            ("ABC", true, true, false, false),
            ("ABC", false, false, true, false),
            ("ABC", true, false, true, false),
            ("ABC", false, true, true, false),
            ("ABC", true, true, true, false),
        ]
        for trial in trials {
            let result = Matcher.match(haystack: haystack, with: trial.needle, isFuzzy: trial.isFuzzy, isSmartcase: trial.isSmartcase, isCaseSensitive: trial.isCaseSensitive)
            XCTAssertEqual(result.isMatched, trial.matched)
        }
    }
    
    func testMixedCaseSearch() {
        let trials: [SearchTrail] = [
            ("abC", false, false, false, true),
            ("abC", true, false, false, true),
            ("abC", false, true, false, false),
            ("abC", true, true, false, false),
            ("abC", false, false, true, false),
            ("abC", true, false, true, false),
            ("abC", false, true, true, false),
            ("abC", true, true, true, false),
        ]
        for trial in trials {
            let result = Matcher.match(haystack: haystack, with: trial.needle, isFuzzy: trial.isFuzzy, isSmartcase: trial.isSmartcase, isCaseSensitive: trial.isCaseSensitive)
            XCTAssertEqual(result.isMatched, trial.matched)
        }
    }
    
    func testFuzzySearch() {
        let trials: [SearchTrail] = [
            ("Ab1", false, false, false, false),
            ("Ab1", true, false, false, true),
            ("Ab1", false, true, false, false),
            ("Ab1", true, true, false, true),
            ("Ab1", false, false, true, false),
            ("Ab1", true, false, true, true),
            ("Ab1", false, true, true, false),
            ("Ab1", true, true, true, true),
            
            ("CG3", false, false, false, false),
            ("CG3", true, false, false, true),
            ("CG3", false, true, false, false),
            ("CG3", true, true, false, true),
            ("CG3", false, false, true, false),
            ("CG3", true, false, true, true),
            ("CG3", false, true, true, false),
            ("CG3", true, true, true, true),
        ]
        for trial in trials {
            let result = Matcher.match(haystack: haystack, with: trial.needle, isFuzzy: trial.isFuzzy, isSmartcase: trial.isSmartcase, isCaseSensitive: trial.isCaseSensitive)
            XCTAssertEqual(result.isMatched, trial.matched)
        }
    }
    
    func testDiacriticMarks() {
        let haystack = "AbcDé"
        
        let trials: [(needle: String, isCaseSensitive: Bool, matched: Bool)] = [
            ("e", true, true),
            ("e", false, true),
            ("E", true, false),
            ("E", false, true),
            
            ("é", true, true),
            ("é", false, true),
            ("É", true, false),
            ("É", false, true),

            ("ē", true, true),
            ("ē", false, true),
            ("Ē", true, false),
            ("Ē", false, true),
        ]
        for trial in trials {
            let result = Matcher.match(haystack: haystack, with: trial.needle, isFuzzy: true, isSmartcase: false, isCaseSensitive: trial.isCaseSensitive)
            XCTAssertEqual(result.isMatched, trial.matched)
        }
    }
    
    func testPerformance() {
        measure {
            _ = Matcher.match(haystack: "A Sample Tweak Section", with: "se", isFuzzy: true, isSmartcase: true, isCaseSensitive: false)
        }
    }
}

private extension MatcherTests {
    var haystack: String { "AbCdEfG 1234567" }
    
    typealias SearchTrail = (needle: String, isFuzzy: Bool, isSmartcase: Bool, isCaseSensitive: Bool, matched: Bool)
}
