//
//  CoreGraphics+Extension.swift
//  TweaKit
//
//  Created by cokile
//

import CoreGraphics

extension CGFloat {
    var half: CGFloat { self * 0.5 }
}

extension CGSize {
    var halfWidth: CGFloat { width.half }
    var halfHeight: CGFloat { height.half }
}

extension CGRect {
    var halfWidth: CGFloat { width.half }
    var halfHeight: CGFloat { height.half }
}

extension CGRect {
    func scaled(by factor: CGFloat) -> CGRect {
        .init(x: minX * factor, y: minY * factor, width: width * factor, height: height * factor)
    }
}

extension CGPoint {
    func insetting(by distance: CGFloat) -> CGRect {
        .init(x: x - distance, y: y -  distance, width: distance * 2, height: distance * 2)
    }
}
