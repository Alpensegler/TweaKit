//
//  Tweak+Info.swift
//  TweaKit
//
//  Created by cokile
//

import Foundation

extension Tweak {
    /// A transformer that transforms tweak value.
    public typealias ValueTransformer = (Value) -> Value

    /// Adds a value transformer to the end of the transformer chain.
    ///
    /// Transformers are applied one by one in the chain.
    ///
    /// - Parameters:
    ///   - transformer: The transformer.
    /// - Returns: The current tweak.
    @discardableResult
    public func addValueTransformer(_ transformer: @escaping ValueTransformer) -> Self {
        info[.valueTransformers, default: []].append(transformer)
        return self
    }

    /// Gets all the value transformers of the tweak.
    var valueTransformers: [ValueTransformer] {
        info[.valueTransformers, default: []]
    }
}

extension AnyTweak {
    /// Prevents the tweak from being changing value manually.
    ///
    /// Users can still import new value of the tweak.
    ///
    /// - Returns: The current tweak.
    @discardableResult
    public func disableUserInteraction() -> Self {
        info[.isUserInteractionEnabled] = false
        return self
    }

    /// A Boolean value that determines whether user change value of the tweak manually.
    var isUserInteractionEnabled: Bool {
        info[.isUserInteractionEnabled, default: true]
    }
}

extension AnyTradableTweak {
    /// Adds the tweak in an export preset.
    ///
    /// Tweaks are grouped in the same preset when exporting.
    ///
    /// - Parameters:
    ///   - preset: The name of the export preset.
    /// - Returns: The current tweak.
    @discardableResult
    public func addExportPreset(_ preset: String) -> Self {
        info[.exportPresets, default: Set<String>()].insert(preset)
        return self
    }

    /// Gets all the export presets of the tweak.
    var exportPresets: Set<String> {
        info[.exportPresets, default: Set<String>()]
    }
}

extension AnyTradableTweak {
    /// Tells the tweak that imported value should override the manually changed value.
    ///
    /// Users can still import new value of the tweak.
    ///
    /// - Returns: The current tweak.
    @discardableResult
    public func setImportedValueTrumpsManuallyChangedValue() -> Self {
        info[.importedValueTrumpsManuallyChangedValue] = true
        return self
    }

    // swiftlint:disable identifier_name
    /// A Boolean value that determines whether imported value should override the manually changed value of the tweak.
    var isImportedValueTrumpsManuallyChangedValue: Bool {
        info[.importedValueTrumpsManuallyChangedValue, default: false]
    }
    // swiftlint:enable identifier_name
}

extension AnyTweak {
    var didChangeManually: Bool {
        get { info.persistent(forKey: .didChangeManually) ?? false }
        set { info.setPersistent(newValue, forKey: .didChangeManually, override: true) }
    }
}

extension TweakInfo.Key where InfoType == TweakInfo.KeyType.Transient {
    static let valueTransformers: TweakInfo.Key<InfoType> = "valueTransformers"
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
