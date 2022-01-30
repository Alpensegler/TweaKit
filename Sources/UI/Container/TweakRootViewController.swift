//
//  TweakRootViewController.swift
//  TweaKit
//
//  Created by cokile
//

import UIKit

final class TweakRootViewController: UIViewController {
    private unowned var context: TweakContext
    private var segmentedVC: TweakSegmentedViewController!
    private unowned var initialTweak: AnyTweak?
    
    deinit {
        stopListeningFloating(in: context)
    }
    
    init(context: TweakContext, locateAt tweak: AnyTweak?) {
        self.context = context
        self.initialTweak = tweak
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TweakRootViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        startListeningFloating(in: context)
        _setupUI()
    }
}

extension TweakRootViewController: TweakFloatingAudience {
    func willTransit(fromCategory: TweakFloatingParticipantCategory, toCategory: TweakFloatingParticipantCategory) {
        switch (fromCategory, toCategory) {
        case (.searchList, .ball):
            _toggleInteractionToEnabled(false)
            _toggleViewToShow(false, animated: false)
            _toggleWindowBackgroundToShow(false, animated: true)
        case (.normalList, .ball):
            _toggleInteractionToEnabled(false)
            _toggleWindowBackgroundToShow(false, animated: false)
        case (_, .searchList):
            _toggleSegmentToShow(false)
        default:
            break
        }
    }
    
    func transit(fromCategory: TweakFloatingParticipantCategory, toCategory: TweakFloatingParticipantCategory) {
        switch (fromCategory, toCategory) {
        case (.normalList, _):
            _toggleViewToShow(false, animated: true)
        case (.ball, .normalList), (.panel, .normalList):
            _toggleViewToShow(true, animated: true)
        case (.ball, .searchList), (.panel, .searchList):
            _toggleWindowBackgroundToShow(true, animated: true)
        default:
            break
        }
    }
    
    func didTransit(fromCategory: TweakFloatingParticipantCategory, toCategory: TweakFloatingParticipantCategory) {
        switch toCategory {
        case .normalList:
            _toggleSegmentToShow(true)
            _toggleViewToShow(true, animated: false)
            _toggleWindowBackgroundToShow(true, animated: false)
            _toggleInteractionToEnabled(true)
        case .searchList:
            _toggleSegmentToShow(true)
            _toggleViewToShow(true, animated: true) { [weak self] in
                self?._toggleViewToShow(true, animated: false)
            }
            _toggleWindowBackgroundToShow(true, animated: false)
            _toggleInteractionToEnabled(true)
        case .ball:
            _toggleViewToShow(false, animated: false)
            _toggleWindowBackgroundToShow(false, animated: false)
        case .panel:
            break
        }
    }
}

private extension TweakRootViewController {
    func _setupUI() {
        _setupView()
        _setupNavigation()
        _setupSegment()
    }
    
    func _setupView() {
        view.backgroundColor = Constants.Color.backgroundPrimary
        navigationController?.view.backgroundColor = Constants.Color.backgroundPrimary
    }
    
    func _setupNavigation() {
        title = context.name
        
        navigationController?.navigationBar.titleTextAttributes = [.font: UIFont.systemFont(ofSize: 18, weight: .medium)]
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = Constants.Color.backgroundPrimary
        navigationController?.navigationBar.shadowImage = UIImage() // remove bottom line

        let dismiss = UIBarButtonItem(image: Constants.Assets.naviBack, style: .plain, target: self, action: #selector(_dismiss))
        let searchItem = UIBarButtonItem(image: Constants.Assets.naviSearch, style: .plain, target: self, action: #selector(_searchTweaks))
        let moreItem = UIBarButtonItem(image: Constants.Assets.naviMore, style: .plain, target: nil, action: nil)
        if #available(iOS 14, *) {
            moreItem.menu = UIMenu(children: [
                UIAction(title: "Import Tweaks", image: Constants.Assets.importTweaks) { [unowned self] _ in _importTweaks(moreItem) },
                UIAction(title: "Export Tweaks", image: Constants.Assets.exportTweaks) { [unowned self] _ in _exportTweaks(moreItem) },
                UIAction(title: "Reset Tweaks", image: Constants.Assets.resetTweaks, attributes: .destructive) { [unowned self] _ in _resetTweaks(moreItem) },
            ])
        } else {
            moreItem.target = self
            moreItem.action = #selector(_tradeTweaks)
        }
        navigationItem.leftBarButtonItem = dismiss
        navigationItem.rightBarButtonItems = [searchItem, moreItem]
    }
    
    func _setupSegment() {
        if let tweak = initialTweak {
            segmentedVC = TweakSegmentedViewController(context: context, initialTweak: tweak)
        } else if context.delegate?.shouldRememberLastTweakList(for: context) == true {
            segmentedVC = TweakSegmentedViewController(context: context, initialList: context.lastShowingList)
        } else {
            segmentedVC = TweakSegmentedViewController(context: context)
        }
        addChild(segmentedVC)
        segmentedVC.view.frame = view.bounds
        view.addSubview(segmentedVC.view)
        segmentedVC.didMove(toParent: self)
    }
}

private extension TweakRootViewController {
    func _toggleSegmentToShow(_ flag: Bool) {
        segmentedVC.view.alpha = flag ? 1 : 0
    }
    
    func _toggleInteractionToEnabled(_ flag: Bool) {
        navigationController?.view.isUserInteractionEnabled = flag
    }
    
    func _toggleViewToShow(_ flag: Bool, animated: Bool, completion: (() -> Void)? = nil) {
        let key = "floating-opacity"
        
        guard animated else {
            disableImplicitAnimation {
                navigationController?.view.layer.opacity = flag ? 1 : 0
                navigationController?.view.layer.removeAnimation(forKey: key)
            }
            return
        }
        
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        let anim = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
        anim.fromValue = flag ? 0 : 1
        anim.toValue = flag ? 1 : 0
        anim.duration = Constants.UI.Floating.fadeDuration
        anim.fillMode = .both
        anim.isRemovedOnCompletion = false
        navigationController?.view.layer.add(anim, forKey: key)
        CATransaction.commit()
    }
    
    func _toggleWindowBackgroundToShow(_ flag: Bool, animated: Bool) {
        let key = "floating-background-color"
        
        guard animated else {
            disableImplicitAnimation {
                context.showingWindow?.backgroundColor = flag ? Constants.UI.windowBackgroundColor : .clear
                context.showingWindow?.layer.removeAnimation(forKey: key)
            }
            return
        }
        
        let anim = CABasicAnimation(keyPath: #keyPath(CALayer.backgroundColor))
        anim.fromValue = flag ? UIColor.clear.cgColor : Constants.UI.windowBackgroundColor.cgColor
        anim.toValue = flag ? Constants.UI.windowBackgroundColor.cgColor : UIColor.clear.cgColor
        anim.duration = Constants.UI.Floating.fadeDuration
        anim.fillMode = .both
        anim.isRemovedOnCompletion = false
        context.showingWindow?.layer.add(anim, forKey: key)
    }
}

private extension TweakRootViewController {
    @objc func _dismiss(_ sender: UIBarButtonItem) {
        context.dismiss()
    }
    
    @objc func _searchTweaks(_ sender: UIBarButtonItem) {
        let searchVC = TweakSearchViewController(context: context)
        present(searchVC, animated: true)
    }
    
    @objc func _tradeTweaks(_ sender: UIBarButtonItem) {
        let actions: [UIAlertAction] = [
            UIAlertAction(title: "Import Tweaks", style: .default) { [unowned self] _ in _importTweaks(sender) },
            UIAlertAction(title: "Export Tweaks", style: .default) { [unowned self] _ in _exportTweaks(sender) },
            UIAlertAction(title: "Reset Tweaks", style: .destructive) { [unowned self] _ in _resetTweaks(sender) },
        ]
        UIAlertController.actionSheet(actions: actions, barButtonItem: sender, fromVC: self)
    }
    
    func _importTweaks(_ sender: UIBarButtonItem) {
        let sources = context.getImportSources()
        if sources.isEmpty {
            UIAlertController.alert(title: "No Source to Import", fromVC: self)
            return
        }
        
        let actions: [UIAlertAction] = sources.map { source in
            let sourceName = source.name
            return UIAlertAction(title: sourceName, style: .default) { [unowned self] _ in
                context.trader.import(from: source) { error in
                    if let error = error {
                        UIAlertController.alert(title: error.localizedDescription, fromVC: self)
                    } else {
                        UIAlertController.alert(title: "Did import \(sourceName)", fromVC: self)
                    }
                }
            }
        }
        UIAlertController.actionSheet(title: "Import Tweaks from...", actions: actions, barButtonItem: sender, fromVC: self)
    }
    
    func _exportTweaks(_ sender: UIBarButtonItem) {
        let tweakSets = context.getExportTweakSets(currentIndex: segmentedVC.currentIndex)
        if tweakSets.isEmpty {
            UIAlertController.alert(title: "No Exportable Tweaks to Export", fromVC: self)
        } else if tweakSets.count == 1 {
            _export(tweaks: tweakSets[0].tweaks, title: "Export \(tweakSets[0].name) to...", sender: sender)
        } else {
            let actions: [UIAlertAction] = tweakSets.compactMap { tweakSet in
                if tweakSet.tweaks.isEmpty { return nil }
                return UIAlertAction(title: tweakSet.name, style: .default) { [unowned self] _ in
                    _export(tweaks: tweakSet.tweaks, title: "Export \(tweakSet.name) to...", sender: sender)
                }
            }
            UIAlertController.actionSheet(title: "Choose Tweaks to Export", actions: actions, barButtonItem: sender, fromVC: self)
        }
    }
    
    func _resetTweaks(_ sender: UIBarButtonItem) {
        let tweakSets = context.getResetTweakSets(currentIndex: segmentedVC.currentIndex)
        if tweakSets.isEmpty {
            UIAlertController.alert(title: "No Tweaks to Reset", fromVC: self)
        } else if tweakSets.count == 1 {
            let tweakSet = tweakSets[0]
            _reset(tweaks: tweakSet.tweaks, isAll: tweakSet.isAll, title: "Reset \(tweakSet.name)?", sender: sender) { [unowned self] in
                UIAlertController.alert(title: "Did reset \(tweakSet.name)", fromVC: self)
            }
        } else {
            let actions: [UIAlertAction] = tweakSets.compactMap { tweakSet in
                if tweakSet.tweaks.isEmpty { return nil }
                return UIAlertAction(title: tweakSet.name, style: .default) { [unowned self] _ in
                    _reset(tweaks: tweakSet.tweaks, isAll: tweakSet.isAll, title: "Reset \(tweakSet.name)?", sender: sender) {
                        UIAlertController.alert(title: "Did reset \(tweakSet.name)", fromVC: self)
                    }
                }
            }
            UIAlertController.actionSheet(title: "Choose Tweaks to Reset", actions: actions, barButtonItem: sender, fromVC: self)
        }
    }
    
    func _export(tweaks: [AnyTradableTweak], title: String?, sender: UIBarButtonItem) {
        let destinations = context.getExportDestinations(fromVC: self)
        if destinations.isEmpty {
            UIAlertController.alert(title: "No Destinations to Export", fromVC: self)
            return
        }
        
        let actions: [UIAlertAction] = destinations.map { destination in
            let needsNotify = destination.needsNotifyCompletion
            let destinationName = destination.name
            return UIAlertAction(title: destinationName, style: .default) { [unowned self] _ in
                context.trader.export(tweaks: tweaks, to: destination) { error in
                    if let error = error {
                        UIAlertController.alert(title: error.localizedDescription, fromVC: self)
                    } else if needsNotify {
                        UIAlertController.alert(title: "Did export to \(destinationName)", fromVC: self)
                    }
                }
            }
        }
        UIAlertController.actionSheet(title: title, actions: actions, barButtonItem: sender, fromVC: self)
    }
    
    func _reset(tweaks: [AnyTweak], isAll: Bool, title: String?, sender: UIBarButtonItem, completion: @escaping () -> Void) {
        let action = UIAlertAction(title: "Confirm", style: .destructive) { [unowned self] _ in
            if isAll {
                context.store.removeAll()
            } else {
                tweaks.forEach {
                    $0.resetStoredValue()
                }
            }
            tweaks.forEach {
                $0.resetInfo()
            }
            completion()
        }
        UIAlertController.alert(title: title, actions: [action], fromVC: self)
    }
}
