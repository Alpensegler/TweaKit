//
//  TweakFloatingBall.swift
//  TweaKit
//
//  Created by cokile
//

import UIKit

final class TweakFloatingBall: UIView {
    private unowned var context: TweakContext
    private var tweaks: [AnyTweak] = []

    private lazy var dashLayer = _dashLayer()
    private lazy var iconLayer = _iconLayer()
    private lazy var pan = _pan()
    private lazy var tap = _tap()
    private lazy var longPress = _longPress()

    private var snapAnimator: UIDynamicAnimator?
    private var snapBehavior: UISnapBehavior?
    private var dynamicItemBehavior: UIDynamicItemBehavior?

    deinit {
        _unregisterNotifications()
    }

    init(context: TweakContext) {
        self.context = context
        super.init(frame: .init(x: 0, y: 0, width: Constants.UI.Floating.ballSize, height: Constants.UI.Floating.ballSize))
        _registerNotifications()
        _setupUI()
        _calibrateUI()
        _reposition()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TweakFloatingBall {
    override func layoutSubviews() {
        super.layoutSubviews()
        _layoutUI()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        _calibrateUI()
    }
}

extension TweakFloatingBall: TweakFloatingSecondaryParticipant {
    var category: TweakFloatingParticipantCategory { .ball }

    func transit(to category: TweakFloatingParticipantCategory) {
        _willTransitAway()
    }

    func transit(from category: TweakFloatingParticipantCategory) {
    }

    func completeTransition(from category: TweakFloatingParticipantCategory) {
        _didTransitIn()
    }

    func reload(withTweaks tweaks: [AnyTweak]) {
        self.tweaks = tweaks
        _reload()
    }
}

extension TweakFloatingBall: UIDynamicAnimatorDelegate {
    func dynamicAnimatorDidPause(_ animator: UIDynamicAnimator) {
        guard let window = context.showingWindow else { return }
        Self._savePosition(layer.position, in: window)
    }
}

extension TweakFloatingBall {
    // normalized position
    private static var lastPosition: CGPoint?

    static func position(in window: TweakWindow) -> CGPoint {
        let viablePositionFrame = _viablePositionFrame(in: window)
        if let position = lastPosition {
            return .init(
                x: ceil(viablePositionFrame.minX + viablePositionFrame.width * position.x),
                y: ceil(viablePositionFrame.minY + viablePositionFrame.height * position.y)
            )
        } else {
            return .init(x: viablePositionFrame.maxX, y: viablePositionFrame.maxY)
        }
    }

    private static func _viablePositionFrame(in  window: TweakWindow) -> CGRect {
        UIApplication.tk_shared.isLandscape
            ? window.bounds
                .insetBy(dx: Constants.UI.Floating.ballVerticalPadding, dy: Constants.UI.Floating.ballHorizontalPadding)
                .insetBy(dx: Constants.UI.Floating.ballSize.half, dy: Constants.UI.Floating.ballSize.half)
            : window.bounds
                .insetBy(dx: Constants.UI.Floating.ballHorizontalPadding, dy: Constants.UI.Floating.ballVerticalPadding)
                .insetBy(dx: Constants.UI.Floating.ballSize.half, dy: Constants.UI.Floating.ballSize.half)
    }

    private static func _savePosition(_ position: CGPoint, in window: TweakWindow) {
        let viablePositionFrame = _viablePositionFrame(in: window)
        let x = (position.x - viablePositionFrame.minX) / viablePositionFrame.width
        let y = (position.y - viablePositionFrame.minY) / viablePositionFrame.height
        lastPosition = .init(x: x.clamped(from: 0, to: 1), y: y.clamped(from: 0, to: 1))
    }
}

private extension TweakFloatingBall {
    func _setupUI() {
        layer.addShadow(color: UIColor.black.withAlphaComponent(0.1), y: 5, radius: 5, path: .init(roundedRect: layer.bounds, cornerRadius: frame.halfHeight))
        layer.addCorner(radius: frame.halfHeight)
        layer.addSublayer(dashLayer)
        layer.addSublayer(iconLayer)

        addGestureRecognizer(pan)
        addGestureRecognizer(tap)
        addGestureRecognizer(longPress)
    }

    func _layoutUI() {
        dashLayer.frame = bounds.insetBy(dx: 4, dy: 4)
        dashLayer.path = UIBezierPath(roundedRect: dashLayer.bounds, cornerRadius: dashLayer.frame.halfHeight).cgPath
        iconLayer.position = .init(x: bounds.halfWidth, y: bounds.halfHeight)
    }

    func _calibrateUI() {
        layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
    }
}

private extension TweakFloatingBall {
    func _registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(_onDidChangeOrientation), name: UIDevice.orientationDidChangeNotification, object: nil)
    }

    func _unregisterNotifications() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func _onDidChangeOrientation(_ notification: Notification) {
        _reposition()
    }
}

private extension TweakFloatingBall {
    func _reload() {
        guard let tweak = tweaks.first else { return }
        backgroundColor = Constants.UI.shapeColor(of: tweak)
        iconLayer.contents = UIGraphicsImageRenderer(size: iconLayer.frame.size).image { _ in
            Constants.UI.shapeImage(of: tweak).draw(in: iconLayer.bounds)
        }.cgImage
    }

    func _reposition() {
        layer.position = context.showingWindow.map(Self.position(in:)) ?? .zero
    }

    func _willTransitAway() {
        removeFromSuperview()
    }

    func _didTransitIn() {
        context.showingWindow?.addSubview(self)
    }
}

private extension TweakFloatingBall {
    @objc func _handlePan(_ pan: UIPanGestureRecognizer) {
        guard let window = context.showingWindow else { return }
        let viablePositionFrame = Self._viablePositionFrame(in: window)
        switch pan.state {
        case .began:
            _cancelSnap()
        case .changed:
            defer { pan.setTranslation(.zero, in: window) }
            _moveAsPan(pan.translation(in: window), viablePositionFrame: viablePositionFrame)
        case .ended, .cancelled:
            _snapToClosestEdge(viablePositionFrame: viablePositionFrame)
        default:
            break
        }
    }

    @objc func _handleTap(_ tap: UITapGestureRecognizer) {
        guard tap.state == .ended else { return }
        _toPanel()
    }

    @objc func _handleLongPress(_ longPress: UITapGestureRecognizer) {
        guard longPress.state == .began else { return }
        _toList()
    }
}

private extension TweakFloatingBall {
    func _moveAsPan(_ translation: CGPoint, viablePositionFrame: CGRect) {
        disableImplicitAnimation {
            layer.position = .init(
                x: (layer.position.x + translation.x).clamped(from: viablePositionFrame.minX, to: viablePositionFrame.maxX),
                y: (layer.position.y + translation.y).clamped(from: viablePositionFrame.minY, to: viablePositionFrame.maxY)
            )
        }
    }

    func _snapToClosestEdge(viablePositionFrame: CGRect) {
        guard let window = context.showingWindow else { return }
        let snapPoint: CGPoint = layer.position.x >= window.frame.halfWidth
            ? .init(x: viablePositionFrame.maxX, y: layer.position.y)
            : .init(x: viablePositionFrame.minX, y: layer.position.y)
        snapBehavior = UISnapBehavior(item: self, snapTo: snapPoint)
        dynamicItemBehavior = UIDynamicItemBehavior(items: [self])
        dynamicItemBehavior?.allowsRotation = false
        snapAnimator = UIDynamicAnimator(referenceView: window)
        snapAnimator?.addBehavior(snapBehavior!)
        snapAnimator?.addBehavior(dynamicItemBehavior!)
        snapAnimator?.delegate = self
    }

    func _cancelSnap() {
        snapAnimator?.removeAllBehaviors()
        snapAnimator = nil
        snapBehavior = nil
        dynamicItemBehavior = nil
    }

    func _toPanel() {
        isUserInteractionEnabled = false
        context.floatingTransitioner?.animateTransition(from: self, to: TweakFloatingPanel(context: context), tweaks: tweaks)
    }

    func _toList() {
        isUserInteractionEnabled = false
        context.floatingTransitioner?.animateBackToPrimary(from: self)
    }
}

private extension TweakFloatingBall {
    func _dashLayer() -> CAShapeLayer {
        let l = CAShapeLayer()
        l.fillColor = UIColor.clear.cgColor
        l.strokeColor = UIColor.white.cgColor
        l.lineJoin = .round
        l.lineWidth = 1
        l.lineDashPattern = [4, 4]
        return l
    }

    func _iconLayer() -> CALayer {
        let l = CALayer()
        l.frame.size = .init(width: Constants.UI.Floating.ballIconSize, height: Constants.UI.Floating.ballIconSize)
        l.contentsScale = UIScreen.main.scale
        l.contentsGravity = .center
        return l
    }

    func _pan() -> UIPanGestureRecognizer {
        let p = UIPanGestureRecognizer(target: self, action: #selector(_handlePan))
        return p
    }

    func _tap() -> UITapGestureRecognizer {
        let t = UITapGestureRecognizer(target: self, action: #selector(_handleTap))
        return t
    }

    func _longPress() -> UILongPressGestureRecognizer {
        let l = UILongPressGestureRecognizer(target: self, action: #selector(_handleLongPress))
        return l
    }
}

extension Constants.UI {
    enum Floating {
        static let ballSize: CGFloat = 70
        static let ballIconSize: CGFloat = 50
        static let ballHorizontalPadding: CGFloat = 15
        static let ballVerticalPadding: CGFloat = 40
        static let ballAnimationDuration: TimeInterval = 0.35
        static let panelAnimationDuration: TimeInterval = 0.35
        static let fadeDuration: TimeInterval = 0.15
    }
}
