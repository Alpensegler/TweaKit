//
//  TweakError.swift
//  TweaKit
//
//  Created by cokile
//

import Foundation

/// `TweakError` is the error type returned by TweaKit.
/// It encompasses a few different types of errors, each with their own associated reasons.
public enum TweakError: LocalizedError {
    /// Error for trade.
    case trade(reason: TradeReason)

    public var errorDescription: String? {
        switch self {
        case .trade(let reason):
            return reason.errorDescription
        }
    }
}

public extension TweakError {
    /// Error reason for trade.
    enum TradeReason {
        /// The traded tweak is not live in any context.
        case contextNotFound
        /// The json data is corrupted, due to `inner`.
        case corruptedData(inner: Error)
        /// The import source has unsupported version.
        case unsupportedVersion(expected: Int, current: Int)
        /// Failed to receive json data from source.
        case sourceFailure(inner: Error)
        /// Failed to send json data to source.
        case destinationFailure(inner: Error)
        /// The trade value cannot be unmarshalled.
        case unmarshalFailure
        /// The trade value is unmarshalled successfully but can't pass the validation.
        case unmarshaledValidationFailure

        var errorDescription: String {
            switch self {
            case .contextNotFound:
                return "tweak context is missing."
            case .corruptedData(let inner):
                return "data corrupted, due to \(inner)."
            case let .unsupportedVersion(expected, current):
                return "unsupported version, expected: <= \(expected), current: \(current)."
            case .sourceFailure(let inner):
                return "receiving from resource failed, due to \(inner)"
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
