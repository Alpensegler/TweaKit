//
//  TweakImporter.swift
//  TweaKit
//
//  Created by cokile
//

import Foundation

/// A type that represents a import source.
public protocol TweakTradeSource {
    /// The name of the source.
    ///
    /// This will be displayed in the tweak UI.
    var name: String { get }
    
    /// Receives tweak data.
    ///
    /// - Parameters:
    ///   - completion: The handler block for you to execute after you have performed the operation.
    ///     This block has no return value and takes the following parameter:
    ///
    ///     **result**: The operation result. The `Success` type is ``TweakTradeCargo`` and the `Failure` type is `Error`.
    func receive(completion: @escaping (Result<TweakTradeCargo, Error>) -> Void)
}

final class TweakImporter {
    private weak var trader: TweakTrader?
    
    init(trader: TweakTrader) {
        self.trader = trader
    }
}

extension TweakImporter {
    func `import`(from source: TweakTradeSource, completion: ((TweakError?) -> Void)?) {
        dispatchPrecondition(condition: .onQueue(.main))
        
        source.receive { [unowned self] result in
            switch result {
            case .success(let cargo):
                do {
                    var container = try _disassemble(cargo: cargo)
                    container = try _inspect(container: container)
                    try _store(container: container)
                    completion?(nil)
                } catch {
                    completion?(error as? TweakError)
                }
            case .failure(let error):
                completion?(.trade(reason: .sourceFailure(inner: error)))
            }
        }
    }
}

private extension TweakImporter {
    func _disassemble(cargo: TweakTradeCargo) throws -> TweakTradeContainer {
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(TweakTradeContainer.self, from: cargo)
        } catch {
            throw TweakError.trade(reason: .corruptedData(inner: error))
        }
    }
    
    func _inspect(container: TweakTradeContainer) throws -> TweakTradeContainer {
        if container.version > Constants.Trade.supportedVersion {
            throw TweakError.trade(reason: .unsupportedVersion(expected: Constants.Trade.supportedVersion, current: container.version))
        }
        return container
    }
    
    func _store(container: TweakTradeContainer) throws {
        guard let context = trader?.context else {
            throw TweakError.trade(reason: .contextNotFound)
        }
        
        for box in container.boxes {
            let id = [box.list, box.section, box.tweak].joined(separator: Constants.idSeparator)
            
            guard let tweak = context.tweaks.first(where: { $0.id == id }) else {
                Logger.log("👊 tweak with id: (\(id)) is not in context \(context.name)")
                continue
            }
            
            guard let tradableTweak = tweak as? AnyTradableTweak else {
                Logger.log("❕ tweak with id: (\(id)) is not tradable")
                continue
            }
            
            if tradableTweak.didChangeManually && !tradableTweak.isImportedValueTrumpsManuallyChangedValue {
                Logger.log("⏭ tweak with id: (\(id)) did change manually and is import value is not trump over manually changed value")
                continue
            }
            
            let result = tradableTweak.rawData(from: box.value)
            switch result {
            case .success(let data):
                if let storedData = context.store.rawData(forKey: id), storedData == data {
                    Logger.log("⏩ tweak with id: (\(id)) already has value: \(box.value)")
                } else {
                    context.store.setRawData(data, forKey: id)
                    Logger.log("✅ tweak with id: (\(id)) value changed to: \(box.value)")
                }
            case .failure(let error):
                Logger.log("❌ tweak with id: (\(id)) mismatch with source: \(box.value), error: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Predefined TweakTradeSource

public final class TweakTradeFileSource: TweakTradeSource {
    public let name: String
    private let filePath: String
    
    public init(name: String, filePath: String) {
        self.name = name
        self.filePath = filePath
    }
    
    public func receive(completion: @escaping (Result<TweakTradeCargo, Error>) -> Void) {
        do {
            let cargo = try TweakTradeCargo(contentsOf: URL(fileURLWithPath: filePath), options: .mappedRead)
            completion(.success(cargo))
        } catch {
            completion(.failure(error))
        }
    }
}
