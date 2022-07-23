//
//  TweakPrimaryViewContainer.swift
//  TweaKit
//
//  Created by cokile
//

import UIKit

protocol TweakPrimaryViewContainerDelegate: AnyObject {
    func primaryViewContainerNeedsLayout(_ container: TweakPrimaryViewContainer)
}

final class TweakPrimaryViewContainer: HitOutsideView {
    private weak var tweak: AnyTweak?
    private var primaryView: TweakPrimaryView?
    private var primaryViewConstraints: [NSLayoutConstraint] = []
    private var notifyToken: NotifyToken? {
        didSet { oldValue?.invalidate() }
    }

    private weak var delegate: TweakPrimaryViewContainerDelegate?

    deinit {
        notifyToken?.invalidate()
    }

    init(delegate: TweakPrimaryViewContainerDelegate) {
        self.delegate = delegate
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TweakPrimaryViewContainer {
    override var intrinsicContentSize: CGSize {
        primaryView?.intrinsicContentSize ?? .zero
    }
}

extension TweakPrimaryViewContainer {
    func reloadWith(tweak: AnyTweak, recycler: TweakPrimaryViewRecycler) {
        let newPrimaryView = _getPrimaryView(forTweak: tweak, recycler: recycler)
        defer { primaryView = newPrimaryView }
        self.tweak = tweak
        _switch(to: newPrimaryView, recycler: recycler)
        _layout(newPrimaryView)
        if _reload(tweak: tweak, in: newPrimaryView) {
            _setNeedsLayout()
        }
    }

    func recycle(by recycler: TweakPrimaryViewRecycler) {
        tweak = nil
        notifyToken = nil
        guard let view = primaryView else { return }
        recycler.enqueue(view)
        primaryView = nil
    }
}

private extension TweakPrimaryViewContainer {
    func _getPrimaryView(forTweak tweak: AnyTweak, recycler: TweakPrimaryViewRecycler) -> TweakPrimaryView {
        if let view = primaryView, view.reuseID == tweak.primaryViewReuseID {
            return view
        } else {
            return recycler.dequeue(withReuseID: tweak.primaryViewReuseID) ?? tweak.primaryView
        }
    }

    func _switch(to newPrimaryView: TweakPrimaryView, recycler: TweakPrimaryViewRecycler) {
        if newPrimaryView === primaryView { return }
        if let view = primaryView {
            recycler.enqueue(view)
        }
        extendInset = newPrimaryView.extendInset
        addSubview(newPrimaryView)
    }

    func _reload(tweak: AnyTweak, in newPrimaryView: TweakPrimaryView) -> Bool {
        let tweakID = tweak.id
        notifyToken = tweak.context?.store.startNotifying(forKey: tweakID) { [weak self] _, _, manually in
            guard let tweak = self?.tweak, tweak.id == tweakID else { return }
            if self?.primaryView?.reload(withTweak: tweak, manually: manually) == true {
                self?._setNeedsLayout()
            }
        }
        return newPrimaryView.reload(withTweak: tweak, manually: false) || primaryView?.reuseID != newPrimaryView.reuseID
    }

    func _layout(_ newPrimaryView: TweakPrimaryView) {
        if newPrimaryView !== primaryView {
            newPrimaryView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.deactivate(primaryViewConstraints)
            primaryViewConstraints = [
                newPrimaryView.leadingAnchor.constraint(equalTo: leadingAnchor),
                newPrimaryView.trailingAnchor.constraint(equalTo: trailingAnchor),
                newPrimaryView.topAnchor.constraint(equalTo: topAnchor),
                newPrimaryView.bottomAnchor.constraint(equalTo: bottomAnchor),
            ]
            NSLayoutConstraint.activate(primaryViewConstraints)
        }
    }

    func _setNeedsLayout() {
        invalidateIntrinsicContentSize()
        delegate?.primaryViewContainerNeedsLayout(self)
    }
}
