//
//  TweakContext+UI.swift
//  TweaKit
//
//  Created by cokile
//

import UIKit

extension TweakContext {
    func showWindow(locateAt tweak: AnyTweak?, completion: ((Bool) -> Void)? = nil) {
        if TweakWindow.showingWindow != nil {
            Logger.log("There is already a showing window")
            completion?(false)
            return
        }

        if lists.isEmpty {
            Logger.log("TweakContext: \(self.name) has no list.")
            completion?(false)
            return
        }

        if let window = showingWindow, window.isFloating {
            Logger.log("TweakContext: \(self.name) is floating.")
            completion?(false)
            return
        }

        delegate?.willShowTweakWindow(for: self)
        floatingTransitioner = TweakFloatingTransitioner(context: self)
        showingWindow = TweakWindow(context: self, locateAt: tweak)
        showingWindow?.show { [weak self] in
            self?.isShowing = true
            completion?(true)
            if let self = self {
                self.delegate?.didShowTweakWindow(for: self)
            }
        }
    }

    func dismissWindow(completion: ((Bool) -> Void)? = nil) {
        if TweakWindow.showingWindow == nil {
            Logger.log("There is no showing window")
            completion?(false)
            return
        }

        if let window = showingWindow, window.isFloating {
            Logger.log("TweakContext: \(self.name) is floating.")
            completion?(false)
            return
        }

        delegate?.willDismissTweakWindow(for: self)
        showingWindow?.dismiss { [weak self] in
            self?.floatingTransitioner = nil
            self?.showingWindow = nil
            self?.isShowing = false
            completion?(true)
            if let self = self {
                self.delegate?.didDismissTweakWindow(for: self)
            }
        }
    }
}

extension TweakContext {
    func getImportSources() -> [TweakTradeSource] {
        tradeSources()
    }

    func getExportTweakSets(currentIndex: Int) -> [ExportTweakSet] {
        var tweakSets: [ExportTweakSet] = .init(capacity: 1)
        let allTweaks = tweaks.compactMap { $0 as? AnyTradableTweak }

        var presets: [String: ExportTweakSet] = [:]
        for tweak in allTweaks {
            let exportPresets = tweak.exportPresets
            if exportPresets.isEmpty { continue }
            for presetName in exportPresets {
                if let tweakSet = presets[presetName] {
                    tweakSet.tweaks.append(tweak)
                } else {
                    presets[presetName] = .init(name: presetName, tweaks: [tweak])
                }
            }
        }

        for key in presets.keys.sorted() {
            tweakSets.append(presets[key]!)
        }

        if lists.count > 1 {
            let list = lists[currentIndex]
            let currentTweaks = list.tweaks.compactMap({ $0 as? AnyTradableTweak })
            if !currentTweaks.isEmpty {
                tweakSets.append(.init(name: list.name, tweaks: currentTweaks))
            }
        }

        if !allTweaks.isEmpty {
            tweakSets.append(.init(name: "All Tweaks", tweaks: allTweaks))
        }

        return tweakSets
    }

    func getExportDestinations(fromVC: UIViewController?) -> [TweakTradeDestination] {
        var destinations = tradeDestinations()
        if destinations.isEmpty {
            destinations.reserveCapacity(2)
            if let fromVC = fromVC {
                destinations.append(TweakTradeActivityDestination(fileName: "\(self.name).tweaks", fromVC: fromVC))
            }
            destinations.append(TweakTradePasteboardDestination())
            if Constants.Debug.isDebuggerAttached {
                destinations.append(TweakTradeConsoleDestination())
            }
        }
        return destinations
    }

    func getResetTweakSets(currentIndex: Int) -> [ResetTweakSet] {
        var tweakSets: [ResetTweakSet] = .init(capacity: 1)

        if lists.count > 1 {
            let list = lists[currentIndex]
            let currentTweaks = list.tweaks
            if !currentTweaks.isEmpty {
                tweakSets.append(.init(name: list.name, isAll: false, tweaks: currentTweaks))
            }
        }

        tweakSets.append(.init(name: "All Tweaks", isAll: true, tweaks: tweaks))

        return tweakSets
    }
}

final class ExportTweakSet {
    let name: String
    fileprivate(set) var tweaks: [AnyTradableTweak]

    init(name: String, tweaks: [AnyTradableTweak]) {
        self.name = name
        self.tweaks = tweaks
    }
}

final class ResetTweakSet {
    let name: String
    let isAll: Bool
    let tweaks: [AnyTweak]

    init(name: String, isAll: Bool, tweaks: [AnyTweak]) {
        self.name = name
        self.isAll = isAll
        self.tweaks = tweaks
    }
}
