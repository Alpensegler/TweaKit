//
//  TweakPrimaryViewStrider.swift
//  TweaKit
//
//  Created by cokile
//

import UIKit

public protocol TweakPrimaryViewStrideable: Storable, Comparable, Numeric {
    var needDecimalPoint: Bool { get }
    
    func needSign(between min: Self, and max: Self) -> Bool
    func substracting(by amount: Self) -> Self
    func adding(by amount: Self) -> Self
    
    func toText() -> String?
    static func fromText(_ text: String) -> Self?
}

final class TweakPrimaryViewStrider<Value: TweakPrimaryViewStrideable>: HitOutsideView {
    private weak var tweak: AnyTweak?
    private var value: Value?
    private var strider: Strider?
    
    private lazy var substractButton = _subtractButton()
    private lazy var addButton = _addButton()
    private lazy var textField = _textField()
    private lazy var textFieldBackground = _textFieldBackground()
    
    override var intrinsicContentSize: CGSize {
        .init(width: 114, height: 26)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        _layoutUI()
    }
    
    @objc func _subtract(_ sender: UIButton) {
        guard let value = value, let stride = strider?.stride else { return }
        _updateValue(value.substracting(by: stride))
    }
    
    @objc func _add(_ sender: UIButton) {
        guard let value = value, let stride = strider?.stride else { return }
        _updateValue(value.adding(by: stride))
    }
    
    @objc func _prependSign(_ sender: UIBarButtonItem) {
        _prependSign()
    }
    
    @objc func _endEditing(_ sender: UIBarButtonItem) {
        _endEditing()
    }
}

extension TweakPrimaryViewStrider: TweakPrimaryView {
    static var reuseID: String {
        "tweak-strider-\(Value.self)"
    }
    
    var reuseID: String {
        Self.reuseID
    }
    
    func reload(withTweak tweak: AnyTweak, manually: Bool) -> Bool {
        guard let tweak = tweak as? NumberedTweak<Value> else { return false }
        guard let value = tweak.currentValue as? Value, value != self.value else { return false }
        let strider = Strider(min: tweak.from, max: tweak.to, stride: tweak.stride)
        self.tweak = tweak
        self.value = value
        self.strider = strider
        _reloadTextWith(tweak: tweak, value: value, strider: strider, manually: manually)
        _reloadSubstractButtonWith(tweak: tweak, value: value, strider: strider)
        _reloadAddButtonWith(tweak: tweak, value: value, strider: strider)
        return false
    }
    
    func reset() {
        tweak = nil
        value = nil
        strider = nil
    }
    
    private func _reloadTextWith(tweak: AnyTweak, value: Value, strider: Strider, manually: Bool) {
        let isEnabled = tweak.isUserInteractionEnabled
        textField.isUserInteractionEnabled = isEnabled
        textField.textColor = isEnabled
            ? Constants.Color.labelPrimary
            : Constants.Color.labelPrimary.withAlphaComponent(0.5)
        textField.keyboardType = value.needDecimalPoint ? .decimalPad : .numberPad
        textField.text = value.toText()
        if !manually || textField.inputAccessoryView == nil {
            textField.addItems(_inputItems(for: value))
        }
    }
    
    private func _reloadSubstractButtonWith(tweak: AnyTweak, value: Value, strider: Strider) {
        let isEnabled = tweak.isUserInteractionEnabled && value != strider.min
        substractButton.isEnabled = isEnabled
        substractButton.alpha = isEnabled ? 1 : Constants.UI.PrimaryView.disableAlpha
    }
    
    private func _reloadAddButtonWith(tweak: AnyTweak, value: Value, strider: Strider) {
        let isEnabled = tweak.isUserInteractionEnabled && value != strider.max
        addButton.isEnabled = isEnabled
        addButton.alpha = isEnabled ? 1 : Constants.UI.PrimaryView.disableAlpha
    }
}

private extension TweakPrimaryViewStrider {
    func _setupUI() {
        extendInset = .init(inset: -15)
        addSubview(substractButton)
        addSubview(addButton)
        addSubview(textFieldBackground)
        addSubview(textField)
    }
    
    func _layoutUI() {
        substractButton.frame.origin = .init(x: 0, y: (frame.height - substractButton.frame.height).half)
        textField.frame.origin = .init(x: substractButton.frame.maxX + 11, y: (frame.height - textField.frame.height).half)
        addButton.frame.origin = .init(x: textField.frame.maxX + 11, y: (frame.height - addButton.frame.height).half)
        textFieldBackground.frame = textField.frame
    }
}

private extension TweakPrimaryViewStrider {
    func _updateValue(_ value: Value) {
        guard let tweak = tweak, let strider = strider else { return }
        if self.value == value { return }
        Haptic.occur(.impact())
        updateTweak(tweak, withValue: value.clamped(from: strider.min, to: strider.max), manually: true)
    }
    
    func _inputItems(for value: Value) -> [UIBarButtonItem] {
        var items: [UIBarButtonItem] = .init(capacity: 3)
        if let strider = strider, value.needSign(between: strider.min, and: strider.max) {
            items.append(UIBarButtonItem(image: Constants.Assets.substract, style: .plain, target: self, action: #selector(_prependSign(_:))))
        }
        items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
        items.append(UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(_endEditing(_:))))
        return items
    }
    
    func _prependSign() {
        if textField.actualText.hasPrefix("-") { return }
        let selectedRange = textField.selectedTextRange
        textField.text = "-".appending(textField.actualText)
        guard let range = selectedRange,
            let start = textField.position(from: range.start, offset: 1),
            let end = textField.position(from: range.end, offset: 1)
        else { return }
        textField.selectedTextRange = textField.textRange(from: start, to: end)
    }
    
    func _endEditing() {
        textField.resignFirstResponder()
    }
}

private extension TweakPrimaryViewStrider {
    func _textField() -> TextField {
        let tf = TextField(frame: .init(x: 0, y: 0, width: 64, height: 26))
        tf.keyboardType = .decimalPad
        tf.backgroundColor = .clear
        tf.tintColor = Constants.Color.actionBlue
        tf.textAlignment = .center
        tf.font = .systemFont(ofSize: 14)
        tf.adjustsFontSizeToFitWidth = true
        tf.minimumFontSize = 7
        // set clipsToBounds since textRect/editingRect exceed bounds
        // there is a separated view to show background color and rounded corner to avoid off-screen rendering
        tf.clipsToBounds = true
        tf.canCommitText = { [unowned self] text in
            guard let value = Value.fromText(text), let strider = strider else { return false }
            return strider.min <= value && value <= strider.max
            
        }
        tf.commitText = { [unowned self] text in
            guard let value = Value.fromText(text) else { return }
            _updateValue(value)
        }
        return tf
    }
    
    func _textFieldBackground() -> UIView {
        let v = UIView()
        v.isUserInteractionEnabled = false
        v.backgroundColor = UIColor(light: UIColor(hexString: "F2F2F7")!, dark: UIColor(hexString: "101010")!)
        v.layer.addCorner(radius: 4)
        return v
    }
    
    func _subtractButton() -> UIButton {
        let button = HitOutsideButton(type: .system)
        button.frame.size = .init(width: 14, height: 14)
        button.extendInset = .init(inset: -15)
        button.tintColor = Constants.Color.labelPrimary
        button.setImage(Constants.Assets.substract, for: .normal)
        button.addTarget(self, action: #selector(_subtract), for: .touchUpInside)
        return button
    }
    
    func _addButton() -> UIButton {
        let button = HitOutsideButton(type: .system)
        button.frame.size = .init(width: 14, height: 14)
        button.extendInset = .init(inset: -15)
        button.tintColor = Constants.Color.labelPrimary
        button.setImage(Constants.Assets.add, for: .normal)
        button.addTarget(self, action: #selector(_add), for: .touchUpInside)
        return button
    }
}

private extension TweakPrimaryViewStrider {
    private struct Strider {
        let min: Value
        let max: Value
        let stride: Value
    }
}

private final class TextField: TweakValidatedTextField {
    // setting adjustsFontSizeToFitWidth to true will add spacing around text
    // -6 is value after multiple trails (remember to change this value when changing the width of text field)
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.insetBy(dx: -6, dy: 0)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        bounds.insetBy(dx: -6, dy: 0)
    }
}
