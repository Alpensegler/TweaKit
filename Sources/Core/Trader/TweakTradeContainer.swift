//
//  TweakTradeContainer.swift
//  TweaKit
//
//  Created by cokile
//

import Foundation

struct TweakTradeContainer: Codable {
    let version: Int
    let boxes: [TweakTradeBox]
    
    // output is sorted by CodingKeys
    enum CodingKeys: String, CodingKey {
        case version = "supported_version"
        case boxes = "tweaks"
    }
}

struct TweakTradeBox: Codable {
    let list: String
    let section: String
    let tweak: String
    let value: TweakTradeValue
}

/// A type with values that represent the a json value.
public enum TweakTradeValue: Codable, CustomStringConvertible {
    case bool(Bool)
    case int(Int)
    case uInt(UInt)
    case double(Double)
    case string(String)
    case array([TweakTradeValue])
    
    public var description: String {
        switch self {
        case .bool(let value):
            return value.description
        case .int(let value):
            return value.description
        case .uInt(let value):
            return value.description
        case .double(let value):
            return value.description
        case .string(let value):
            return value.description
        case .array(let value):
            return value.description
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else if let value = try? container.decode(Int.self) {
            self = .int(value)
        } else if let value = try? container.decode(UInt.self) {
            self = .uInt(value)
        } else if let value = try? container.decode(Double.self) {
            self = .double(value)
        } else if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode([TweakTradeValue].self) {
            self = .array(value)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "value cannot be decoded")
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .bool(let value):
            try container.encode(value)
        case .int(let value):
            try container.encode(value)
        case .uInt(let value):
            try container.encode(value)
        case .double(let value):
            try container.encode(value)
        case .string(let value):
            try container.encode(value)
        case .array(let value):
            try container.encode(value)
        }
    }
}
