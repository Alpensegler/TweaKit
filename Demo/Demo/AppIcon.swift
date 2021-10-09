//
//  AppIcon.swift
//  TweaKit-Demo
//  Created by cokile
//
//

import UIKit
import TweaKit

enum AppIcon: String, CaseIterable {
    case primary = "Default"
    case darkRazer = "Dark Razer"
}

extension AppIcon: Tweakable {
    var previewImage: UIImage {
        switch self {
        case .primary:
            return UIImage(named: "icon_app_icon_preview_primary")!
        case .darkRazer:
            return UIImage(named: "icon_app_icon_preview_dark_razer")!
        }
    }
    
    static var primaryViewReuseID: String {
        TweakPrimaryViewDisclosurer.reuseID
    }
    static var primaryView: TweakPrimaryView {
        TweakPrimaryViewDisclosurer()
    }
    static var hasSecondaryView: Bool {
        true
    }
    static var secondaryView: TweakSecondaryView? {
        AppIconSecondaryView()
    }
}

extension AppIcon {
    private var iconName: String? {
        switch self {
        case .primary: return nil
        case .darkRazer: return "AppIconDarkRazer"
        }
    }
    
    func apply() {
        // UIApplication.shared.supportsAlternateIcons should always return true since the deployment target is iOS 11.
        switch self {
        case .primary:
            if UIApplication.shared.alternateIconName == nil { break }
            UIApplication.shared.setAlternateIconName(nil)
        default:
            if UIApplication.shared.alternateIconName == iconName { break }
            UIApplication.shared.setAlternateIconName(iconName)
        }
    }
}

// MARK: - AppIconSecondaryView

private final class AppIconSecondaryView: UICollectionViewController, TweakSecondaryView {
    private var currentTweak: AnyTweak?
    private var selectedIcon: AppIcon?
    
    init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AppIconSecondaryView {
    override func viewDidLoad() {
        super.viewDidLoad()
        _setupUI()
    }
}

extension AppIconSecondaryView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        13
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        .init(width: floor((collectionView.frame.width - 2 * horizontalPadding - 13) * 0.5), height: 240)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        AppIcon.allCases.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! Cell
        let icon = AppIcon.allCases[indexPath.item]
        cell.configContent(icon: icon)
        cell.configIsSelected(selectedIcon == icon)
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? Cell else { return }
        cell.configIsSelected(selectedIcon == AppIcon.allCases[indexPath.item])
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let tweak = currentTweak else { return }
        updateTweak(tweak, withValue: AppIcon.allCases[indexPath.item], manually: true)
    }
}

extension AppIconSecondaryView {
    func reload(withTweak tweak: AnyTweak, manually: Bool) {
        guard let selectedIcon = tweak.currentValue as? AppIcon, self.selectedIcon != selectedIcon else { return }
        self.currentTweak = tweak
        self.selectedIcon = selectedIcon
        collectionView.reloadData()
    }
}

private extension AppIconSecondaryView {
    func _setupUI() {
        view.backgroundColor = .clear
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = .init(top: 44, left: horizontalPadding, bottom: collectionView.contentInset.bottom, right: horizontalPadding)
        collectionView.register( Cell.self, forCellWithReuseIdentifier: "cell")
    }
}

private extension AppIconSecondaryView {
    final class Cell: UICollectionViewCell {
        private lazy var iconImageView = _iconImageView()
        private lazy var nameLabel = _nameLabel()
        private lazy var tickImageView = _tickImageView()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            _setupUI()
            _layoutUI()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

extension AppIconSecondaryView.Cell {
    func configContent(icon: AppIcon) {
        iconImageView.image = icon.previewImage
        nameLabel.text = icon.rawValue
    }
    
    func configIsSelected(_ flag: Bool) {
        contentView.layer.borderWidth = flag ? 1 : 0
        contentView.backgroundColor = UIColor(named: flag ? "color_app_icon_background_selected" : "color_app_icon_background_normal")
        nameLabel.textColor = UIColor(named: flag ? "color_app_icon_label_selected" : "color_app_icon_label_normal")
        tickImageView.isHidden = !flag
    }
}

private extension AppIconSecondaryView.Cell {
    func _setupUI() {
        contentView.layer.borderColor = UIColor(named: "color_app_icon_label_selected")?.cgColor
        contentView.layer.cornerRadius = 20
        contentView.layer.cornerCurve = .continuous
        
        contentView.addSubview(iconImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(tickImageView)
    }
    
    func _layoutUI() {
        contentView.subviews.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        NSLayoutConstraint.activate([
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 28),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            iconImageView.bottomAnchor.constraint(equalTo: nameLabel.topAnchor, constant: -13),
            iconImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            tickImageView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 22),
            tickImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
        ])
    }
}

private extension AppIconSecondaryView.Cell {
    func _iconImageView() -> UIImageView {
        let v = UIImageView()
        return v
    }
    
    func _nameLabel() -> UILabel {
        let l = UILabel()
        l.textAlignment = .center
        l.font = .systemFont(ofSize: 18)
        l.minimumScaleFactor = 0.5
        return l
    }
    
    func _tickImageView() -> UIImageView {
        let v = UIImageView()
        v.image = UIImage(named: "icon_selected")
        return v
    }
}
