//
//  ResultBuilder.swift
//  TweaKit
//
//  Created by cokile
//

import Foundation

public protocol TweakBuildable {
    var constrainKey: String { get }
    
    func hasBuilt() -> Bool
}

@resultBuilder
public struct TweakContainerBuilder<T: TweakBuildable> {
    public static func buildBlock(_ buildables: T...) -> [T] {
        buildables
            .uniqued { $0.constrainKey == $1.constrainKey }
            .filter { !$0.hasBuilt() }
            .sorted { $0.constrainKey < $1.constrainKey }
    }
}

// A Duplication of TweakContainerBuilder for AnyTweak since AnyTweak does not conform to TweakBuildable
@resultBuilder
public struct AnyTweakBuilder {
    public static func buildBlock(_ tweaks: AnyTweak...) -> [AnyTweak] {
        tweaks
            .uniqued { $0.name == $1.name }
            .filter { $0.section == nil }
            .sorted { $0.name < $1.name }
    }
}
