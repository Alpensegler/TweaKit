//
//  TweakPrimaryViewPlaceholder.swift
//  TweaKit
//
//  Created by cokile
//

import UIKit

final class TweakPrimaryViewPlaceholder: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        _setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TweakPrimaryViewPlaceholder: TweakPrimaryView {
    static let reuseID = "tweak-placeholder"

    var reuseID: String {
        Self.reuseID
    }

    func reload(withTweak tweak: AnyTweak, manually: Bool) -> Bool {
        _reloadInteraction(withTweak: tweak)
        return _reloadText(withTweak: tweak)
    }

    private func _reloadInteraction(withTweak tweak: AnyTweak) {
        alpha = tweak.isUserInteractionEnabled ? 1 : Constants.UI.PrimaryView.disableAlpha
    }

    private func _reloadText(withTweak tweak: AnyTweak) -> Bool {
        let oldText = text
        text = String(describing: tweak.currentValue)
        return oldText != text
    }
}

private extension TweakPrimaryViewPlaceholder {
    func _setupUI() {
        textColor = Constants.Color.labelSecondary
        font = Constants.UI.PrimaryView.textFont
        adjustsFontSizeToFitWidth = true
        minimumScaleFactor = 0.5
    }
}
