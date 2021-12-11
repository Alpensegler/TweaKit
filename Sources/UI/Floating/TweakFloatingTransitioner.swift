//
//  TweakFloatingTransitioner.swift
//  TweaKit
//
//  Created by cokile
//

import UIKit

final class TweakFloatingTransitioner {
    private var primaryParticipant: TweakFloatingPrimaryParticipant?
    private var secondaryParticipants: [TweakFloatingParticipantCategory: TweakFloatingSecondaryParticipant] = [:]
    private var audiences: [AnyWeakTweakFloatingAudience] = []
    
    private unowned var context: TweakContext
    
    deinit {
        _releaseAllAudiences()
    }
    
    init(context: TweakContext) {
        self.context = context
    }
}

extension TweakFloatingTransitioner {
    func animateTransition(from: TweakFloatingParticipant, to: TweakFloatingSecondaryParticipant, tweaks: [AnyTweak]) {
        if from.category == to.category { return }
        _reload(secondary: to, tweaks: tweaks)
        _upsertParticipants(from: from, to: to)
        _animateParticipants(from: from, to: to)
    }
    
    func animateBackToPrimary(from: TweakFloatingSecondaryParticipant) {
        guard let primary = primaryParticipant else { return }
        _animateParticipants(from: from, to: primary) { [weak self] in
            self?._releaseParticipants()
            self?._releaseLegacyAudiences()
        }
    }
}

extension TweakFloatingTransitioner {
    func addAudience(_ audience: TweakFloatingAudience) {
        audiences.append(.init(audience))
    }
    
    func removeAudience(_ audience: TweakFloatingAudience) {
        audiences.removeAll { $0.audience === audience }
    }
}

extension TweakFloatingTransitioner {
    func ballPosition() -> CGPoint {
        context.showingWindow.map(TweakFloatingBall.position(in:)) ?? .zero
    }
}

private extension TweakFloatingTransitioner {
    func _upsertParticipants(from: TweakFloatingParticipant, to: TweakFloatingParticipant) {
        if let from = from as? TweakFloatingPrimaryParticipant {
            primaryParticipant = from
        } else if let from = from as? TweakFloatingSecondaryParticipant {
            secondaryParticipants[from.category] = from
        }

        if let to = to as? TweakFloatingSecondaryParticipant {
            secondaryParticipants[to.category] = to
        }
    }
    
    func _animateParticipants(from: TweakFloatingParticipant, to: TweakFloatingParticipant, completion: (() -> Void)? = nil) {
        _notifyAudiences { $0.willTransit(fromCategory: from.category, toCategory: to.category) }
        from.prepareTransition(to: to.category)
        to.prepareTransition(from: from.category)
        CATransaction.begin()
        CATransaction.setCompletionBlock { [unowned self] in
            from.completeTransition(to: to.category)
            to.completeTransition(from: from.category)
            _notifyAudiences { $0.didTransit(fromCategory: from.category, toCategory: to.category) }
            completion?()
        }
        _notifyAudiences { $0.transit(fromCategory: from.category, toCategory: to.category) }
        from.transit(to: to.category)
        to.transit(from: from.category)
        CATransaction.commit()
    }
    
    func _reload(secondary: TweakFloatingSecondaryParticipant, tweaks: [AnyTweak]) {
        secondary.reload(withTweaks: tweaks)
    }
    
    func _notifyAudiences(_ notify: (TweakFloatingAudience) -> Void) {
        audiences.forEach(notify)
    }
    
    func _releaseParticipants() {
        primaryParticipant = nil
        secondaryParticipants.removeAll()
    }
    
    func _releaseLegacyAudiences() {
        audiences.removeAll { $0.audience == nil }
    }
    
    func _releaseAllAudiences() {
        audiences.removeAll()
    }
}

private final class AnyWeakTweakFloatingAudience: TweakFloatingAudience {
    private(set) weak var audience: TweakFloatingAudience?
    
    init(_ audience: TweakFloatingAudience) {
        self.audience = audience
    }
    
    func willTransit(fromCategory: TweakFloatingParticipantCategory, toCategory: TweakFloatingParticipantCategory) {
        audience?.willTransit(fromCategory: fromCategory, toCategory: toCategory)
    }
    
    func transit(fromCategory: TweakFloatingParticipantCategory, toCategory: TweakFloatingParticipantCategory) {
        audience?.transit(fromCategory: fromCategory, toCategory: toCategory)
    }
    
    func didTransit(fromCategory: TweakFloatingParticipantCategory, toCategory: TweakFloatingParticipantCategory) {
        audience?.didTransit(fromCategory: fromCategory, toCategory: toCategory)
    }
}
