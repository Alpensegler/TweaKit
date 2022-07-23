//
//  UIColor+Extension.swift
//  TweaKit
//
//  Created by cokile
//

import UIKit

extension UIColor {
    convenience init(rgba: RGBA) {
        self.init(r: rgba.r, g: rgba.b, b: rgba.b, a: rgba.a)
    }

    convenience init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat = 1) {
        self.init(red: r / 255, green: g / 255, blue: b / 255, alpha: a.clamped(from: 0, to: 1))
    }

    convenience init(light: UIColor, dark: UIColor) {
        self.init(dynamicProvider: { $0.userInterfaceStyle == .dark ? dark : light })
    }
}

extension UIColor {
    // r, g, b: 0...255, a: 0...1
    struct RGBA: Equatable {
        let r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat
    }

    var rgba: RGBA {
        if let rgba = objc_getAssociatedObject(self, &rgbaKey) as? RGBA {
            return rgba
        }
        var (r, g, b, a): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgba = RGBA(r: r * 255, g: g * 255, b: b * 255, a: a.rounded(to: .hundredth))
        objc_setAssociatedObject(self, &rgbaKey, rgba, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return rgba
    }

    convenience init?(hexString: String) {
        let hexString = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: Constants.Color.hexPrefix, with: "")
            .replacingOccurrences(of: "0x", with: "")

        guard hexString.count >= 6, let hex64 = Int64(hexString, radix: 16) else { return nil }
        let a = hexString.count > 6 ? CGFloat((hex64 & 0xFF000000) >> 24) / 255 : 1
        let hex = Int(hex64)
        let r = CGFloat((hex & 0xFF0000) >> 16)
        let g = CGFloat((hex & 0x00FF00) >> 8)
        let b = CGFloat((hex & 0x0000FF) >> 0)
        self.init(r: r, g: g, b: b, a: a)
    }

    func toRGBHexString(includeAlpha: Bool = false, includePrefix: Bool = true) -> String {
        let rgba = rgba
        let (r, g, b, a) = (rgba.r, rgba.g, rgba.b, rgba.a * 255)

        var format = String(repeating: "%02lX", count: includeAlpha ? 4 : 3)
        if includePrefix {
            format = Constants.Color.hexPrefix.appending(format)
        }
        if includeAlpha {
            return String(format: format, lroundf(Float(a)), lroundf(Float(r)), lroundf(Float(g)), lroundf(Float(b)))
        } else {
            return String(format: format, lroundf(Float(r)), lroundf(Float(g)), lroundf(Float(b)))
        }
    }
}

private var rgbaKey: UInt8 = 0
