//
//  CoreAnimation+Extension.swift
//  TweaKit
//
//  Created by cokile
//

import UIKit

extension CALayer {
    func addCorner(radius: CGFloat, mask: CACornerMask = .all, continuous: Bool = true, clipsContent: Bool = false) {
        cornerRadius = radius
        maskedCorners = mask
        cornerCurve = continuous ? .continuous :.circular
        masksToBounds = clipsContent
    }
    
    func removeCorner() {
        cornerRadius = 0
    }
    
    func addShadow(color: UIColor, opacity: Float = 1, x: CGFloat = 0, y: CGFloat = 0, radius: CGFloat = 1, path: UIBezierPath? = nil) {
        shadowColor = color.cgColor
        shadowOpacity = opacity.clamped(from: 0, to: 1)
        shadowOffset = .init(width: x, height: y)
        shadowRadius = radius
        shadowPath = path?.cgPath
    }
    
    func removeShadow() {
        shadowPath = nil
        shadowColor = nil
        shadowOpacity = 0
    }
}

extension CACornerMask {
    static let top: CACornerMask = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    static let bottom: CACornerMask = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    static let left: CACornerMask = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
    static let right: CACornerMask = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
    static let all: CACornerMask = [.top, .bottom]
}

extension CABasicAnimation {
    convenience init(
        keyPath: String,
        fromValue: Any? = nil,
        toValue: Any,
        duration: Double = 0.3,
        timingFunction: CAMediaTimingFunction = .init(controlPoints: 0, 0, 0.2, 1),
        keepStay: Bool = true
    ) {
        self.init(keyPath: keyPath)
        self.fromValue = fromValue
        self.toValue = toValue
        self.duration = duration
        self.timingFunction = timingFunction
        if keepStay {
            self.fillMode = .both
            self.isRemovedOnCompletion = false
        }
    }
}

func disableImplicitAnimation(_ job: () -> Void) {
    CATransaction.begin()
    CATransaction.setDisableActions(true)
    job()
    CATransaction.commit()
}
