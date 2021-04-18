//
//  Tweaks.swift
//  TweaKit-Demo
//  Created by cokile
//
//

import UIKit
import TweaKit

enum Tweaks {
    @Tweak<CGFloat>(name: "Line Width", defaultValue: 1, from: 0.5, to: 2, stride: 0.05)
    static var sketchLineWidth
    @Tweak(name: "Line Color", defaultValue: UIColor(red: 0.227, green: 0.529, blue: 0.992, alpha: 1))
    static var sketchLineColor
    @Tweak(name: "Order", defaultValue: SketchAction.allCases)
    static var sketchActionsOrder
    @Tweak(name: "Name", defaultValue: "My Sketch")
    static var sketchName
    
    @Tweak(name: "Navigation Title", defaultValue: "Demo", options: ["Demo", "Example", "Guide"])
    static var rootViewNavigationTitle
    @Tweak(name: "Shake To Show Tweaks", defaultValue: true)
    static var rootViewEnableShake
    
    @Tweak(name: "App Icon", defaultValue: AppIcon.primary)
    static var appIcon
    
    private static let delegate = Delegate()
    static let context = TweakContext(delegate: delegate) {
        TweakList("Sketch") {
            TweakSection("Line") {
                $sketchLineWidth
                $sketchLineColor
            }
            TweakSection("Info") {
                $sketchName
            }
            TweakSection("Actions") {
                $sketchActionsOrder
            }
        }
        TweakList("Root View") {
            TweakSection("UI") {
                $rootViewNavigationTitle
            }
            TweakSection("Interaction") {
                $rootViewEnableShake
            }
        }
        TweakList("App") {
            TweakSection("Setting") {
                $appIcon
            }
        }
    }
}

private extension Tweaks {
    final class Delegate: TweakContextDelegate {
        func tradeSources(for context: TweakContext) -> [TweakTradeSource] {
            [
                TweakTradeFileSource(name: "Sample Tweaks", filePath: Bundle.main.path(forResource: "tweaks", ofType: "json")!)
            ]
        }
    }
}
