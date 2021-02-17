//
//  TweakSecondaryViewAnimator.swift
//  TweaKit
//
//  Created by cokile
//

import UIKit

protocol TweakSecondaryViewAnimatorDelegate: AnyObject {
    func animatorPortraitPresentTargetHeight(_ animator: TweakSecondaryViewAnimator) -> CGFloat
    func animatorDidTapBlankArea(_ animator: TweakSecondaryViewAnimator)
}

final class TweakSecondaryViewAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private let duration: TimeInterval = 0.3
    private var maskView: UIView?
    private weak var delegate: TweakSecondaryViewAnimatorDelegate?
    
    init(delegate: TweakSecondaryViewAnimatorDelegate) {
        self.delegate = delegate
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to)
        else { return }
        let container = transitionContext.containerView
        
        fromVC.beginAppearanceTransition(false, animated: true)
        toVC.beginAppearanceTransition(true, animated: true)
        let completion = {
            toVC.endAppearanceTransition()
            fromVC.endAppearanceTransition()
            transitionContext.completeTransition(true)
        }
        
        let isPresenting = fromVC === toVC.presentingViewController
        if isPresenting {
            _animateforPresentation(fromVC: fromVC, toVC: toVC, container: container, completion: completion)
        } else {
            _animateforDismissal(fromVC: fromVC, toVC: toVC, container: container, completion: completion)
        }
    }
}

private extension TweakSecondaryViewAnimator {
    func _animateforPresentation(fromVC: UIViewController, toVC: UIViewController, container: UIView, completion: @escaping () -> Void) {
        let maskView = UIView(frame: fromVC.view.bounds)
        maskView.alpha = 0
        maskView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        container.addSubview(maskView)
        maskView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(_didTapMaskView)))
        self.maskView = maskView
        
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let sizeForToVC: CGSize = UIApplication.tk_shared.isLandscape
            ? .init(width: screenHeight, height: ceil(screenHeight * 0.9))
            : .init(width: screenWidth, height: delegate?.animatorPortraitPresentTargetHeight(self) ?? 0)
        let originForToVC: CGPoint = .init(
            x: ceil((screenWidth - sizeForToVC.width).half),
            y: ceil(screenHeight - sizeForToVC.height))
        toVC.view.frame = .init(origin: originForToVC, size: sizeForToVC)
        toVC.view.transform = .init(translationX: 0, y: sizeForToVC.height)
        container.addSubview(toVC.view)
        
        let animationKey = "presentation"
        let maskAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity), fromValue: 0, toValue: 1, duration: duration)
        let toVCAnimation = CABasicAnimation(keyPath: "transform.translation.y", fromValue: sizeForToVC.height, toValue: 0, duration: duration)
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            maskView.alpha = 1
            toVC.view.transform = .identity
            maskView.layer.removeAnimation(forKey: animationKey)
            toVC.view.layer.removeAnimation(forKey: animationKey)
            completion()
        }
        maskView.layer.add(maskAnimation, forKey: animationKey)
        toVC.view.layer.add(toVCAnimation, forKey: animationKey)
        CATransaction.commit()
    }
    
    func _animateforDismissal(fromVC: UIViewController, toVC: UIViewController, container: UIView, completion: @escaping () -> Void) {
        let maskAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity), fromValue: 1, toValue: 0, duration: duration)
        let fromVCAnimation = CABasicAnimation(keyPath: "transform.translation.y", fromValue: 0, toValue: fromVC.view.frame.height, duration: duration)
        CATransaction.begin()
        CATransaction.setCompletionBlock { [weak self] in
            self?.maskView?.removeFromSuperview()
            self?.maskView = nil
            fromVC.view.removeFromSuperview()
            completion()
        }
        maskView?.layer.add(maskAnimation, forKey: nil)
        fromVC.view.layer.add(fromVCAnimation, forKey: nil)
        CATransaction.commit()
    }
}

private extension TweakSecondaryViewAnimator {
    @objc func _didTapMaskView(_ gesture: UITapGestureRecognizer) {
        delegate?.animatorDidTapBlankArea(self)
    }
}
