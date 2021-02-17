//
//  TweakError.swift
//  TweaKit
//
//  Created by cokile
//

import Foundation

public enum TweakError: LocalizedError {
    case trade(reason: TradeReason)
    
    public var errorDescription: String? {
        switch self {
        case .trade(let reason):
            return reason.errorDescription
        }
    }
}

public extension TweakError {
    enum TradeReason {
        case contextNotFound
        case corruptedData(inner: Error)
        case unsupportedVersion(expected: Int, current: Int)
        case sourceFailure(inner: Error)
        case destinationFailure(inner: Error)
        case unmarshalFailure
        case unmarshaledValidationFailure

        var errorDescription: String {
            switch self {
            case .contextNotFound:
                return "tweak context is missing."
            case .corruptedData(let inner):
                return "data corruputed, due to \(inner)."
            case let .unsupportedVersion(expected, current):
                return "unsupported version, exptected: <= \(expected), current: \(current)."
            case .sourceFailure(let inner):
                return "receiving from rsource failed, due to \(inner)"
            case .destinationFailure(let inner):
                return "shipping to destination failed, due to \(inner)"
            case .unmarshalFailure:
                return "unable to unmarshal"
            case .unmarshaledValidationFailure:
                return "unmarshaled value does not pass validation"
            }
        }
    }
}
