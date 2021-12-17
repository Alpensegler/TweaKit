//
//  TweakPrimaryViewSwitcher.swift
//  TweaKit
//
//  Created by cokile
//

import UIKit

final class TweakPrimaryViewSwitcher: UISwitch {
    private lazy var tapView = _tapView()
    
    private weak var tweak: AnyTweak?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        _setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TweakPrimaryViewSwitcher {
    override func layoutSubviews() {
        super.layoutSubviews()
        _layoutUI()
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
        setOn(isOn, animated: manually)
    }
}

private extension TweakPrimaryViewSwitcher {
    func _setupUI() {
        onTintColor = Constants.Color.actionBlue
        
        addSubview(tapView)
    }
    
    func _layoutUI() {
        tapView.frame = bounds
    }
    
    @objc func _handleTap(_ gesture: UITapGestureRecognizer) {
        guard gesture.state == .ended, let tweak = tweak else { return }
        updateTweak(tweak, withValue: !isOn, manually: true)
    }
}

private extension TweakPrimaryViewSwitcher {
    func _tapView() -> UIView {
        let v = UIView()
        // interacting with a overlay view rather than interacting with the switcher directly to prevent redundant update
        v.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(_handleTap)))
        return v
    }
}
