//
//  TweaKit.swift
//  TweaKit
//
//  Created by cokile
//

import Foundation

/// A simple type to log interpolated string messages.
///
/// `Logger` itself is simply a namespace.
public enum Logger {
    /// Specify the approach that how the message will be logged.
    ///
    /// The default approach is using the `print` method to print the message to the console.
    public static var log: (String) -> Void = { message in
        print(message)
    }

    /// log message.
    ///
    /// - Parameters:
    ///   - message: the message to be logged.
    ///   - file: The file name to log with message. The default is the file where `log(_:,file:,function:,line:)` is called.
    ///   - function: The function name to log with message. The default is the function where `log(_:,file:,function:,line:)` is called.
    ///   - line: The line number to log with message. The default is the line number where `log(_:,file:,function:,line:)` is called.
    static func log(_ message: () -> String, file: StaticString = #file, function: StaticString = #function, line: Int = #line) {
        log("[TweaKit] [\(file): \(function) - \(line)] ".appending(message()))
    }
}

public extension Notification.Name {
    /// A notification that posts shortly before the tweak window show.
    ///
    /// The `object` of the notification is the `TweakContext` object. There is no `userInfo` dictionary.
    static let willShowTweakWindow = Notification.Name("TweaKit.willShowTweakWindow")

    /// A notification that posts shortly after the tweak window show.
    ///
    /// The `object` of the notification is the `TweakContext` object. There is no `userInfo` dictionary.
    static let didShowTweakWindow = Notification.Name("TweaKit.didShowTweakWindow")

    /// A notification that posts shortly before the tweak window dismiss.
    ///
    /// The `object` of the notification is the `TweakContext` object. There is no `userInfo` dictionary.
    static let willDismissTweakWindow = Notification.Name("TweaKit.willDismissTweakWindow")

    /// A notification that posts shortly after the tweak window dismiss.
    ///
    /// The `object` of the notification is the `TweakContext` object. There is no `userInfo` dictionary.
    static let didDismissTweakWindow = Notification.Name("TweaKit.didDismissTweakWindow")
}
