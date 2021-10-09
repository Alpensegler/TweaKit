//
//  ViewController.swift
//  TweaKit-Demo
//  Created by cokile
//
//

import UIKit
import TweaKit

class ViewController: UIViewController {
    private var tweakNotifyTokens: Set<NotifyToken> = []
    private var notificationTokens: [NSObjectProtocol] = []
    
    @IBOutlet weak var sketchView: SketchView!
    @IBOutlet weak var sketchColorIndicatorView: UIImageView!
    @IBOutlet weak var sketchColorIndicatorShadowView: UIView!
    @IBOutlet weak var sketchActionView: SketchActionView!
    @IBOutlet weak var shakeTipView: UIView!
    @IBOutlet weak var longPressTipView: UIView!
    @IBOutlet weak var orLabel: UILabel!
    @IBOutlet weak var placeholderLabel: UILabel!
    
    @IBOutlet weak var longPressTipViewLeadingToCenter: NSLayoutConstraint!
    @IBOutlet weak var longPressTipViewLeadingToShakeTip: NSLayoutConstraint!
    
    @IBAction func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        guard sender.state == .began else { return }
        _prepareForShowTweaks()
        _showTweaks()
    }
    
    deinit {
        _unbindTweaks()
        _unregisterNotifications()
    }
}

extension ViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        _registerNotifications()
        _setupUI()
        _bindTweaks()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        _updateSketchActions()
    }
    
    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionBegan(motion, with: event)
        guard motion == .motionShake, Tweaks.rootViewEnableShake else { return }
        _prepareForShowTweaks()
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionEnded(motion, with: event)
        guard motion == .motionShake, Tweaks.rootViewEnableShake else { return }
        _showTweaks()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        _updateColors()
    }
}

extension ViewController: SketchViewDelegate {
    func sketchViewDidUpdate(_ sketchView: SketchView, hasContent: Bool) {
        _updatePlaceholder(hasContent: hasContent)
        _updateSketchActions()
    }
}

private extension ViewController {
    func _setupUI() {
        _setupNavigation()
        _setupSketch()
        _setupTip()
    }
    
    func _setupNavigation() {
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.view.backgroundColor = view.backgroundColor
        title = [Tweaks.rootViewNavigationTitle, Tweaks.sketchName].filter { !$0.isEmpty }.joined(separator: "-")
    }
    
    func _setupSketch() {
        sketchView.becomeFirstResponder()
        sketchView.delegate = self
        sketchView.lineWidth = Tweaks.sketchLineWidth
        sketchView.lineColor = Tweaks.sketchLineColor
        
        sketchColorIndicatorView.backgroundColor = sketchView.lineColor
        sketchColorIndicatorView.layer.cornerRadius = sketchColorIndicatorView.frame.height * 0.5
        sketchColorIndicatorView.layer.borderWidth = 2
        sketchColorIndicatorView.layer.borderColor = UIColor.white.cgColor
        sketchColorIndicatorShadowView.layer.shadowPath = UIBezierPath(
            roundedRect: sketchColorIndicatorShadowView.bounds,
            cornerRadius: sketchColorIndicatorShadowView.bounds.height * 0.5
        ).cgPath
        sketchColorIndicatorShadowView.layer.shadowColor = UIColor.black.withAlphaComponent(0.12).cgColor
        sketchColorIndicatorShadowView.layer.shadowRadius = 5
        sketchColorIndicatorShadowView.layer.shadowOffset = .init(width: 0, height: 6)
        sketchColorIndicatorView.layer.cornerCurve = .circular
        sketchColorIndicatorShadowView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
    }
    
    func _setupTip() {
        shakeTipView.isHidden = !Tweaks.rootViewEnableShake
        shakeTipView.layer.cornerRadius = 10
        shakeTipView.layer.cornerCurve = .continuous
        longPressTipView.layer.cornerRadius = 10
        longPressTipView.layer.cornerCurve = .continuous
        orLabel.isHidden = shakeTipView.isHidden
        longPressTipViewLeadingToCenter.isActive = !shakeTipView.isHidden
        longPressTipViewLeadingToShakeTip.isActive = shakeTipView.isHidden
    }
}

private extension ViewController {
    func _bindTweaks() {
        _bindTweaksForApp()
        _bindTweaksForRootView()
        _bindTweaksForSketch()
    }
    
    func _unbindTweaks() {
        tweakNotifyTokens.forEach { $0.invalidate() }
        tweakNotifyTokens.removeAll()
    }
    
    func _bindTweaksForApp() {
        Tweaks.appIcon.apply()
        
        let token = Tweaks.$appIcon.startObservingValueChange { _, new, _ in
            new.apply()
        }
        tweakNotifyTokens.insert(token)
    }
    
    func _bindTweaksForRootView() {
        var token = Tweaks.$rootViewNavigationTitle.startObservingValueChange { [unowned self] _, new, _ in
            title = "\(new)-\(Tweaks.sketchName)"
        }
        tweakNotifyTokens.insert(token)
        
        token = Tweaks.$rootViewEnableShake.startObservingValueChange { [unowned self] _, new, _ in
            shakeTipView.isHidden = !new
            orLabel.isHidden = !new
            _updateTips(isShakeEnabled: new)
        }
        tweakNotifyTokens.insert(token)
    }
    
    func _bindTweaksForSketch() {
        var token = Tweaks.$sketchName.startObservingValueChange { [unowned self] _, new, _ in
            if new.isEmpty {
                title = Tweaks.rootViewNavigationTitle
            } else {
                title = "\(Tweaks.rootViewNavigationTitle)-\(new)"
            }
        }
        tweakNotifyTokens.insert(token)
        
        token = Tweaks.$sketchActionsOrder.startObservingValueChange { [unowned self] _, new, _ in
            sketchActionView.reload(with: new, for: sketchView)
        }
        tweakNotifyTokens.insert(token)

        token = Tweaks.$sketchLineColor.startObservingValueChange { [unowned self] _, new, _ in
            sketchView.lineColor = new
            sketchColorIndicatorView.backgroundColor = new
        }
        tweakNotifyTokens.insert(token)
        
        token = Tweaks.$sketchLineWidth.startObservingValueChange { [unowned self] _, new, _ in
            sketchView.lineWidth = new
        }
        tweakNotifyTokens.insert(token)
    }
}

private extension ViewController {
    func _registerNotifications() {
        var token = NotificationCenter.default.addObserver(forName: .didDismissTweakWindow, object: Tweaks.context, queue: .main) { [weak self] in
            self?._handleTweakDismiss($0)
        }
        notificationTokens.append(token)
        
        token = NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [weak self] in
            self?._handleEnterForeground($0)
        }
        notificationTokens.append(token)
    }
    
    func _unregisterNotifications() {
        notificationTokens.forEach {
            NotificationCenter.default.removeObserver($0)
        }
        notificationTokens.removeAll()
    }
    
    func _handleTweakDismiss(_ notifcation: Notification) {
        sketchView.becomeFirstResponder()
    }
    
    func _handleEnterForeground(_ notification: Notification) {
        // constraints not installed in Interface Builder will be deactivated after app entering background
        // so we need to reconfig theses constraints in code
        _updateTips()
    }
}

private extension ViewController {
    func _prepareForShowTweaks() {
        sketchView.resignFirstResponder()
    }
    
    func _showTweaks() {
        Tweaks.context.show()
    }
    
    func _updateColors() {
        sketchColorIndicatorShadowView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
    }
    
    func _updatePlaceholder(hasContent: Bool) {
        placeholderLabel.isHidden = hasContent
    }
    
    func _updateSketchActions() {
        sketchActionView.reload(with: Tweaks.sketchActionsOrder, for: sketchView)
    }
    
    func _updateTips(isShakeEnabled: Bool? = nil) {
        // must deactivate the conflicted constraints first
        longPressTipViewLeadingToCenter.isActive = false
        longPressTipViewLeadingToShakeTip.isActive = false
        longPressTipViewLeadingToCenter.isActive = isShakeEnabled ?? Tweaks.rootViewEnableShake
        longPressTipViewLeadingToShakeTip.isActive = !longPressTipViewLeadingToCenter.isActive
        view.setNeedsUpdateConstraints()
    }
}
