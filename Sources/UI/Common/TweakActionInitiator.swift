//
//  ActionInitiator.swift
//  TweaKit
//
//  Created by cokile
//

import UIKit

protocol TweakActionInitiator: AnyObject {
    var fromVC: UIViewController? { get }
}

protocol TweakExportInitiator: TweakActionInitiator {
    var context: TweakContext? { get }
    var exportableTweaks: [AnyTradableTweak] { get }
    var exportAlertTitle: String? { get }
    var sender: UIView { get }
}

extension TweakExportInitiator {
    func initiateExport() {
        DispatchQueue.ensureInMain()

        let tweaks = exportableTweaks
        if tweaks.isEmpty {
            UIAlertController.alert(title: "No Exportable Tweaks to Export", fromVC: fromVC)
            return
        }
        guard let destinations = context?.getExportDestinations(fromVC: fromVC), !destinations.isEmpty else {
            UIAlertController.alert(title: "No Destinations to Export", fromVC: fromVC)
            return
        }

        let actions = destinations.map { destination in
            UIAlertAction(title: destination.name, style: .default) { [unowned self] _ in
                context?.trader.export(tweaks: tweaks, to: destination)
            }
        }
        UIAlertController.actionSheet(title: exportAlertTitle, actions: actions, view: sender, fromVC: fromVC)
    }
}

protocol TweakResetInitiator: TweakActionInitiator {
    var resetableTweaks: [AnyTweak] { get }
    var resetAlertTitle: String? { get }
    var needsConfirm: Bool { get }
}

extension TweakResetInitiator {
    var needsConfirm: Bool { true }
}

extension TweakResetInitiator {
    func initiateReset() {
        DispatchQueue.ensureInMain()

        if needsConfirm {
            let action = UIAlertAction(title: "Confirm", style: .destructive) { [unowned self] _ in
                _resetTweaks()
            }
            UIAlertController.alert(title: resetAlertTitle, actions: [action], fromVC: fromVC)
        } else {
            _resetTweaks()
        }
    }

    func _resetTweaks() {
        let tweaks = resetableTweaks
        if tweaks.isEmpty {
            UIAlertController.alert(title: "No Tweaks to Reset", fromVC: fromVC)
            return
        }

        for tweak in tweaks {
            tweak.resetStoredValue()
            tweak.resetInfo()
        }
    }
}

extension AnyTweak {
    func resetStoredValue() {
        context?.store.removeValue(forKey: id)
    }
}
