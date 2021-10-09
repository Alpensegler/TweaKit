//
//  TweaKit.swift
//  TweaKit
//
//  Created by cokile
//

import Foundation

public enum Logger {
    public static var log: (String) -> Void = { message in
        print(message)
    }
    
    static func log(_ message: () -> String, file: StaticString = #file, function: StaticString = #function, line: Int = #line) {
        log("[TweaKit] [\(file): \(function) - \(line)] ".appending(message()))
    }
}

public extension Notification.Name {
    static let willShowTweakWindow = Notification.Name("TweaKit.willShowTweakWindow")
    static let didShowTweakWindow = Notification.Name("TweaKit.didShowTweakWindow")
    static let willDismissTweakWindow = Notification.Name("TweaKit.willDismissTweakWindow")
    static let didDismissTweakWindow = Notification.Name("TweaKit.didDismissTweakWindow")
}
