//
//  TweakWindow.swift
//  TweaKit
//
//  Created by cokile
//

import UIKit

final class TweakWindow: UIWindow {
    private unowned let context: TweakContext
    private(set) var isFloating = false
    
    init(context: TweakContext, locateAt tweak: AnyTweak?) {
        self.context = context
        super.init(frame: UIScreen.main.bounds)
        windowLevel = UIWindow.Level.statusBar + 100
        backgroundColor = Constants.UI.windowBackgroundColor
        rootViewController = UINavigationController(rootViewController: TweakRootViewController(context: context, locateAt: tweak))
        
        Self._setupOnce()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TweakWindow {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        return view === self ? nil : view
    }
}

extension TweakWindow {
    func show(completion: @escaping () -> Void) {
        NotificationCenter.default.post(name: .willShowTweakWindow, object: self.context)
        let animation = CABasicAnimation(keyPath: "transform.translation.y", fromValue: bounds.height, toValue: 0)
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            self.isHidden = false
            self.layer.removeAllAnimations()
            NotificationCenter.default.post(name: .didShowTweakWindow, object: self.context)
            completion()
        }
        isHidden = false
        layer.add(animation, forKey: "show")
        CATransaction.commit()
    }
    
    func dismiss(completion: @escaping () -> Void) {
        NotificationCenter.default.post(name: .willDismissTweakWindow, object: self.context)
        let animation = CABasicAnimation(keyPath: "transform.translation.y", fromValue: 0, toValue: bounds.height)
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            self.layer.removeAllAnimations()
            self.isHidden = true
            NotificationCenter.default.post(name: .didDismissTweakWindow, object: self.context)
            completion()
        }
        layer.add(animation, forKey: "dismiss")
        CATransaction.commit()
    }
}

extension TweakWindow {
    func markIsFloating(_ flag: Bool) {
        if isFloating == flag { return }
        isFloating = flag
        _setNeedsUpdateStatusBarAppearance()
    }
}

private extension TweakWindow {
    static var didSetup = false
    
    static func _setupOnce() {
        dispatchPrecondition(condition: .onQueue(.main))
        if didSetup { return }
        didSetup = true
        
        _setupStatusBar()
    }
    
    static func _setupStatusBar() {
        // workaround for to
        let selector = NSSelectorFromString(_decodeText("^b`m@eedbsRs`strA`q@ood`q`mbd", shift: 1))
        guard let method = class_getInstanceMethod(self, #selector(_takeoverStatusBarAppearance)) else { return }
        let imp = method_getImplementation(method)
        class_addMethod(self, selector, imp, method_getTypeEncoding(method))
    }
    
    static func _decodeText(_ text: String, shift: Int) -> String {
        var result = ""
        for c in text.unicodeScalars {
            result.append(Character(UnicodeScalar(UInt32(Int(c.value) + shift))!))
        }
        return result
    }
}

private extension TweakWindow {
    @objc func _takeoverStatusBarAppearance() -> Bool {
        !isFloating
    }
    
    func _setNeedsUpdateStatusBarAppearance() {
        rootViewController?.setNeedsStatusBarAppearanceUpdate()
    }
}

extension Constants.UI {
    static let windowBackgroundColor = UIColor.black
}
