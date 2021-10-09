//
//  TweakListEmptyView.swift
//  TweaKit
//
//  Created by cokile
//

import UIKit

final class TweakListEmptyView: UIView {
    private lazy var imageView = _imageView()
    private lazy var label = _label()
    
    init(image: UIImage, text: String? = nil) {
        super.init(frame: .zero)
        _setupUI(image: image, text: text)
        _layoutUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        _layoutUI()
    }
}

extension TweakListEmptyView {
    func setText(text: String) {
        label.text = text
        setNeedsLayout()
    }
}

private extension TweakListEmptyView {
    func _setupUI(image: UIImage, text: String?) {
        addSubview(imageView)
        addSubview(label)
        imageView.image = image
        imageView.sizeToFit()
        label.text = text
    }
    
    func _layoutUI() {
        imageView.center.x = frame.midX
        imageView.frame.origin.y = UIApplication.tk_shared.isLandscape ? 16 : 56
        label.center.x = frame.midX
        label.frame.origin.y = imageView.frame.maxY + 1
        label.frame.size.width = frame.width * 0.5
        label.frame.size.height = label.font.lineHeight + 3
    }
}

private extension TweakListEmptyView {
    func _imageView() -> UIImageView {
        let iv = UIImageView()
        return iv
    }
    
    func _label() -> UILabel {
        let l = UILabel()
        l.font = .systemFont(ofSize: 16)
        l.textColor = Constants.Color.labelSecondary
        l.textAlignment = .center
        return l
    }
}
