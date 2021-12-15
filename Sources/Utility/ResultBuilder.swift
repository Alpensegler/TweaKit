//
//  ResultBuilder.swift
//  TweaKit
//
//  Created by cokile
//

import Foundation

public protocol TweakBuildable {
    var constrainKey: String { get }
    var hasBuilt: Bool { get }
}

@resultBuilder
public struct TweakContainerBuilder<Element: TweakBuildable> {
    public typealias Expression = Element
    public typealias Component = [Element]
    
    public static func buildExpression(_ expression: Expression) -> Component {
        _build(component: [expression])
    }
    
    public static func buildBlock(_ components: Component...) -> Component {
        _build(component: components.flatMap { $0 })
    }
    
    public static func buildArray(_ components: [Component]) -> Component {
        _build(component: components.flatMap { $0 })
    }
    
    private static func _build(component: Component) -> Component {
        component
            .uniqued { $0.constrainKey == $1.constrainKey }
            .filter { !$0.hasBuilt }
            .sorted { $0.constrainKey < $1.constrainKey }
    }
}

// A Duplication of TweakContainerBuilder for AnyTweak since AnyTweak can not conform to TweakBuildable
@resultBuilder
public struct AnyTweakBuilder {
    public typealias Expression = AnyTweak
    public typealias Component = [AnyTweak]
    
    public static func buildExpression(_ expression: Expression) -> Component {
        _build(component: [expression])
    }
    
    public static func buildBlock(_ components: Component...) -> Component {
        _build(component: components.flatMap { $0 })
    }
    
    public static func buildArray(_ components: [Component]) -> Component {
        _build(component: components.flatMap { $0 })
    }
    
    private static func _build(component: Component) -> Component {
        component
            .uniqued { $0.name == $1.name }
            .filter { $0.section == nil }
            .sorted { $0.name < $1.name }
    }
}
