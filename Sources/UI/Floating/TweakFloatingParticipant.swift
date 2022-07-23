//
//  TweakFloatingParticipant.swift
//  TweaKit
//
//  Created by cokile
//

import Foundation

// MARK: - TweakFloatingParticipant

enum TweakFloatingParticipantCategory {
    case normalList
    case searchList
    case ball
    case panel
}

protocol TweakFloatingParticipant: AnyObject {
    var category: TweakFloatingParticipantCategory { get }

    func prepareTransition(to category: TweakFloatingParticipantCategory)
    func prepareTransition(from category: TweakFloatingParticipantCategory)
    func transit(to category: TweakFloatingParticipantCategory)
    func transit(from category: TweakFloatingParticipantCategory)
    func completeTransition(from category: TweakFloatingParticipantCategory)
    func completeTransition(to category: TweakFloatingParticipantCategory)
}

extension TweakFloatingParticipant {
    func prepareTransition(to category: TweakFloatingParticipantCategory) { }
    func prepareTransition(from category: TweakFloatingParticipantCategory) { }
    func completeTransition(from category: TweakFloatingParticipantCategory) { }
    func completeTransition(to category: TweakFloatingParticipantCategory) { }
}

protocol TweakFloatingPrimaryParticipant: TweakFloatingParticipant {
}

protocol TweakFloatingSecondaryParticipant: TweakFloatingParticipant {
    func reload(withTweaks tweaks: [AnyTweak])
}

// MARK: - TweakFloatingAudience

protocol TweakFloatingAudience: AnyObject {
    func willTransit(fromCategory: TweakFloatingParticipantCategory, toCategory: TweakFloatingParticipantCategory)
    func transit(fromCategory: TweakFloatingParticipantCategory, toCategory: TweakFloatingParticipantCategory)
    func didTransit(fromCategory: TweakFloatingParticipantCategory, toCategory: TweakFloatingParticipantCategory)
}

extension TweakFloatingAudience {
    func willTransit(fromCategory: TweakFloatingParticipantCategory, toCategory: TweakFloatingParticipantCategory) { }
    func transit(fromCategory: TweakFloatingParticipantCategory, toCategory: TweakFloatingParticipantCategory) { }
    func didTransit(fromCategory: TweakFloatingParticipantCategory, toCategory: TweakFloatingParticipantCategory) { }
}

extension TweakFloatingAudience {
    func startListeningFloating(in context: TweakContext) {
        context.floatingTransitioner?.addAudience(self)
    }

    func stopListeningFloating(in context: TweakContext) {
        context.floatingTransitioner?.removeAudience(self)
    }
}
