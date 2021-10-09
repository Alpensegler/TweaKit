//
//  TweakListViewHeader.swift
//  TweaKit
//
//  Created by cokile
//

import UIKit

protocol TweakListSectionHeaderDelegate: AnyObject {
    var headerHostViewController: UIViewController { get }
    
    func sectionHeader(_ header: TweakListSectionHeader, titleForSection section: Int) -> String
    func sectionHeader(_ header: TweakListSectionHeader, tweaksForSection section: Int) -> [AnyTweak]
    func sectionHeader(_ header: TweakListSectionHeader, contextForSection section: Int) -> TweakContext
    func sectionHeader(_ header: TweakListSectionHeader, didActivateFloatingForSection section: Int)
}

final class TweakListSectionHeader: UITableViewHeaderFooterView {
    private lazy var background = _background()
    private lazy var nameLabel = _nameLabel()
    private lazy var floatButton = _floatButton()
    private lazy var moreButton = _moreButton()
    
    private var section: Int?
    private weak var delegate: TweakListSectionHeaderDelegate?
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        _setupUI()
        _layoutUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TweakListSectionHeader {
    func configWith(delegate: TweakListSectionHeaderDelegate, section: Int) {
        self.delegate = delegate
        self.section = section
        _configLabelWith(delegate: delegate, section: section)
    }
}

extension TweakListSectionHeader {
    override func layoutSubviews() {
        super.layoutSubviews()
        _calibrateShadow()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        _toggleShadow()
    }
}

private extension TweakListSectionHeader {
    func _setupUI() {
        contentView.backgroundColor = .clear
        contentView.addSubview(background)
        background.addSubview(nameLabel)
        contentView.addSubview(floatButton)
        contentView.addSubview(moreButton)
    }
    
    func _layoutUI() {
        contentView.autoresizingMask = []
        contentView.clipsToBounds = true
        background.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        floatButton.translatesAutoresizingMaskIntoConstraints = false
        moreButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            background.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.UI.ListView.verticalPadding),
            background.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            background.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.UI.ListView.horizontalPadding),
            background.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.UI.ListView.horizontalPadding),
            nameLabel.topAnchor.constraint(equalTo: background.topAnchor, constant: 17),
            nameLabel.bottomAnchor.constraint(equalTo: background.bottomAnchor, constant: -17),
            nameLabel.leadingAnchor.constraint(equalTo: background.leadingAnchor, constant: Constants.UI.ListView.contentLeading),
            moreButton.leadingAnchor.constraint(greaterThanOrEqualTo: nameLabel.trailingAnchor, constant: 20),
            moreButton.centerYAnchor.constraint(equalTo: background.centerYAnchor),
            floatButton.leadingAnchor.constraint(equalTo: moreButton.trailingAnchor, constant: 24),
            floatButton.centerYAnchor.constraint(equalTo: background.centerYAnchor),
            floatButton.trailingAnchor.constraint(equalTo: background.trailingAnchor, constant: -Constants.UI.ListView.contentLeading),
        ])
    }
    
    func _calibrateShadow() {
        // background.bounds is still zero even upon layoutSubviews invocation
        let backgroundBounds = CGRect(
            x: 0,
            y: 0,
            width: contentView.frame.width - 2 * Constants.UI.ListView.horizontalPadding,
            height: contentView.frame.height - Constants.UI.ListView.verticalPadding
        )
        let path = UIBezierPath(
            roundedRect: backgroundBounds,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: .init(width: background.layer.cornerRadius, height: background.layer.cornerRadius)
        )
        background.layer.shadowPath = path.cgPath
    }
    
    func _toggleShadow() {
        background.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
    }
}

private extension TweakListSectionHeader {
    func _configLabelWith(delegate: TweakListSectionHeaderDelegate, section: Int) {
        nameLabel.text = delegate.sectionHeader(self, titleForSection: section)
    }
}

private extension TweakListSectionHeader {
    @objc func _activateFloating(_ sender: UIButton) {
        guard let section = section else { return }
        delegate?.sectionHeader(self, didActivateFloatingForSection: section)
    }
    
    @objc private func _activateMoreOptions(_ gesture: UIButton) {
        let actions: [UIAlertAction] = [
            UIAlertAction(title: "Export Tweaks", style: .default) { [unowned self] _ in initiateExport() },
            UIAlertAction(title: "Reset Tweaks", style: .destructive) { [unowned self] _ in initiateReset() },
        ]
        UIAlertController.actionSheet(actions: actions, view: background, fromVC: delegate?.headerHostViewController)
    }
}

extension TweakListSectionHeader: TweakExportInitiator {
    var fromVC: UIViewController? {
        delegate?.headerHostViewController
    }
    
    var context: TweakContext? {
        guard let section = section else { return nil }
        return delegate?.sectionHeader(self, contextForSection: section)
    }
    
    var sender: UIView {
        background
    }
    
    var exportAlertTitle: String? {
        guard let section = section, let delegate = delegate else { return nil }
        return "Export \(delegate.sectionHeader(self, titleForSection: section)) To..."
    }
    
    var exportableTweaks: [AnyTradableTweak] {
        guard let section = section, let delegate = delegate else { return [] }
        return delegate.sectionHeader(self, tweaksForSection: section).compactMap { $0 as? AnyTradableTweak }
    }
}

extension TweakListSectionHeader: TweakResetInitiator {
    var resetAlertTitle: String? {
        guard let section = section, let delegate = delegate else { return nil }
        return "Reset \(delegate.sectionHeader(self, titleForSection: section))?"
    }
    
    var resetableTweaks: [AnyTweak] {
        guard let section = section, let delegate = delegate else { return [] }
        return delegate.sectionHeader(self, tweaksForSection: section)
    }
}

private extension TweakListSectionHeader {
    func _background() -> UIView {
        let v = UIView()
        v.backgroundColor = Constants.Color.backgroundElevatedPrimary
        v.layer.addCorner(radius: Constants.UI.ListView.cornerRadius, mask: .top)
        v.layer.addShadow(color: Constants.UI.ListView.shadowColor, y: Constants.UI.ListView.shadowY, radius: Constants.UI.ListView.shadowRadius)
        return v
    }
    
    func _nameLabel() -> UILabel {
        let l = UILabel()
        l.numberOfLines = 0
        l.font = .systemFont(ofSize: 17, weight: .bold)
        l.textColor = Constants.Color.labelPrimary
        return l
    }
    
    func _floatButton() -> UIButton {
        let b = HitOutsideButton(type: .system)
        b.extendInset = .init(inset: -11)
        b.setImage(Constants.Assets.floatButton, for: .normal)
        b.addTarget(self, action: #selector(_activateFloating), for: .touchUpInside)
        return b
    }
    
    func _moreButton() -> UIButton {
        let b = HitOutsideButton(type: .system)
        b.extendInset = .init(inset: -11)
        b.setImage(Constants.Assets.naviMore, for: .normal)
        b.addTarget(self, action: #selector(_activateMoreOptions), for: .touchUpInside)
        return b
    }
}
