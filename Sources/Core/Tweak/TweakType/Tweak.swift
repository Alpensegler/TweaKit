//
//  Tweak.swift
//  TweaKit
//
//  Created by cokile
//

import Foundation

@propertyWrapper
public class Tweak<Value: Storable>: AnyTweak, TweakType {
    public let name: String
    let defaultValue: Value
    private var didRegister = false
    
    public weak var section: TweakSection? {
        willSet {
            assert(section == nil, "Tweak \(name) already in section \(section!.name)")
        }
    }
    public let info: TweakInfo
    public var currentValue: Storable {
        rawValue
    }
    public var primaryViewReuseID: String {
        fatalError("\(#function) should be implemented in subclass for \(id)")
    }
    public var primaryView: TweakPrimaryView {
        fatalError("\(#function) should be implemented in subclass for \(id)")
    }
    public var hasSecondaryView: Bool {
        fatalError("\(#function) should be implemented in subclass for \(id)")
    }
    public var secondaryView: TweakSecondaryView? {
        fatalError("\(#function) should be implemented in subclass for \(id)")
    }
    
    public final var wrappedValue: Value {
        if let valueTransformer = valueTransformer {
            return valueTransformer(rawValue)
        } else {
            return rawValue
        }
    }
    public final var projectedValue: Tweak<Value> {
        self
    }
    final var storedValue: Value? {
        if let value: Value = context.flatMap({ $0.store.value(forKey: id) }) {
            return value
        } else {
            return nil
        }
    }
    /// The final value will be applied by value transformer(if has).
    var rawValue: Value {
        storedValue ?? defaultValue
    }
    
    deinit {
        stopObservingValueChange()
    }
    
    init(name: String, default: Value) {
        assert(!name.contains(Constants.idSeparator), "Tweak name: \(name) should not contain \(Constants.idSeparator)")
        
        self.name = name
        self.defaultValue = `default`
        self.info = TweakInfo()
        self.info.tweak = self
    }
    
    func validate(unmarshaled: Value) -> Bool where Value: TradedTweakable {
        true
    }
}

public extension Tweak {
    func register(in context: TweakContext) {
        if didRegister { return }
        didRegister = true
        
        info.persist(in: context)
    }
}

public extension Tweak {
    func stopObservingValueChange(token: NotifyToken? = nil) {
        if let token = token {
            context?.store.stopNotifying(ForToken: token)
        } else {
            context?.store.stopNotifying(forKey: id)
        }
    }
    
    func startObservingValueChange(_ handler: @escaping (Value, Value, Bool) -> Void) -> NotifyToken {
        guard let context = context else {
            fatalError("Tweak \(name) is not in context yet")
        }
        return context.store.startNotifying(forKey: id) { [weak self] old, new, manually in
            guard let self = self else { return }
            let oldValue: Value = old.flatMap { Value.convert(from: $0) } ?? self.defaultValue
            let newValue: Value = new.flatMap { Value.convert(from: $0) } ?? self.defaultValue
            handler(oldValue, newValue, manually)
        }
    }
}

extension Tweak: AnyTradableTweak where Value: TradedTweakable {
    public func rawData(from value: TweakTradeValue) -> Result<Data, TweakError> {
        guard let unmarshaled = Value.unmarshal(from: value) else {
            return .failure(.trade(reason: .unmarshalFailure))
        }
        if validate(unmarshaled: unmarshaled), unmarshaled.validate(with: defaultValue) {
            return .success(unmarshaled.convertToData())
        } else {
            return .failure(.trade(reason: .unmarshaledValidationFailure))
        }
    }
    
    public func tradeValue() -> TweakTradeValue {
        wrappedValue.marshalToValue()
    }
}
