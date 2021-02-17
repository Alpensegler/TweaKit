//
//  Array+Extension.swift
//  TweaKit
//
//  Created by cokile
//

import Foundation

extension Array {
    init(capacity: Int) {
        self.init()
        reserveCapacity(capacity)
    }
}

extension Array {
    func uniqued(_ isSame: (Element, Element) -> Bool) -> [Element] {
        if isEmpty { return [] }
        if count == 1 { return self }
        
        var buffer: [Element] = .init(capacity: count)
        for one in self {
            if !buffer.contains(where: { another in isSame(one, another) }) {
                buffer.append(one)
            }
        }
        return buffer
    }
    
    func uniqued() -> [Element] where Element: Hashable {
        uniqued { $0.hashValue == $1.hashValue }
    }
    
    func uniqued() -> [Element] where Element: Equatable {
        uniqued { $0 == $1 }
    }
}
