//
//  TweakListViewScene.swift
//  TweaKit
//
//  Created by cokile
//

import Foundation

enum TweakListViewScene {
    case list(name: String)
    case search(keyword: String)
    case floating
}

extension TweakListViewScene {
    var emptyView: TweakListEmptyView {
        switch self {
        case .list, .floating: return Constants.UI.tweakEmptyView
        case .search: return Constants.UI.tweakEmptyResultView
        }
    }
    
    var isFloating: Bool {
        switch self {
        case .list, .search: return false
        case .floating: return true
        }
    }
}
