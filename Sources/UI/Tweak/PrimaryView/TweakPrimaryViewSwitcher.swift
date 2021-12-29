//
//  TweakPrimaryViewSwitcher.swift
//  TweaKit
//
//  Created by cokile
//

import UIKit

final class TweakPrimaryViewSwitcher: UISwitch {
    private weak var tweak: AnyTweak?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        _setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TweakPrimaryViewSwitcher: TweakPrimaryView {
    public static let reuseID = "tweak-switcher"
    
    public var reuseID: String {
        Self.reuseID
    }
    
    public func reload(withTweak tweak: AnyTweak, manually: Bool) -> Bool {
        guard let isOn = tweak.currentValue as? Bool else { return false }
        self.tweak = tweak
        _reloadInteraction(withTweak: tweak)
        _reloadSwitch(isOn: isOn, manually: manually)
        return false
    }
    
    func reset() {
        tweak = nil
    }
    
    private func _reloadInteraction(withTweak tweak: AnyTweak) {
        isEnabled = tweak.isUserInteractionEnabled
    }
    
    private func _reloadSwitch(isOn: Bool, manually: Bool) {
        if self.isOn == isOn { return }
        setOn(isOn, animated: manually)
    }
}

private extension TweakPrimaryViewSwitcher {
    func _setupUI() {
        onTintColor = Constants.Color.actionBlue
        
        addTarget(self, action: #selector(_handleValueChange), for: .valueChanged)
    }
    
    @objc func _handleValueChange(_ sender: TweakPrimaryViewSwitcher) {
        guard let tweak = tweak else { return }
        updateTweak(tweak, withValue: isOn, manually: true)
    }
}
