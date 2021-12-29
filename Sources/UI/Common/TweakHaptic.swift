//
//  TweakHaptic.swift
//  TweaKit
//
//  Created by cokile
//

import UIKit

enum Haptic {
    enum Feedback {
        case selection
        case impact(UIImpactFeedbackGenerator.FeedbackStyle = .light)
    }
    
    static func occur(_ feedback: Feedback) {
        switch feedback {
        case .selection:
            let generator = UISelectionFeedbackGenerator()
            generator.selectionChanged()
        case .impact(let style):
            let generator = UIImpactFeedbackGenerator(style: style)
            generator.impactOccurred()
        }
    }
}
