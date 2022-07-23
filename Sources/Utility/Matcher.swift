//
//  Matcher.swift
//  TweaKit
//
//  Created by cokile
//

// swiftlint:disable line_length
/*
 The Matcher implementation is a modification base on objc.io:
 https://www.objc.io/blog/2020/08/18/fuzzy-search/
 https://github.com/objcio/S01E214-quick-open-from-recursion-to-loops

 MIT License
 
 Copyright (c) 2019 objc.io
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
// swiftlint:enable line_length

import Foundation

enum Matcher {
    static func match(haystack: String, with needle: String, isFuzzy: Bool, isSmartcase: Bool, isCaseSensitive: Bool) -> Result {
        guard _validate(haystack: haystack, needle: needle) else { return .notMatched }
        let (haystack, needle) = _normalize(haystack: haystack, needle: needle, isFuzzy: isFuzzy, isSmartcase: isSmartcase, isCaseSensitive: isCaseSensitive)
        if isFuzzy {
            return _fuzzyMatch(haystack: haystack, needle: needle)
        } else {
            return _exactMatch(haystack: haystack, needle: needle)
        }
    }
}

private extension Matcher {
    static let locale = Locale(identifier: "en_US_POSIX")

    static func _validate(haystack: String, needle: String) -> Bool {
        !haystack.isEmpty && !needle.isEmpty
    }

    static func _normalize(haystack: String, needle: String, isFuzzy: Bool, isSmartcase: Bool, isCaseSensitive: Bool) -> (haystack: String, needle: String) {
        var haystack = haystack
        var needle = needle

        if isCaseSensitive || (isSmartcase && needle.contains(where: { $0.isUppercase })) {
            haystack = haystack.folding(options: [.widthInsensitive, .diacriticInsensitive], locale: locale)
            needle = needle.folding(options: [.widthInsensitive, .diacriticInsensitive], locale: locale)
        } else {
            haystack = haystack.folding(options: [.caseInsensitive, .widthInsensitive, .diacriticInsensitive], locale: locale).lowercased(with: locale)
            needle = needle.folding(options: [.caseInsensitive, .widthInsensitive, .diacriticInsensitive], locale: locale).lowercased(with: locale)
        }
        return (haystack, needle)
    }

    static func _exactMatch(haystack: String, needle: String) -> Result {
        haystack.contains(needle) ? .exactMatched : .notMatched
    }

    static func _fuzzyMatch(haystack: String, needle: String) -> Result {
        let haystackCount = haystack.count
        let needleCount = needle.count

        if haystackCount < needleCount {
            return .notMatched
        }

        if haystack == needle {
            return .exactMatched
        }

        let matrix = ScoreMatrix(width: haystackCount, height: needleCount)
        for (row, needleChar) in needle.enumerated() {
            var didMatch = false

            let previousMatchIndex: Int
            if row == 0 {
                previousMatchIndex = -1
            } else {
                previousMatchIndex = matrix[row: row - 1].firstIndex { $0 != nil }!
            }
            // for optimization:
            // 1. drop haystack chars that firstly matches previous needle char to reduce iteration since these chars won't match current needle char
            // 2. Use wrapping integer arithmetic
            for (column, haystackChar) in haystack.enumerated().dropFirst(previousMatchIndex + 1) {
                guard needleChar == haystackChar else { continue }
                didMatch = true
                var score: Score = 1
                if row > 0 {
                    var maxScore = Score.min
                    for prevColumn in 0..<column {
                        guard let score = matrix[prevColumn, row - 1] else { continue }
                        let gapPenalty = Score(column &- prevColumn &- 1)
                        maxScore = max(maxScore, score &- gapPenalty)
                    }
                    score &+= maxScore
                }
                matrix[column, row] = score
            }
            guard didMatch else { return .notMatched }
        }

        return matrix[row: needleCount - 1]
            .compactMap { $0 }
            .max()
            .map { Result(score: $0, isMatched: true) }
        ?? .notMatched
    }
}

extension Matcher {
    typealias Score = Int16

    struct Result {
        let score: Score
        let isMatched: Bool

        static let notMatched = Result(score: .min, isMatched: false)
        static let exactMatched = Result(score: .max, isMatched: true)
    }
}

private extension Matcher {
    final class ScoreMatrix {
        let width: Int
        let height: Int
        private var storage: [Score?]

        init(width: Int, height: Int) {
            self.width = width
            self.height = height
            self.storage = .init(repeating: nil, count: width * height)
        }

        subscript(column: Int, row: Int) -> Score? {
            get { storage[row * width + column] }
            set { storage[row * width + column] = newValue }
        }

        subscript(row row: Int) -> [Score?] {
            Array(storage[row * width..<(row + 1) * width])
        }
    }
}
