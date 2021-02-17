//
//  TweakPrimaryViewRecycler.swift
//  TweaKit
//
//  Created by cokile
//

import UIKit

final class TweakPrimaryViewRecycler {
    private var pool: [String: Set<TweakPrimaryViewBox>] = [:] // key: TweakPrimaryView.reuseID
}

extension TweakPrimaryViewRecycler {
    func enqueue(_ view: TweakPrimaryView) {
        DispatchQueue.ensureInMain()
        
        view.prepareForReuse()
        pool[view.reuseID, default: []].insert(.init(view: view))
    }
    
    func dequeue(withReuseID reuseID: String) -> TweakPrimaryView? {
        DispatchQueue.ensureInMain()
        
        if var views = pool[reuseID] {
            if views.isEmpty {
                pool.removeValue(forKey: reuseID)
                return nil
            } else {
                let view = views.removeFirst().view
                if views.isEmpty {
                    pool.removeValue(forKey: reuseID)
                } else {
                    pool[reuseID] = views
                }
                return view
            }
        } else {
            return nil
        }
    }
}

private extension TweakPrimaryViewRecycler {
    final class TweakPrimaryViewBox: Hashable {
        let view: TweakPrimaryView
        
        init(view: TweakPrimaryView) {
            self.view = view
        }
        
        static func == (lhs: TweakPrimaryViewBox, rhs: TweakPrimaryViewBox) -> Bool {
            lhs.view === rhs.view
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(view.hash)
        }
    }
}
