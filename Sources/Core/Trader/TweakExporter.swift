//
//  TweakExporter.swift
//  TweaKit
//
//  Created by cokile
//

import UIKit

public protocol TweakTradeDestination {
    var name: String { get }
    var needsNotifyCompletion: Bool { get }
    
    func ship(_ cargo: TweakTradeCargo, completion: @escaping (Error?) -> Void)
}

extension TweakTradeDestination {
    public var needsNotifyCompletion: Bool { true }
}

final class TweakExporter {
    private weak var trader: TweakTrader?
    
    init(trader: TweakTrader) {
        self.trader = trader
    }
}

extension TweakExporter {
    func export(tweaks: [AnyTradableTweak], to destination: TweakTradeDestination, completion: ((TweakError?) -> Void)?) {
        dispatchPrecondition(condition: .onQueue(.main))
        
        do {
            let container = try _package(tweaks: tweaks)
            let cargo = try _assemble(container)
            destination.ship(cargo) { error in
                if let error = error {
                    completion?(.trade(reason: .destinationFailure(inner: error)))
                } else {
                    completion?(nil)
                }
            }
        } catch {
            completion?(error as? TweakError)
        }
    }
}

private extension TweakExporter {
    func _assemble(_ container: TweakTradeContainer) throws -> TweakTradeCargo {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            return try encoder.encode(container)
        } catch {
            throw TweakError.trade(reason: .corruptedData(inner: error))
        }
    }
    
    func _package(tweaks: [AnyTradableTweak]) throws -> TweakTradeContainer {
        if tweaks.isEmpty {
            return .init(version: Constants.Trade.supportedVersion, boxes: [])
        }
        
        if tweaks.contains(where: { $0.context == nil }) {
            throw TweakError.trade(reason: .contextNotFound)
        }
        
        var boxes: [TweakTradeBox] = .init(capacity: tweaks.count)
        for tweak in tweaks.sorted(by: { $0.id < $1.id }) {
            guard let listName = tweak.list?.name, let sectionName = tweak.section?.name else { continue }
            boxes.append(.init(list: listName, section: sectionName, tweak: tweak.name, value: tweak.tradeValue()))
        }
        
        return .init(version: Constants.Trade.supportedVersion, boxes: boxes)
    }
}

// MARK: - Predefined TweakTradeDestination

public final class TweakTradeActivityDestination: TweakTradeDestination {
    public let name = "Activity View"
    public let needsNotifyCompletion = false
    
    private let fileName: String
    private weak var viewController: UIViewController?
    
    init(fileName: String, fromVC viewController: UIViewController) {
        self.fileName = fileName
        self.viewController = viewController
    }
    
    public func ship(_ cargo: TweakTradeCargo, completion: @escaping (Error?) -> Void) {
        let url = _getURL(for: fileName)
        _createFile(at: url, content: cargo)
        _showActivityView(for: url)
        completion(nil)
    }
    
    private func _getURL(for fileName: String) -> URL {
        let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return cacheURL.appendingPathComponent(fileName)
    }
    
    private func _createFile(at url: URL, content: TweakTradeCargo) {
        FileManager.default.createFile(atPath: url.path, contents: content, attributes: nil)
    }
    
    private func _showActivityView(for url: URL) {
        viewController?.present(UIActivityViewController(activityItems: [url], applicationActivities: nil), animated: true)
    }
}

public final class TweakTradePasteboardDestination: TweakTradeDestination {
    public let name = "Pasteboard"
    
    public func ship(_ cargo: TweakTradeCargo, completion: @escaping (Error?) -> Void) {
        UIPasteboard.general.string = String(data: cargo, encoding: .utf8)!
        completion(nil)
    }
}

final class TweakTradeConsoleDestination: TweakTradeDestination {
    let name = "Console"
    
    func ship(_ cargo: TweakTradeCargo, completion: @escaping (Error?) -> Void) {
        print(String(data: cargo, encoding: .utf8)!)
        completion(nil)
    }
}
