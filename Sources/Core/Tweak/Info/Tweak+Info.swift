//
//  Tweak+Info.swift
//  TweaKit
//
//  Created by cokile
//

import Foundation

extension Tweak {
    public typealias ValueTransformer = (Value) -> Value
    
    @discardableResult
    public func setValueTransformer(_ getter: @escaping ValueTransformer) -> Self {
        info[.valueTransformer] = getter
        return self
    }
    
    var valueTransformer: ValueTransformer? {
        info[.valueTransformer]
    }
}

extension AnyTweak {
    @discardableResult
    public func disableUserInteraction() -> Self {
        info[.isUserInteractionEnabled] = false
        return self
    }
    
    var isUserInteractionEnabled: Bool {
        info[.isUserInteractionEnabled, default: true]
    }
}

extension AnyTradableTweak {
    @discardableResult
    public func addExportPreset(_ preset: String) -> Self {
        info[.exportPresets, default: Set<String>()].insert(preset)
        return self
    }
    
    var exportPresets: Set<String> {
        info[.exportPresets, default: Set<String>()]
    }
}

extension AnyTradableTweak {
    @discardableResult
    public func setImportedValueTrumpsManuallyChangedValue() -> Self {
        info[.importedValueTrumpsManuallyChangedValue] = true
        return self
    }
    
    var isImportedValueTrumpsManuallyChangedValue: Bool {
        info[.importedValueTrumpsManuallyChangedValue, default: false]
    }
}

extension AnyTweak {
    var didChangeManually: Bool {
        get { info.persistent(forKey: .didChangeManually) ?? false }
        set { info.setPersistent(newValue, forKey: .didChangeManually, override: true) }
    }
}

extension TweakInfo.Key where InfoType == TweakInfo.KeyType.Transient {
    static let valueTransformer: TweakInfo.Key<InfoType> = "valueTransformer"
    static let isUserInteractionEnabled: TweakInfo.Key<InfoType> = "isUserInteractionEnabled"
    static let exportPresets: TweakInfo.Key<InfoType> = "exportPresets"
    static let importedValueTrumpsManuallyChangedValue: TweakInfo.Key<InfoType> = "importedValueTrumpsManuallyChangedValue"
}

extension TweakInfo.Key where InfoType == TweakInfo.KeyType.Persistent {
    static let didChangeManually: TweakInfo.Key<InfoType> = "didChangeManually"
}

extension AnyTweak {
    // NOTICE: Don't forget to check if any newly added infos should be reset.
    func resetInfo() {
        didChangeManually = false
    }
}
