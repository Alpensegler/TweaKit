//
//  TweakPrimaryViewTextField.swift
//  TweaKit
//
//  Created by cokile
//

import UIKit

final class TweakPrimaryViewTextField: TweakTextField {
    private weak var tweak: AnyTweak?
    private var startingText: String?

    override init(frame: CGRect) {
        super.init(frame: frame)
        _setupUI()
        _setupEditing()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TweakPrimaryViewTextField: TweakPrimaryView {
    static let reuseID = "tweak-text-view"

    var reuseID: String {
        Self.reuseID
    }

    func reload(withTweak tweak: AnyTweak, manually: Bool) -> Bool {
        guard let value = tweak.currentValue as? String else { return false }
        self.tweak = tweak
        _reloadInteraction(withTweak: tweak)
        return _reloadText(withText: value)
    }

    func reset() {
        tweak = nil
        startingText = nil
    }

    func _reloadInteraction(withTweak tweak: AnyTweak) {
        isUserInteractionEnabled = tweak.isUserInteractionEnabled
        alpha = isUserInteractionEnabled ? 1 : Constants.UI.PrimaryView.disableAlpha
    }

    func _reloadText(withText newText: String) -> Bool {
        let oldText = startingText
        startingText = newText
        text = newText
        return oldText != newText
    }
}

extension TweakPrimaryViewTextField: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        resignFirstResponder()
        return true
    }
}

private extension TweakPrimaryViewTextField {
    @objc func _beginEditing(_ sender: TweakPrimaryViewTextField) {
        startingText = sender.actualText
    }

    @objc func _endEditing(_ sender: TweakPrimaryViewTextField) {
        let actualText = sender.actualText
        guard let tweak = tweak, actualText != startingText else { return }
        updateTweak(tweak, withValue: actualText, manually: true)
    }
}

private extension TweakPrimaryViewTextField {
    func _setupUI() {
        delegate = self
        textAlignment = .right
        returnKeyType = .done
        tintColor = Constants.Color.actionBlue
        textColor = Constants.Color.labelPrimary
        font = Constants.UI.PrimaryView.textFont
        attributedPlaceholder = NSAttributedString(string: "Tap to edit", attributes: [
            .foregroundColor: Constants.Color.labelSecondary,
            .font: font!,
        ])
    }

    func _setupEditing() {
        addTarget(self, action: #selector(_beginEditing), for: .editingDidBegin)
        addTarget(self, action: #selector(_endEditing), for: .editingDidEnd)
    }
}
