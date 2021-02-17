//
//  TweakPrimaryViewColorPicker.swift
//  TweaKit
//
//  Created by cokile
//

import UIKit

public final class TweakPrimaryViewColorPicker: UIView {
    private lazy var label = _label()
    private lazy var colorView = _colorView()
    private lazy var labelSize = _labelSize(with: _label())

    public override init(frame: CGRect) {
        super.init(frame: frame)
        _setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
 
public extension TweakPrimaryViewColorPicker {
    override var intrinsicContentSize: CGSize {
        return .init(
            width: labelSize.width + colorView.frame.width + padding,
            height: max(labelSize.height, colorView.frame.height)
        )
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        _layoutUI()
    }
}

extension TweakPrimaryViewColorPicker: TweakPrimaryView {
    public static let reuseID = "tweak-color-picker"
    
    public var reuseID: String {
        Self.reuseID
    }
    
    public func reload(withTweak tweak: AnyTweak, manually: Bool) -> Bool {
        guard let color = tweak.currentValue as? UIColor else { return false }
        _reloadInteraction(withTweak: tweak)
        _reloadHex(withColor: color)
        _reloadColor(withColor: color)
        return false
    }
    
    private func _reloadInteraction(withTweak tweak: AnyTweak) {
        label.alpha = tweak.isUserInteractionEnabled ? 1 : Constants.UI.PrimaryView.disableAlpha
    }
    
    private func _reloadHex(withColor color: UIColor) {
        label.text = color.toRGBHexString(includeAlpha: false, includePrefix: true)
    }
    
    private func _reloadColor(withColor color: UIColor) {
        colorView.backgroundColor = color.withAlphaComponent(1)
    }
}

private extension TweakPrimaryViewColorPicker {
    var padding: CGFloat { 9 }
    
    func _setupUI() {
        addSubview(label)
        addSubview(colorView)
    }
    
    func _layoutUI() {
        colorView.frame.origin = .init(
            x: frame.width - colorView.frame.width,
            y: (frame.height - colorView.frame.height).half
        )
        label.frame.size = .init(
            width: colorView.frame.minX - padding,
            height: frame.height
        )
    }
}

private extension TweakPrimaryViewColorPicker {
    func _label() -> UILabel {
        let l = UILabel()
        l.textColor = Constants.Color.labelSecondary
        l.font = .systemFont(ofSize: 14)
        l.textAlignment = .right
        return l
    }
    
    func _colorView() -> UIView {
        let v = UIView(frame: .init(origin: .zero, size: .init(width: 22, height: 22)))
        v.isUserInteractionEnabled = false
        v.layer.addCorner(radius: 8)
        return v
    }
    
    func _labelSize(with label: UILabel) -> CGSize {
        // add two more characters to add some space, since font is not mono-spaced
        label.text = "#DDDDDDDD"
        label.sizeToFit()
        return label.frame.size
    }
}
