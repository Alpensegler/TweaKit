//
//  Storable.swift
//  TweaKit
//
//  Created by cokile
//

import UIKit

public protocol Storable {
    static func convert(from data: Data) -> Self?
    func convertToData() -> Data
}

extension Storable where Self: Numeric {
    public static func convert(from data: Data) -> Self? {
        var value: Self = .zero
        let size = withUnsafeMutableBytes(of: &value, { data.copyBytes(to: $0) })
        assert(size == MemoryLayout.size(ofValue: value))
        return value
    }
    
    public func convertToData() -> Data {
        var value = self
        return .init(bytes: &value, count: MemoryLayout<Self>.size)
    }
}
extension Int: Storable { }
extension Int8: Storable { }
extension Int16: Storable { }
extension Int32: Storable { }
extension Int64: Storable { }
extension UInt: Storable { }
extension UInt8: Storable { }
extension UInt16: Storable { }
extension UInt32: Storable { }
extension UInt64: Storable { }
extension Float: Storable { }
extension Double: Storable { }
extension CGFloat: Storable { }

extension Bool: Storable {
    public static func convert(from data: Data) -> Bool? {
        guard let number = Int8.convert(from: data) else { return nil }
        if number == 1 {
            return true
        } else if number == 0 {
            return false
        } else {
            return nil
        }
    }
    
    public func convertToData() -> Data {
        if self {
            return Int8(1).convertToData()
        } else {
            return Int8(0).convertToData()
        }
    }
}

extension String: Storable {
    public static func convert(from data: Data) -> String? {
        String(data: data, encoding: .utf8)
    }
    
    public func convertToData() -> Data {
        data(using: .utf8) ?? .init()
    }
}

extension UIColor: Storable {
    public static func convert(from data: Data) -> Self? {
        String.convert(from: data).flatMap { UIColor(hexString: $0) as? Self }
    }
    
    public func convertToData() -> Data {
        toRGBHexString(includeAlpha: true).convertToData()
    }
}

extension Array: Storable where Element: Storable {
    public static func convert(from data: Data) -> [Element]? {
        let datas = try? JSONDecoder().decode([Data].self, from: data)
        let array = datas?.compactMap { Element.convert(from: $0) }
        return array?.count == datas?.count ? array : nil
    }
    
    // swiftlint:disable force_try
    public func convertToData() -> Data {
        return try! JSONEncoder().encode(map { $0.convertToData() })
    }
    // swiftlint:enable force_try
}

extension Storable where Self: RawRepresentable, RawValue: Storable {
    public static func convert(from data: Data) -> Self? {
        RawValue.convert(from: data).flatMap { self.init(rawValue: $0) }
    }
    
    public func convertToData() -> Data {
        rawValue.convertToData()
    }
}
