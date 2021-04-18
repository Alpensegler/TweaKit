//
//  AppDelegate.swift
//  TweaKit-Demo
//  Created by cokile
//
//

// swiftlint:disable all

import UIKit
import TweaKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // make sure the cute stoat will stay on scceen for a little while
        // comment it if you can't wait to debuging
        Thread.sleep(forTimeInterval: 1)
        
        // trigger context init
        // you can put this line at any place just before using tweaks
        _ = Tweaks.context
        
        return true
    }
}
