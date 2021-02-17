//
//  HitOutsideView.swift
//  TweaKit
//
//  Created by cokile
//

import UIKit

class HitOutsideView: UIView {
    var extendInset: UIEdgeInsets = .zero
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard isUserInteractionEnabled, !isHidden, alpha > 0.001, frame.width > 0, frame.height > 0 else {
            return super.point(inside: point, with: event)
        }
        
        let hitRect = bounds.inset(by: extendInset)
        if hitRect.width <= 0 || hitRect.height <= 0 {
            return super.point(inside: point, with: event)
        }
        
        return hitRect.contains(point)
    }
}

final class HitOutsideButton: UIButton {
    var extendInset: UIEdgeInsets = .zero
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard isUserInteractionEnabled, !isHidden, alpha > 0.001, frame.width != 0, frame.height != 0 else {
            return super.point(inside: point, with: event)
        }
        
        let hitRect = bounds.inset(by: extendInset)
        if hitRect.width <= 0 || hitRect.height <= 0 {
            return super.point(inside: point, with: event)
        }
        
        return hitRect.contains(point)
    }
}

extension UIEdgeInsets {
    init(inset: CGFloat) {
        self.init(top: inset, left: inset, bottom: inset, right: inset)
    }
    
    init(horizontal: CGFloat = 0, vertical: CGFloat = 0) {
        self.init(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
    }
}
