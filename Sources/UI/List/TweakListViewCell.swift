//
//  TweakListViewCell.swift
//  TweaKit
//
//  Created by cokile
//

import UIKit

protocol TweakListViewCellDelegate: AnyObject {
    var cellHostViewController: UIViewController { get }
    var primaryViewRecycler: TweakPrimaryViewRecycler { get }
    
    func tweakListViewCellNeedsLayout(_ cell: TweakListViewCell)
}

final class TweakListViewCell: UITableViewCell {
    private lazy var bottomBackground = _bottomBackground()
    private lazy var topBackground = _topBackground()
    private lazy var highlightBackground = _highlightBackground()
    private lazy var nameLabel = _nameLabel()
    private lazy var icon = _icon()
    private lazy var primaryViewContainer = _primaryViewContainer()
    
    private var topBackgroundBottomConstraint: NSLayoutConstraint?
    private let topBackgroundBaseBottomPadding: CGFloat = 10
    
    private unowned var tweak: AnyTweak!
    private unowned var delegate: TweakListViewCellDelegate!
    private var isLast = false
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        _setupUI()
        _layoutUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TweakListViewCell {
    var iconFrame: CGRect {
        topBackground.convert(icon.frame, to: contentView)
    }
    
    func config(with tweak: AnyTweak, isLast: Bool, scene: TweakListViewScene, delegate: TweakListViewCellDelegate) {
        self.tweak = tweak
        self.isLast = isLast
        self.delegate = delegate
        _configIconWith(tweak: tweak)
        _configLabelWith(tweak: tweak)
        _configBGWith(tweak: tweak, isLast: isLast, scene: scene)
        _configPrimaryViewContainerWith(tweak: tweak)
        _setNeedsRelayout()
    }
    
    func handleSelection(for tweak: AnyTweak) {
        _handleSelection(for: tweak)
    }
}

extension TweakListViewCell {
    override func layoutSubviews() {
        super.layoutSubviews()
        _calibrateUI()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        _toggleShadow()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        _recyclePrimaryView()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        guard _checkCanManuallyHighlight() else { return }
        _setHighlight(selected, animated: animated)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        guard _checkCanManuallyHighlight() else { return }
        _setHighlight(highlighted, animated: animated)
    }
}

private extension TweakListViewCell {
    func _setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.clipsToBounds = true
        contentView.addSubview(bottomBackground)
        contentView.addSubview(topBackground)
        topBackground.addSubview(highlightBackground)
        topBackground.addSubview(icon)
        topBackground.addSubview(nameLabel)
        topBackground.addSubview(primaryViewContainer)
    }
    
    func _layoutUI() {
        let nameVerticalPadding: CGFloat = 19
        let contentPadding: CGFloat = 20
        topBackground.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        icon.translatesAutoresizingMaskIntoConstraints = false
        primaryViewContainer.translatesAutoresizingMaskIntoConstraints = false
        topBackgroundBottomConstraint = topBackground.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        icon.setContentHuggingPriority(.required, for: .horizontal)
        icon.setContentCompressionResistancePriority(.required, for: .horizontal)
        primaryViewContainer.setContentHuggingPriority(nameLabel.contentHuggingPriority(for: .horizontal) + 1, for: .horizontal)
        primaryViewContainer.setContentCompressionResistancePriority(nameLabel.contentCompressionResistancePriority(for: .horizontal) + 1, for: .horizontal)
        NSLayoutConstraint.activate([
            topBackground.topAnchor.constraint(equalTo: contentView.topAnchor),
            topBackgroundBottomConstraint!,
            topBackground.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.UI.ListView.horizontalPadding),
            topBackground.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.UI.ListView.horizontalPadding),
            icon.leadingAnchor.constraint(equalTo: topBackground.leadingAnchor, constant: Constants.UI.ListView.contentLeading),
            icon.centerYAnchor.constraint(equalTo: topBackground.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: Constants.UI.ListView.iconSize),
            icon.heightAnchor.constraint(equalToConstant: Constants.UI.ListView.iconSize),
            nameLabel.topAnchor.constraint(equalTo: topBackground.topAnchor, constant: nameVerticalPadding),
            nameLabel.bottomAnchor.constraint(equalTo: topBackground.bottomAnchor, constant: -nameVerticalPadding),
            nameLabel.leadingAnchor.constraint(equalTo: topBackground.leadingAnchor, constant: Constants.UI.ListView.contentLeading + Constants.UI.ListView.iconSize + 8),
            nameLabel.widthAnchor.constraint(greaterThanOrEqualTo: topBackground.widthAnchor, multiplier: 0.2),
            primaryViewContainer.leadingAnchor.constraint(greaterThanOrEqualTo: nameLabel.trailingAnchor, constant: contentPadding),
            primaryViewContainer.trailingAnchor.constraint(equalTo: topBackground.trailingAnchor, constant: -Constants.UI.ListView.contentLeading),
            primaryViewContainer.centerYAnchor.constraint(equalTo: topBackground.centerYAnchor),
            primaryViewContainer.heightAnchor.constraint(lessThanOrEqualToConstant: Constants.UI.ListView.iconSize),
            primaryViewContainer.widthAnchor.constraint(greaterThanOrEqualToConstant: 12),
        ])
    }
    
    func _calibrateUI() {
        bottomBackground.frame = .init(
            x: Constants.UI.ListView.horizontalPadding,
            y: 0,
            width: contentView.frame.width - Constants.UI.ListView.horizontalPadding * 2,
            height: contentView.frame.height - Constants.UI.ListView.verticalPadding * (isLast ? 1 : 0)
        )
        if isLast {
            let path = UIBezierPath(
                roundedRect: bottomBackground.bounds,
                byRoundingCorners: [.bottomLeft, .bottomRight],
                cornerRadii: .init(width: bottomBackground.layer.cornerRadius, height: bottomBackground.layer.cornerRadius)
            )
            bottomBackground.layer.shadowPath = path.cgPath
        } else {
            bottomBackground.layer.shadowPath = UIBezierPath(rect: bottomBackground.bounds).cgPath
        }
        
        highlightBackground.frame.size = .init(
            width: bottomBackground.frame.width,
            height: bottomBackground.frame.height - topBackgroundBaseBottomPadding
        )
    }
    
    func _toggleShadow() {
        bottomBackground.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
    }
}

private extension TweakListViewCell {
    func _configIconWith(tweak: AnyTweak) {
        icon.backgroundColor = Constants.UI.shapeColor(of: tweak)
        icon.image = Constants.UI.shapeImage(of: tweak)
    }
    
    func _configLabelWith(tweak: AnyTweak) {
        nameLabel.text = tweak.name
    }
    
    func _configBGWith(tweak: AnyTweak, isLast: Bool, scene: TweakListViewScene) {
        bottomBackground.layer.cornerRadius = isLast ? Constants.UI.ListView.cornerRadius : 0
        bottomBackground.isHidden = scene.isFloating
        
        let paddingFactor: CGFloat = isLast ? 1 : 0
        topBackgroundBottomConstraint?.constant = -topBackgroundBaseBottomPadding - Constants.UI.ListView.verticalPadding * paddingFactor
    }
    
    func _configPrimaryViewContainerWith(tweak: AnyTweak) {
        primaryViewContainer.reloadWith(tweak: tweak, recycler: delegate.primaryViewRecycler)
    }
    
    func _setNeedsRelayout() {
        setNeedsUpdateConstraints()
        setNeedsLayout()
    }
    
    func _recyclePrimaryView() {
        primaryViewContainer.recycle(by: delegate.primaryViewRecycler)
    }
    
    func _checkCanManuallyHighlight() -> Bool {
        tweak.isUserInteractionEnabled && tweak.hasSecondaryView
    }
    
    func _setHighlight(_ flag: Bool, animated: Bool) {
        guard tweak.isUserInteractionEnabled else { return }
        
        if animated {
            UIView.animate(withDuration: 0.25, delay: 0, options: .beginFromCurrentState, animations: { [unowned self] in
                highlightBackground.alpha = flag ? 0.1 : 0
            })
        } else {
            highlightBackground.alpha = flag ? 0.1 : 0
        }
    }
}

private extension TweakListViewCell {
    @objc func _handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        _setHighlight(false, animated: false)
        _showLongPressOptions()
    }
    
    func _showLongPressOptions() {
        let actions: [UIAlertAction] = [
            UIAlertAction(title: "Export Tweak", style: .default) { [unowned self] _ in initiateExport() },
            UIAlertAction(title: "Reset Tweak", style: .destructive) { [unowned self] _ in initiateReset() },
        ]
        UIAlertController.actionSheet(actions: actions, view: topBackground, fromVC: delegate.cellHostViewController)
    }
    
    func _handleSelection(for tweak: AnyTweak) {
        guard tweak.isUserInteractionEnabled else { return }
        _showSecondaryView(for: tweak)
    }
    
    func _showSecondaryView(for tweak: AnyTweak) {
        guard tweak.hasSecondaryView, let secondaryView = tweak.secondaryView else { return }
        let container = TweakSecondaryViewContainer(tweak: tweak, secondaryView: secondaryView)
        delegate.cellHostViewController.present(container, animated: true)
    }
}

extension TweakListViewCell: TweakPrimaryViewContainerDelegate {
    func primaryViewContainerNeedsLayout(_ container: TweakPrimaryViewContainer) {
        if isHidden || window == nil { return }
        // recalculate label size to make sure row height is correct
        nameLabel.invalidateIntrinsicContentSize()
        delegate.tweakListViewCellNeedsLayout(self)
    }
}

extension TweakListViewCell: TweakExportInitiator {
    var fromVC: UIViewController? {
        delegate.cellHostViewController
    }
    
    var context: TweakContext? {
        tweak.context
    }
    
    var sender: UIView {
        topBackground
    }
    
    var exportAlertTitle: String? {
        "Export \(tweak.name) To..."
    }
    
    var exportableTweaks: [AnyTradableTweak] {
        guard let tweak = tweak as? AnyTradableTweak else { return [] }
        return [tweak]
    }
}

extension TweakListViewCell: TweakResetInitiator {
    var resetAlertTitle: String? {
        "Reset \(tweak.name)?"
    }
    
    var resetableTweaks: [AnyTweak] {
        [tweak]
    }
}

private extension TweakListViewCell {
    func _bottomBackground() -> UIView {
        let v = UIView()
        v.backgroundColor = Constants.Color.backgroundElevatedPrimary
        v.layer.maskedCorners = .bottom
        v.layer.addShadow(color: Constants.UI.ListView.shadowColor, y: Constants.UI.ListView.shadowY, radius: Constants.UI.ListView.shadowRadius)
        return v
    }
    
    func _topBackground() -> UIView {
        let v = UIView()
        v.backgroundColor = Constants.Color.backgroundElevatedSecondary
        // we do not use context menu interaction since it will conflict with highlight
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(_handleLongPress))
        longPress.minimumPressDuration = 0.7
        v.addGestureRecognizer(longPress)
        return v
    }
    
    func _highlightBackground() -> UIView {
        let v = UIView()
        v.isUserInteractionEnabled = false
        v.backgroundColor = Constants.Color.actionBlue
        v.alpha = 0
        return v
    }
    
    func _nameLabel() -> UILabel {
        let l = UILabel()
        l.numberOfLines = 0
        l.textAlignment = .left
        l.font = .systemFont(ofSize: 16)
        l.textColor = Constants.Color.labelPrimary
        return l
    }
    
    func _icon() -> UIImageView {
        let iv = UIImageView()
        iv.contentMode = .center
        iv.layer.addCorner(radius: Constants.UI.ListView.iconCornerRadius)
        return iv
    }
    
    func _primaryViewContainer() -> TweakPrimaryViewContainer {
        let v = TweakPrimaryViewContainer(delegate: self)
        return v
    }
}
