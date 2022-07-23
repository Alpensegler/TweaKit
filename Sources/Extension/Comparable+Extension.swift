//
//  Comparable+Extension.swift
//  TweaKit
//
//  Created by cokile
//

import Foundation

extension Comparable {
    func clamped(from: Self, to: Self) -> Self {
        assert(from <= to, "clamp from: \(from) is larger than to: \(to)")

        return max(from, min(self, to))
    }
}
