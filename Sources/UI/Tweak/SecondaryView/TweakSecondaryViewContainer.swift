//
//  TweakSecondaryViewContainer.swift
//  TweaKit
//
//  Created by cokile
//

import UIKit

final class TweakSecondaryViewContainer: UIViewController {
    private unowned let tweak: AnyTweak
    private let secondaryView: TweakSecondaryView
    private var notifyToken: NotifyToken? {
        didSet { oldValue?.invalidate() }
    }
    
    private lazy var animator = TweakSecondaryViewAnimator(delegate: self)

    private lazy var titleLabel = _titleLabel()
    private lazy var resetButton = _resetButton()
    private lazy var dismissButton = _dismissButton()
    private lazy var hairline = _hairline()
    
    deinit {
        notifyToken?.invalidate()
    }
    
    init(tweak: AnyTweak, secondaryView: TweakSecondaryView) {
        self.tweak = tweak
        self.secondaryView = secondaryView
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TweakSecondaryViewContainer {
    override func viewDidLoad() {
        super.viewDidLoad()
        _setupBasicUI()
        _setupSecondaryView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        _layoutUI()
    }
    
    override var shouldAutorotate: Bool {
        false
    }
}

extension TweakSecondaryViewContainer: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator
    }
}

extension TweakSecondaryViewContainer: TweakSecondaryViewAnimatorDelegate {
    func animatorPortraitPresentTargetHeight(_ animator: TweakSecondaryViewAnimator) -> CGFloat {
        let topInset = Constants.UI.SecondaryView.titleHeight + Constants.UI.SecondaryView.hairlineHeight
        let bottomInset = UIApplication.tk_shared.keyWindow?.safeAreaInsets.bottom ?? 0
        let minHeight: CGFloat = 550
        let maxHeight = UIScreen.main.bounds.height - UIApplication.tk_shared.statusBarFrame.height - Constants.UI.SecondaryView.navigationBarHeight
        return (topInset + secondaryView.estimatedHeight + bottomInset).clamped(from: minHeight, to: maxHeight)
    }
    
    func animatorDidTapBlankArea(_ animator: TweakSecondaryViewAnimator) {
        _initiateDismiss()
    }
}

extension TweakSecondaryViewContainer: TweakResetInitiator {
    var fromVC: UIViewController? {
        self
    }
    
    var resetableTweaks: [AnyTweak] {
        [tweak]
    }
    
    var resetAlertTitle: String? {
        "Reset \(tweak.name)?"
    }
}

private extension TweakSecondaryViewContainer {
    func _setupBasicUI() {
        view.backgroundColor = Constants.Color.backgroundSecondary
        view.layer.addCorner(radius: 20, mask: .top)
        view.addSubview(titleLabel)
        view.addSubview(resetButton)
        view.addSubview(dismissButton)
        view.addSubview(hairline)
    }
    
    func _setupSecondaryView() {
        secondaryView.reload(withTweak: tweak, manually: false)
        addChildViewController(secondaryView)
        notifyToken = tweak.context?.store.startNotifying(forKey: tweak.id) { [weak self] _, _, manually in
            guard let self = self else { return }
            self.secondaryView.reload(withTweak: self.tweak, manually: manually)
        }
    }
    
    func _layoutUI() {
        resetButton.frame.origin = .init(
            x: secondaryView.horizontalPadding,
            y: (Constants.UI.SecondaryView.titleHeight - resetButton.frame.height).half
        )
        dismissButton.frame.origin = .init(
            x: view.bounds.width - secondaryView.horizontalPadding - dismissButton.frame.width,
            y: resetButton.frame.minY
        )
        titleLabel.frame = .init(
            x: resetButton.frame.maxX + secondaryView.horizontalPadding,
            y: 0,
            width: dismissButton.frame.minX - resetButton.frame.maxX - secondaryView.horizontalPadding * 2,
            height: Constants.UI.SecondaryView.titleHeight
        )
        hairline.frame = .init(
            x: secondaryView.horizontalPadding,
            y: titleLabel.frame.maxY,
            width: view.bounds.width - secondaryView.horizontalPadding * 2,
            height: Constants.UI.SecondaryView.hairlineHeight
        )
        secondaryView.view.frame = .init(
            x: 0,
            y: hairline.frame.maxY,
            width: view.bounds.width,
            height: view.bounds.height - hairline.frame.maxY
        )
    }
}

private extension TweakSecondaryViewContainer {
    @objc func _dismiss(_ sender: UIButton) {
        _initiateDismiss()
    }
    
    @objc func _reset(_ sender: UIButton) {
        _initiateReset()
    }
    
    func _initiateDismiss() {
        let view = secondaryView
        dismiss(animated: true) {
            view.removeFromParentController()
        }
    }
    
    func _initiateReset() {
        initiateReset()
    }
}

private extension TweakSecondaryViewContainer {
    func _titleLabel() -> UILabel {
        let l = UILabel()
        l.textAlignment = .center
        l.lineBreakMode = .byTruncatingMiddle
        l.textColor = Constants.Color.labelPrimary
        l.font = .systemFont(ofSize: 18, weight: .semibold)
        l.text = tweak.name
        l.sizeToFit()
        return l
    }
    
    func _resetButton() -> UIButton {
        let b = HitOutsideButton(type: .system)
        // A mimic of system destructive style color
        b.tintColor = UIColor(r: 255, g: 66, b: 57)
        b.setImage(Constants.Assets.resetTweaks, for: .normal)
        b.addTarget(self, action: #selector(_reset), for: .touchUpInside)
        b.extendInset = .init(inset: -11)
        b.sizeToFit()
        return b
    }
    
    func _dismissButton() -> UIButton {
        let b = HitOutsideButton(type: .system)
        b.tintColor = Constants.Color.actionBlue
        b.setImage(Constants.Assets.cross, for: .normal)
        b.addTarget(self, action: #selector(_dismiss), for: .touchUpInside)
        b.extendInset = .init(inset: -11)
        b.sizeToFit()
        return b
    }
    
    func _hairline() -> UIView {
        let v = UIView()
        v.backgroundColor = Constants.Color.seperator
        return v
    }
}

extension Constants.UI {
    enum SecondaryView {
        fileprivate static let titleHeight: CGFloat = 60
        fileprivate static let hairlineHeight: CGFloat = 1
        fileprivate static let navigationBarHeight: CGFloat = 44
        
        static let defaultEstimatedHeight: CGFloat = 455
        static let horizontalPadding: CGFloat = 17
    }
}
