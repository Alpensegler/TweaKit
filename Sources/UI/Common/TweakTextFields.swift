//
//  TweakTextFields.swift
//  TweaKit
//
//  Created by cokile
//

import UIKit

// MARK: - TweakTextField

class TweakTextField: UITextField {
    var actualText: String {
        text ?? ""
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        // disable look up and share
        if action == Selector(("_define:")) || action == Selector(("_share:")) {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
}

// MARK: - TweakValidatedTextField

class TweakValidatedTextField: TweakTextField {
    var inputTextTransformer: ((String) -> String?)?
    var canCommitText: ((String) -> Bool)?
    var commitText: ((String) -> Void)?

    private var startingText: String?

    override init(frame: CGRect) {
        super.init(frame: frame)

        delegate = self
        addTarget(self, action: #selector(_beginEditing), for: .editingDidBegin)
        addTarget(self, action: #selector(_endEditing), for: .editingDidEnd)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TweakValidatedTextField: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return false }
        guard let transformer = inputTextTransformer else { return true }

        // keep cursor location when set textField.text
        // https://stackoverflow.com/questions/26284271/format-uitextfield-text-without-having-cursor-move-to-the-end
        let beginning = textField.beginningOfDocument
        let cursorLocation = textField.position(from: beginning, offset: range.location + string.utf16.count)

        if let finalText = transformer((text as NSString).replacingCharacters(in: range, with: string)) {
            textField.text = finalText

            if let cursorLocation = cursorLocation {
                textField.selectedTextRange = textField.textRange(from: cursorLocation, to: cursorLocation)
            }
        }
        return false
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text, !text.isEmpty else { return false }
        let canCommit = canCommitText?(text) ?? true
        if canCommit {
            resignFirstResponder()
        }
        return canCommit
    }
}

private extension TweakValidatedTextField {
    @objc func _beginEditing(_ sender: TweakValidatedTextField) {
        startingText = sender.text
    }

    @objc func _endEditing(_ sender: TweakValidatedTextField) {
        guard let canCommitText = canCommitText else { return }
        // if final text is the same as starting text, there is no need to commit
        guard sender.actualText != startingText else { return }
        if canCommitText(sender.actualText) {
            commitText?(sender.actualText)
        } else {
            sender.text = startingText
        }
    }
}

extension UITextField {
    func addItems(_ items: [UIBarButtonItem]) {
        // specify a frame that can have enough space to hold done button to suppress the auto layout constraints warning:
        // https://stackoverflow.com/a/61725757/4155933
        let toolBar = UIToolbar(frame: .init(x: 0, y: 0, width: 100, height: 44))
        toolBar.items = items
        toolBar.sizeToFit()
        inputAccessoryView = toolBar
    }
}
