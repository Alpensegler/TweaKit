//
//  TweakPrimaryViewDisclosurer.swift
//  TweaKit
//
//  Created by cokile
//

import UIKit

/// A primary view that simply displays the tweak value and a disclosure arrow.
public final class TweakPrimaryViewDisclosurer: UIView {
    private lazy var label = _label()
    private lazy var imageView = _imageView()
    
    private var detailConverter: ((AnyTweak) -> String?)?
    
    convenience init(detailConverter: ((AnyTweak) -> String?)? = nil) {
        self.init(frame: .zero)
        self.detailConverter = detailConverter
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        _setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
 
public extension TweakPrimaryViewDisclosurer {
    override var intrinsicContentSize: CGSize {
        let labelSize = label.intrinsicContentSize
        let imageSize = imageView.intrinsicContentSize
        return .init(
            width: labelSize.width + imageSize.width + padding,
            height: max(labelSize.height, imageSize.height)
        )
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        _layoutUI()
    }
}

extension TweakPrimaryViewDisclosurer: TweakPrimaryView {
    public static let reuseID = "tweak-disclosurer"
    
    public var reuseID: String {
        Self.reuseID
    }
    
    public func reload(withTweak tweak: AnyTweak, manually: Bool) -> Bool {
        _reloadInteraction(withTweak: tweak)
        let textReloaded = _reloadText(withTweak: tweak)
        let imageReloaded = _reloadImage(withTweak: tweak)
        if textReloaded || imageReloaded {
            _resize()
            return true
        } else {
            return false
        }
    }
    
    private func _reloadInteraction(withTweak tweak: AnyTweak) {
        alpha = tweak.isUserInteractionEnabled ? 1 : Constants.UI.PrimaryView.disableAlpha
    }
    
    private func _reloadText(withTweak tweak: AnyTweak) -> Bool {
        let oldText = label.text
        label.text = detailConverter?(tweak) ?? ""
        return oldText != label.text
    }
    
    private func _reloadImage(withTweak tweak: AnyTweak) -> Bool {
        let hasImage = imageView.image != nil
        if !hasImage {
            imageView.image = Constants.Assets.disclosure
            imageView.sizeToFit()
        }
        return !hasImage
    }
    
    private func _resize() {
        invalidateIntrinsicContentSize()
        setNeedsLayout()
    }
}

private extension TweakPrimaryViewDisclosurer {
    var padding: CGFloat {
        (label.text == nil || label.text!.isEmpty) ? 0 : 9
    }
    
    func _setupUI() {
        addSubview(label)
        addSubview(imageView)
    }
    
    func _layoutUI() {
        imageView.frame.origin = .init(
            x: frame.width - imageView.frame.width,
            y: (frame.height - imageView.frame.height).half
        )
        label.frame.size = .init(
            width: imageView.frame.minX - padding,
            height: frame.height
        )
    }
}

private extension TweakPrimaryViewDisclosurer {
    func _label() -> UILabel {
        let l = UILabel()
        l.textColor = Constants.Color.labelSecondary
        l.font = Constants.UI.PrimaryView.textFont
        l.adjustsFontSizeToFitWidth = true
        l.minimumScaleFactor = 0.5
        l.textAlignment = .right
        return l
    }
    
    func _imageView() -> UIImageView {
        let v = UIImageView()
        v.tintColor = Constants.Color.disclosure
        return v
    }
}
