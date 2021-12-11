//
//  TweakFloatingPanel.swift
//  TweaKit
//
//  Created by cokile
//

import UIKit

final class TweakFloatingPanel: UIViewController {
    private lazy var pan = _pan()
    private lazy var panIndicator = _panIndicator()
    private lazy var nameLabel = _nameLabel()
    private lazy var floatButton = _floatButton()
    private lazy var dismissButton = _dismissButton()
    private lazy var topCover = _topCover()
    private lazy var tweakListViewController = _tweakListViewController()
    
    private var snapshot: UIView?
    private var iconBackground: CALayer?
    private var iconImage: CALayer?
    
    private var tweaks: [AnyTweak] = []
    private var heightLevel: HeightLevel = .medium
    
    private unowned let context: TweakContext
    
    init(context: TweakContext) {
        self.context = context
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TweakFloatingPanel {
    override func viewDidLoad() {
        super.viewDidLoad()
        _setupUI()
        _calibrateUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        _layoutUI()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        _calibrateUI()
        _reposition()
    }
}

extension TweakFloatingPanel: TweakFloatingSecondaryParticipant {
    var category: TweakFloatingParticipantCategory { .panel }
    
    func prepareTransition(from category: TweakFloatingParticipantCategory) {
        guard category == .ball else { return }
        _beginAppearanceTransition(isAppear: true)
        _addToWindow()
    }
    
    func transit(from category: TweakFloatingParticipantCategory) {
        guard category == .ball else { return }
        _animateFromBall()
    }
    
    func completeTransition(from category: TweakFloatingParticipantCategory) {
        guard category == .ball else { return }
        _showAfterFromBall()
        _endAppearanceTransition()
    }
    
    func prepareTransition(to category: TweakFloatingParticipantCategory) {
        switch category {
        case .ball:
            _beginAppearanceTransition(isAppear: false)
            _fakeFloatingToBall()
        case .normalList, .searchList:
            _beginAppearanceTransition(isAppear: false)
        case .panel:
            break
        }
    }
    
    func transit(to category: TweakFloatingParticipantCategory) {
        switch category {
        case .ball:
            _beginFloatingToBall()
            _animateToBall()
        case .normalList, .searchList:
            _animateToList()
        case .panel:
            break
        }
    }
    
    func completeTransition(to category: TweakFloatingParticipantCategory) {
        switch category {
        case .ball:
            _endAppearanceTransition()
            _endFloatingToBall()
            removeFromWindow()
        case .normalList, .searchList:
            _endAppearanceTransition()
            removeFromWindow()
        case .panel:
            break
        }
    }
    
    func reload(withTweaks tweaks: [AnyTweak]) {
        self.tweaks = tweaks
        nameLabel.text = tweaks.first?.section?.name
        tweakListViewController.setTweaks([tweaks], in: context)
        view.setNeedsLayout()
    }
}

extension TweakFloatingPanel: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer === pan else { return true }
        guard _isListAtTop() else { return false }
        switch heightLevel {
        case .short:
            return pan.velocity(in: view).y < 0
        case .medium:
            return true
        case .tall:
            return pan.velocity(in: view).y > 0
        }
    }
}

private extension TweakFloatingPanel {
    func _setupUI() {
        view.backgroundColor = Constants.Color.backgroundElevatedPrimary
        view.frame = context.showingWindow.map { _frame(in: $0, heightLevel: heightLevel) } ?? .zero
        view.layer.addCorner(radius: Constants.UI.Floating.panelCornerRadius, mask: .top)
        view.layer.addShadow(color: UIColor.black.withAlphaComponent(0.1), y: -5, radius: 5)
        
        addChildViewController(tweakListViewController)
        view.addSubview(topCover)
        view.addSubview(panIndicator)
        view.addSubview(nameLabel)
        view.addSubview(floatButton)
        view.addSubview(dismissButton)
        
        tweakListViewController.tableView.addGestureRecognizer(pan)
    }
    
    func _layoutUI() {
        disableImplicitAnimation {
            view.layer.shadowPath = UIBezierPath(roundedRect: view.bounds, cornerRadius: view.layer.cornerRadius).cgPath
        }
        
        panIndicator.center = .init(x: view.frame.halfWidth, y: 12 + panIndicator.frame.halfHeight)
        
        let isLandscape = UIApplication.tk_shared.isLandscape
        let landscapePadding = tweakListViewController.tableView.safeAreaInsets.left + Constants.UI.ListView.contentLeading
        dismissButton.frame.origin.x = view.frame.width - dismissButton.frame.width - (isLandscape ? landscapePadding : Constants.UI.ListView.contentLeading)
        floatButton.frame.origin.x = dismissButton.frame.origin.x - floatButton.frame.width - 20
        
        nameLabel.frame.origin = .init(x: isLandscape ? landscapePadding : Constants.UI.ListView.contentLeading + Constants.UI.ListView.horizontalPadding, y: 25)
        nameLabel.frame.size.width = floatButton.frame.minX - 20
        nameLabel.frame.size.height = ceil(nameLabel.sizeThatFits(.init(width: nameLabel.frame.width, height: 0)).height)
        
        dismissButton.center.y = ceil(nameLabel.frame.midY)
        floatButton.center.y = dismissButton.center.y
        
        topCover.frame = .init(x: 0, y: 0, width: view.frame.width, height: nameLabel.frame.maxY + 14)
        tweakListViewController.view.frame = .init(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        tweakListViewController.tableView.contentInset.top = topCover.frame.height
    }
    
    func _calibrateUI() {
        view.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
    }
    
    func _reposition() {
        guard let window = context.showingWindow else { return }
        view.frame = _frame(in: window, heightLevel: heightLevel)
    }
}

private extension TweakFloatingPanel {
    func _beginAppearanceTransition(isAppear: Bool) {
        view.isUserInteractionEnabled = false
        beginAppearanceTransition(isAppear, animated: true)
    }
    
    func _endAppearanceTransition() {
        endAppearanceTransition()
        view.isUserInteractionEnabled = true
    }
    
    func _addToWindow() {
        context.showingWindow?.addSubview(view)
    }
    
    func removeFromWindow() {
        view.removeFromSuperview()
        tweakListViewController.setTweaks([], in: context)
    }
    
    func _showAfterFromBall() {
        view.layer.removeAllAnimations()
    }
    
    func _animateFromBall() {
        let anim = CABasicAnimation(keyPath: "transform.translation.y", fromValue: view.bounds.height, toValue: 0, duration: Constants.UI.Floating.panelAnimationDuration)
        view.layer.add(anim, forKey: "view-translate-y")
    }
    
    func _animateToBall() {
        guard let snapshot = snapshot else { return }
        let duration: TimeInterval = Constants.UI.Floating.ballAnimationDuration
        
        if let image = iconImage {
            let scale = Constants.UI.Floating.ballIconSize / Constants.UI.ListView.iconSize
            let scaleAnim = CABasicAnimation(keyPath: "transform.scale", toValue: scale, duration: duration)
            image.add(scaleAnim, forKey: "icon-scale")
            let position = CGPoint(x: Constants.UI.Floating.ballSize.half, y: Constants.UI.Floating.ballSize.half)
            let positionAnim = CABasicAnimation(keyPath: #keyPath(CALayer.position), toValue: position, duration: duration)
            image.add(positionAnim, forKey: "icon-position")
        }

        if let background = iconBackground {
            let backgroundScale = ceil(max(snapshot.frame.width / background.frame.halfWidth, snapshot.frame.height / background.frame.halfHeight))
            let anim = CABasicAnimation(keyPath: "transform.scale", toValue: backgroundScale, duration: duration)
            background.add(anim, forKey: "background-scale")
        }
        
        if let ballPosition = context.floatingTransitioner?.ballPosition() {
            let positionAnim = CABasicAnimation(keyPath: #keyPath(CALayer.position), toValue: ballPosition, duration: duration)
            snapshot.layer.add(positionAnim, forKey: "snapshot-position")
            let ballSize = CGSize(width: Constants.UI.Floating.ballSize, height: Constants.UI.Floating.ballSize)
            let sizeAnim = CABasicAnimation(keyPath: "bounds.size", fromValue: snapshot.frame.size, toValue: ballSize, duration: duration)
            snapshot.layer.add(sizeAnim, forKey: "snapshot-size")
            let cornerAnim = CABasicAnimation(keyPath: #keyPath(CALayer.cornerRadius), fromValue: 0, toValue: Constants.UI.Floating.ballSize.half, duration: duration)
            snapshot.layer.add(cornerAnim, forKey: "snapshot-corner")
        }
    }
    
    func _animateToList() {
        let duration = Constants.UI.Floating.ballAnimationDuration
        let anim = CABasicAnimation(keyPath: "transform.translation.y", fromValue: 0, toValue: view.bounds.height, duration: duration)
        view.layer.add(anim, forKey: "view-translation-y")
    }
    
    func _beginFloatingToBall() {
        snapshot?.isHidden = false
    }
    
    func _endFloatingToBall() {
        snapshot?.removeFromSuperview()
        snapshot = nil
        iconBackground?.removeFromSuperlayer()
        iconBackground = nil
        iconImage?.removeFromSuperlayer()
        iconImage = nil
    }
    
    func _fakeFloatingToBall() {
        guard let window = context.showingWindow, let tweak = tweaks.first else { return }
        snapshot = _makeSnapshot(frame: view.frame)
        window.addSubview(snapshot!)
        let (iconImage, iconBackground) = _makeIcon(in: window, container: snapshot!, tweak: tweak)
        self.iconImage = iconImage
        self.iconBackground = iconBackground
        snapshot?.layer.addSublayer(iconBackground)
        snapshot?.layer.addSublayer(iconImage)
        view.frame.origin.y = window.bounds.height
    }
    
    func _makeSnapshot(frame: CGRect) -> UIImageView {
        let v = UIImageView(frame: frame)
        v.backgroundColor = .red
        v.clipsToBounds = true
        v.image = UIGraphicsImageRenderer(bounds: view.bounds).image { _ in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
        v.isHidden = true
        return v
    }
    
    func _makeIcon(in window: TweakWindow, container: UIView, tweak: AnyTweak) -> (CALayer, CALayer) {
        let frame = container.convert(tweakListViewController.iconFrame(in: 0), from: tweakListViewController.view)
        let image = CALayer()
        image.frame = frame
        image.contents = Constants.UI.shapeImage(of: tweak).cgImage
        let background = CALayer()
        background.frame = frame
        background.backgroundColor = Constants.UI.shapeColor(of: tweak).cgColor
        background.addCorner(radius: Constants.UI.ListView.iconCornerRadius)
        return (image, background)
    }
}

private extension TweakFloatingPanel {
    func _handlePan(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .changed:
            defer { _resetPan(gesture) }
            guard _isListAtTop(tolerance: max(5, abs(gesture.velocity(in: view).y) / 30)) else { return }
            _stretchPan(with: gesture.translation(in: gesture.view))
        case .ended, .cancelled:
            _snapToClosestHeightLevel(velocity: gesture.velocity(in: gesture.view).y)
        default:
            break
        }
    }
    
    func _resetPan(_ gesture: UIPanGestureRecognizer) {
        gesture.setTranslation(.zero, in: gesture.view)
    }
    
    func _isListAtTop(tolerance: CGFloat = 0) -> Bool {
        return tweakListViewController.tableView.contentOffset.y <= -topCover.frame.height + tolerance
            && tweakListViewController.tableView.contentOffset.y >= -topCover.frame.height - tolerance
    }
    
    func _stretchPan(with translation: CGPoint) {
        guard let window = context.showingWindow else { return }
        let targetY = (view.frame.minY + translation.y)
            .clamped(
                from: _frame(in: window, heightLevel: .tall).minY,
                to: _frame(in: window, heightLevel: .short).minY
            )
        view.frame = .init(
            x: view.frame.minX,
            y: targetY,
            width: view.frame.width,
            height: window.bounds.height - targetY
        )
    }
    
    func _snapToClosestHeightLevel(velocity: CGFloat) {
        guard let window = context.showingWindow else { return }
        let targetLevel = _panTargetLevel(in: window, velocity: velocity)
        let targetFrame = _frame(in: window, heightLevel: targetLevel)
        defer { heightLevel = targetLevel }
        
        if heightLevel.distance(from: targetLevel) > 1 {
            let damping = 1 - (abs(velocity) / 4000).clamped(from: 0.2, to: 0.35)
            let initialVelocity = (abs(velocity) / 5000).clamped(from: 0, to: 0.6)
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: damping, initialSpringVelocity: initialVelocity, animations: { [unowned self] in
                view.frame = targetFrame
            })
        } else if heightLevel.distance(from: targetLevel) == 1 {
            let damping = 1 - (abs(velocity) / 400).clamped(from: 0.2, to: 0.35)
            let initialVelocity = (abs(velocity) / 500).clamped(from: 0, to: 0.6)
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: damping, initialSpringVelocity: initialVelocity, animations: { [unowned self] in
                view.frame = targetFrame
            })
        } else {
            let duration = 0.25 - TimeInterval(abs(targetFrame.minY - view.frame.minY) / abs(velocity)).clamped(from: 0, to: 0.1)
            UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseIn, .beginFromCurrentState], animations: { [unowned self] in
                view.frame = targetFrame
            })
        }
    }
    
    func _panTargetLevel(in window: TweakWindow, velocity: CGFloat) -> HeightLevel {
        let isUp = velocity.sign == .minus
        if abs(velocity) >= 3300 {
            // tall <-> short
            return heightLevel.add(distance: isUp ? -2 : 2)
        } else if abs(velocity) >= 500 {
            return heightLevel.add(distance: isUp ? -1 : 1)
        } else {
            // find the nearest height level
            return HeightLevel
                .allCases
                .map { ($0, _frame(in: window, heightLevel: $0).minY) }
                .sorted { abs($0.1 - view.frame.minY) < abs($1.1 - view.frame.minY) }
                .first!
                .0
        }
    }
}

private extension TweakFloatingPanel {
    func _frame(in window: TweakWindow, heightLevel: HeightLevel) -> CGRect {
        let height = ceil(window.bounds.height * heightLevel.percentage)
        return .init(x: 0, y: window.bounds.height - height, width: window.bounds.width, height: height)
    }
}

private extension TweakFloatingPanel {
    @objc func _transitToBall(_ sender: UIButton) {
        context.floatingTransitioner?.animateTransition(from: self, to: TweakFloatingBall(context: context), tweaks: tweaks)
    }
    
    @objc func _transitToList(_ sender: UIButton) {
        context.floatingTransitioner?.animateBackToPrimary(from: self)
    }
    
    @objc func _onPan(_ gesture: UIPanGestureRecognizer) {
        _handlePan(gesture)
    }
}

private extension TweakFloatingPanel {
    func _panIndicator() -> UIView {
        let v = UIView()
        v.isUserInteractionEnabled = false
        v.frame.size = .init(width: 36, height: 6)
        v.backgroundColor = Constants.Color.panIndicator
        v.layer.addCorner(radius: 3)
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
        b.addTarget(self, action: #selector(_transitToBall), for: .touchUpInside)
        b.sizeToFit()
        return b
    }
    
    func _dismissButton() -> UIButton {
        let b = HitOutsideButton(type: .system)
        b.extendInset = .init(inset: -11)
        b.setImage(Constants.Assets.cross, for: .normal)
        b.addTarget(self, action: #selector(_transitToList), for: .touchUpInside)
        b.sizeToFit()
        return b
    }
    
    func _topCover() -> UIView {
        let v = UIView()
        v.backgroundColor = view.backgroundColor
        v.isUserInteractionEnabled = false
        v.layer.addCorner(radius: Constants.UI.Floating.panelCornerRadius, mask: .top)
        return v
    }
    
    func _tweakListViewController() -> TweakListViewController {
        let v = TweakListViewController(scene: .floating)
        v.tableView.showsVerticalScrollIndicator = false
        return v
    }
    
    func _floatingBallBackground() -> UIView {
        let v = UIView()
        v.frame.size = .init(width: Constants.UI.Floating.ballSize, height: Constants.UI.Floating.ballSize)
        v.layer.addCorner(radius: v.frame.halfHeight)
        v.isUserInteractionEnabled = false
        v.isHidden = true
        return v
    }
    
    func _floatingBallIcon() -> UIImageView {
        let v = UIImageView()
        v.frame.size = .init(width: Constants.UI.Floating.ballIconSize, height: Constants.UI.Floating.ballIconSize)
        v.isHidden = true
        return v
    }
    
    func _pan() -> UIPanGestureRecognizer {
        let g = UIPanGestureRecognizer()
        g.addTarget(self, action: #selector(_onPan))
        g.delegate = self
        return g
    }
}

private extension TweakFloatingPanel {
    enum HeightLevel: Int, CaseIterable {
        case tall
        case medium
        case short
        
        var percentage: CGFloat {
            switch self {
            case .tall: return 0.85
            case .medium: return 0.6
            case .short: return 0.3
            }
        }

        func add(distance: Int) -> HeightLevel {
            HeightLevel(rawValue: (rawValue + distance).clamped(from: 0, to: 2))!
        }
        
        func distance(from level: HeightLevel) -> Int {
            abs(rawValue - level.rawValue)
        }
    }
}

private extension Constants.UI.Floating {
    static let panelCornerRadius: CGFloat = 22
}
