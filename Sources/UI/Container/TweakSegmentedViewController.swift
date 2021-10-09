//
//  TweakSegmentedViewController.swift
//  TweaKit
//
//  Created by cokile
//

import UIKit

// MARK: - TweakSegmentedViewController

final class TweakSegmentedViewController: UIViewController {
    private lazy var titleCollectionView = _titleCollectionView()
    private lazy var contentCollectionView = _contentCollectionView()
    private lazy var seperator = _seperator()
    private lazy var indicator = _indicator()
    
    private unowned var context: TweakContext
    private unowned var initialTweak: AnyTweak?
    private unowned var initialList: TweakList?
    
    private(set) var currentIndex = 0
    private var duringTransition = false
    private var duringAutoScrolling = false
    private var previousOffsetX: CGFloat = 0
    private var previousScrollState: ContentScrollState?
    private var titleWidthCache: [String: CGFloat]
    
    deinit {
        _unregisterNotifications()
    }
    
    init(context: TweakContext) {
        self.context = context
        self.titleWidthCache = .init(minimumCapacity: context.lists.count)
        super.init(nibName: nil, bundle: nil)
    }
    
    init(context: TweakContext, initialTweak: AnyTweak?) {
        self.context = context
        self.initialTweak = initialTweak
        self.titleWidthCache = .init(minimumCapacity: context.lists.count)
        super.init(nibName: nil, bundle: nil)
    }
    
    init(context: TweakContext, initialList: TweakList?) {
        self.context = context
        self.initialList = initialList
        self.titleWidthCache = .init(minimumCapacity: context.lists.count)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TweakSegmentedViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        _setupUI()
        _registerNotifications()
        _initialLocating()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        _layoutUI()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        _beginTransition()
        _keepContentUponRotation()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if previousTraitCollection?.userInterfaceStyle == traitCollection.userInterfaceStyle {
            _correctTitleProgress()
        }
    }
}

extension TweakSegmentedViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionView {
        case contentCollectionView:
            return collectionView.frame.size
        case titleCollectionView:
            return .init(width: _width(of: _title(at: indexPath.item)), height: collectionView.frame.height)
        default:
            return .zero
        }
    }
}

extension TweakSegmentedViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        context.lists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case contentCollectionView:
            let cell = collectionView.dequeue(cell: TweakSegmentContentCell.self, for: indexPath)
            cell.configList(_list(at: indexPath.item), context: context, in: self)
            return cell
        case titleCollectionView:
            let cell = collectionView.dequeue(cell: TweakSegmentTitleCell.self, for: indexPath)
            cell.configTitle(_title(at: indexPath.item))
            cell.configProgress(indexPath.item == currentIndex ? 1 : 0)
            return cell
        default:
            return UICollectionViewCell()
        }
    }
}

extension TweakSegmentedViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        collectionView === titleCollectionView
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let oldIndex = currentIndex
        if indexPath.item == currentIndex { return }
        currentIndex = indexPath.item
        _beginAutoScrolling()
        _autoScrollTitle(from: _indexPath(of: oldIndex), to: indexPath, animated: true)
        _autoScrollContent(from: _indexPath(of: oldIndex), to: indexPath, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard collectionView === titleCollectionView else { return }
        _resetTitleSelection(forCell: cell, at: indexPath)
    }
}

extension TweakSegmentedViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView === contentCollectionView else { return }
        if duringTransition || duringAutoScrolling { return }
        guard let state = _calculateScrollState() else {
            _clearScrollState()
            return
        }
        _updateIndicator(with: state)
        _updateTitle(with: state)
        _updateCurrentIndex(with: state)
        _recordScrollState(state)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard scrollView === contentCollectionView else { return }
        _recordContentOffset()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView === contentCollectionView else { return }
        if duringTransition || duringAutoScrolling { return }
        _clearScrollState()
        _revealTitleAfterPaging()
        DispatchQueue.main.async { [unowned self] in
            _correctIndicatorAfterPaging()
            _correctTitleProgress()
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        guard scrollView === contentCollectionView else { return }
        _endAutoScrolling()
    }
}

private extension TweakSegmentedViewController {
    func _setupUI() {
        title = context.name
        view.backgroundColor = .clear // use the same bg color with navi vc
        view.addSubview(seperator)
        if needsTitle {
            view.addSubview(titleCollectionView)
            titleCollectionView.setIndicator(indicator)
            DispatchQueue.main.async { [unowned self] in
                indicator.frame = _indicatorFrame(of: currentIndex)
            }
        }
        view.addSubview(contentCollectionView)
        if !hasList {
            contentCollectionView.backgroundView = Constants.UI.tweakEmptyView
        }
    }
    
    func _layoutUI() {
        titleCollectionView.frame.size = .init(width: view.frame.width, height: 36)
        if needsTitle {
            contentCollectionView.frame = .init(x: 0, y: titleCollectionView.frame.height, width: view.frame.width, height: view.frame.height - titleCollectionView.frame.height)
        } else {
            contentCollectionView.frame = .init(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        }
        seperator.frame = .init(x: 0, y: contentCollectionView.frame.minY - 1, width: view.frame.width, height: 1)
    }
}

private extension TweakSegmentedViewController {
    func _registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(_handleRotation), name: UIDevice.orientationDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(_handleDismiss), name: .willDismissTweakWindow, object: context)
    }
    
    func _unregisterNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func _handleRotation(_ notification: Notification) {
        _endTransition()
    }
    
    @objc func _handleDismiss(_ notification: Notification) {
        // always remember list
        _rememberList()
    }
}

private extension TweakSegmentedViewController {
    func _initialLocating() {
        _beginInitialLocating()
        
        guard let list = initialTweak?.list ?? initialList else {
            _endInitialLocating(animated: false)
            return
        }
        
        let oldIndex = currentIndex
        guard let index = context.lists.firstIndex(where: { $0 === list }) else {
            _endInitialLocating(animated: false)
            return
        }
        
        if oldIndex == index, initialTweak == nil {
            _endInitialLocating(animated: true)
            return
        }
        
        currentIndex = index
        // wait for title and content collection views layout
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [unowned self] in
            if oldIndex != index {
                _beginAutoScrolling()
                _autoScrollTitle(from: _indexPath(of: oldIndex), to: _indexPath(of: index), animated: false)
                _autoScrollContent(from: _indexPath(of: oldIndex), to: _indexPath(of: index), animated: false)
                _endAutoScrolling()
            }
            if let tweak = initialTweak {
                DispatchQueue.main.async {
                    _scroll(to: tweak, at: index)
                    _endInitialLocating(animated: true)
                }
            } else {
                _endInitialLocating(animated: true)
            }
        }
    }
    
    func _scroll(to tweak: AnyTweak, at index: Int) {
        guard contentCollectionView.cellVisibility(at: .init(item: index, section: 0)) == 1 else { return }
        let cell = contentCollectionView.visibleCells[0] as? TweakSegmentContentCell
        cell?.listViewController.scrollTo(tweak: tweak, animated: false)
    }
}

private extension TweakSegmentedViewController {
    func _beginTransition() {
        duringTransition = true
    }
    
    func _endTransition() {
        duringTransition = false
    }
    
    func _beginAutoScrolling() {
        contentCollectionView.isScrollEnabled = false
        duringAutoScrolling = true
    }
    
    func _endAutoScrolling() {
        duringAutoScrolling = false
        contentCollectionView.isScrollEnabled = true
    }
    
    func _beginInitialLocating() {
        view.isUserInteractionEnabled = false
        view.alpha = 0
    }
    
    func _endInitialLocating(animated: Bool) {
        guard animated else {
            view.alpha = 1
            view.isUserInteractionEnabled = true
            return
        }
        
        UIView.animate(withDuration: 0.25, animations: { [unowned self] in
            view.alpha = 1
        }, completion: { [unowned self] _ in
            view.isUserInteractionEnabled = true
        })
    }

    func _rememberList() {
        context.lastList = _list(at: currentIndex)
    }
    
    func _keepContentUponRotation() {
        titleCollectionView.collectionViewLayout.invalidateLayout()
        contentCollectionView.collectionViewLayout.invalidateLayout()
        // wait for titleCollectionView and contentCollectionView complete layouting
        DispatchQueue.main.async { [unowned self] in
            let indexPath = _indexPath(of: currentIndex)
            contentCollectionView.scrollToItem(at: indexPath, at: .left, animated: false)
            if titleCollectionView.cellVisibility(at: indexPath) < 1 {
                titleCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
                // wait for titleCollectionView complete scrolling
                DispatchQueue.main.async {
                    indicator.frame = _indicatorFrame(of: currentIndex)
                }
            }
        }
    }
    
    func _resetTitleSelection(forCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        guard let cell = cell as? TweakSegmentTitleCell else { return }
        cell.configProgress(indexPath.item == currentIndex ? 1 : 0)
    }
    
    func _autoScrollTitle(from old: IndexPath, to new: IndexPath, animated: Bool) {
        if let oldCell = titleCollectionView.cellForItem(at: old) as? TweakSegmentTitleCell {
            if animated {
                UIView.transition(with: oldCell, duration: 0.3, options: [.transitionCrossDissolve, .beginFromCurrentState], animations: {
                    oldCell.configProgress(0)
                })
            } else {
                oldCell.configProgress(0)
            }
        }
        
        if let layout = titleCollectionView.collectionViewLayout as? UICollectionViewFlowLayout,
           let frame = layout.layoutAttributesForItem(at: new)?.frame {
            let rightMostOffsetX = titleCollectionView.contentSize.width - titleCollectionView.frame.width
            if animated {
                UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseIn, .beginFromCurrentState], animations: { [unowned self] in
                    indicator.frame = .init(x: frame.minX, y: indicator.frame.minY, width: frame.width, height: indicator.frame.height)
                    titleCollectionView.contentOffset.x = max(0, min(frame.midX - titleCollectionView.frame.midX, rightMostOffsetX))
                })
            } else {
                indicator.frame = .init(x: frame.minX, y: indicator.frame.minY, width: frame.width, height: indicator.frame.height)
                titleCollectionView.contentOffset.x = max(0, min(frame.midX - titleCollectionView.frame.midX, rightMostOffsetX))
            }
        }
        
        if let newCell = titleCollectionView.cellForItem(at: new) as? TweakSegmentTitleCell {
            if animated {
                UIView.transition(with: newCell, duration: 0.3, options: [.transitionCrossDissolve, .beginFromCurrentState], animations: {
                    newCell.configProgress(1)
                })
            } else {
                newCell.configProgress(1)
            }
        }
    }
    
    func _autoScrollContent(from old: IndexPath, to new: IndexPath, animated: Bool) {
        contentCollectionView.scrollToItem(at: new, at: .left, animated: animated)
    }
    
    func _recordContentOffset() {
        previousOffsetX = contentCollectionView.contentOffset.x
    }

    func _calculateScrollState() -> ContentScrollState? {
        let offsetX = contentCollectionView.contentOffset.x
        let width = contentCollectionView.frame.width
        let count = contentCollectionView.numberOfItems(inSection: 0)
        
        let offsetRatio = offsetX / width
        var progress = (offsetRatio - floor(offsetRatio))
        var sourceIndex: Int
        var targetIndex: Int
        if offsetX - previousOffsetX >= 0 {
            if progress == 0.0 { return nil }
            sourceIndex = Int(floor(offsetX / width))
            targetIndex = sourceIndex + 1
            if targetIndex >= count {
                return nil
            }
        } else {
            targetIndex = Int(floor(offsetX / width))
            sourceIndex = targetIndex + 1
            if sourceIndex >= count {
                return nil
            }
            progress = 1.0 - progress
        }
        
        return .init(sourceIndex: sourceIndex, targetIndex: targetIndex, progress: progress)
    }
    
    func _recordScrollState(_ state: ContentScrollState) {
        previousScrollState = state
    }
    
    func _clearScrollState() {
        previousScrollState = nil
    }
    
    func _updateIndicator(with state: ContentScrollState) {
        guard let layout = titleCollectionView.collectionViewLayout as? UICollectionViewFlowLayout,
            let sourceFrame = layout.layoutAttributesForItem(at: _indexPath(of: state.sourceIndex))?.frame,
            let targetFrame = layout.layoutAttributesForItem(at: _indexPath(of: state.targetIndex))?.frame
        else { return }
        let width = sourceFrame.width - (sourceFrame.width - targetFrame.width) * state.progress
        let centerX = sourceFrame.midX + (targetFrame.midX - sourceFrame.midX) * state.progress
        indicator.frame.size.width = width
        indicator.frame.origin.x = centerX - width.half
    }
    
    func _updateTitle(with state: ContentScrollState) {
        if let oldCell = titleCollectionView.cellForItem(at: _indexPath(of: state.sourceIndex)) as? TweakSegmentTitleCell {
            UIView.transition(with: oldCell, duration: 0.3, options: [.transitionCrossDissolve, .beginFromCurrentState], animations: {
                oldCell.configProgress(1 - state.progress)
            })
        }
        if let newCell = titleCollectionView.cellForItem(at: _indexPath(of: state.targetIndex)) as? TweakSegmentTitleCell {
            UIView.transition(with: newCell, duration: 0.3, options: [.transitionCrossDissolve, .beginFromCurrentState], animations: {
                newCell.configProgress(state.progress)
            })
        }
    }
    
    func _updateCurrentIndex(with state: ContentScrollState) {
        let isNewIndex: Bool
        
        if let previousState = previousScrollState {
            let delta = abs(state.progress - previousState.progress)
            // the contentOffset change is not that continuous when pan too fast
            // which means the progress delta will larger than usual pan
            // we choose delta (0.01) after multiple trial
            if delta >= 0.01 {
                isNewIndex = state.progress.rounded(to: .integer).isEqual(to: 1)
            } else {
                isNewIndex = false
            }
        } else {
            isNewIndex = state.progress.rounded(to: .hundredth).isEqual(to: 1)
        }
        guard isNewIndex, currentIndex != state.targetIndex else { return }
        currentIndex = state.targetIndex
    }
    
    func _revealTitleAfterPaging() {
        let indexPath = _indexPath(of: currentIndex)
        guard titleCollectionView.cellVisibility(at: indexPath) < 1 else { return }
        titleCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    func _correctIndicatorAfterPaging() {
        let targetFrame = _indicatorFrame(of: currentIndex)
        if indicator.frame == targetFrame { return }
        indicator.frame = targetFrame
    }
    
    func _correctTitleProgress() {
        for indexPath in titleCollectionView.indexPathsForVisibleItems {
            let cell = titleCollectionView.cellForItem(at: indexPath) as? TweakSegmentTitleCell
            cell?.configProgress(indexPath.item == currentIndex ? 1 : 0)
        }
    }
}

private extension TweakSegmentedViewController {
    struct ContentScrollState {
        let sourceIndex: Int
        let targetIndex: Int
        let progress: CGFloat
    }
    
    var needsTitle: Bool {
        context.lists.count > 1
    }
    
    var hasList: Bool {
        !context.lists.isEmpty
    }

    func _list(at index: Int) -> TweakList {
        context.lists[index]
    }
    
    func _title(at index: Int) -> String {
        _list(at: index).name
    }
    
    func _indexPath(of index: Int) -> IndexPath {
        .init(item: index, section: 0)
    }
    
    func _width(of title: String) -> CGFloat {
        if let width = titleWidthCache[title] {
            return width
        } else {
            let width = (title as NSString).size(withAttributes: [.font: Constants.Font.segmentTitle]).width + 28
            titleWidthCache[title] = width
            return width
        }
    }
    
    func _indicatorFrame(of index: Int) -> CGRect {
        guard let layout = titleCollectionView.collectionViewLayout as? UICollectionViewFlowLayout,
            let frame = layout.layoutAttributesForItem(at: _indexPath(of: index))?.frame
        else { return indicator.frame }
        return .init(x: frame.minX, y: titleCollectionView.frame.height - indicator.frame.height, width: frame.width, height: indicator.frame.height)
    }
}

private extension TweakSegmentedViewController {
    func _titleCollectionView() -> TweakSegmentTitleCollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = TweakSegmentTitleCollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.bounces = false
        cv.delegate = self
        cv.dataSource = self
        cv.scrollsToTop = false
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.contentInsetAdjustmentBehavior = .never
        cv.register(cell: TweakSegmentTitleCell.self)
        return cv
    }
    
    func _contentCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.bounces = false
        cv.delegate = self
        cv.dataSource = self
        cv.isPagingEnabled = true
        cv.scrollsToTop = false
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.contentInsetAdjustmentBehavior = .never
        cv.register(cell: TweakSegmentContentCell.self)
        return cv
    }
    
    func _seperator() -> UIView {
        let v = UIView()
        v.backgroundColor = Constants.Color.seperator
        return v
    }
    
    func _indicator() -> UIView {
        let v = UIView()
        v.backgroundColor = Constants.Color.actionBlue
        v.frame.size.height = 2 + (1 / UIScreen.main.scale)
        v.layer.addCorner(radius: v.frame.height * 0.75, mask: .top)
        return v
    }
}

// MARK: - TweakSegmentTitleCollectionView

private final class TweakSegmentTitleCollectionView: UICollectionView {
    private var indicator: UIView?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // always keep indicator in the top most
        if let indicator = indicator {
            indicator.frame.origin.y = frame.height - indicator.frame.height
            bringSubviewToFront(indicator)
        }
    }
}

extension TweakSegmentTitleCollectionView {
    func setIndicator(_ indicator: UIView) {
        indicator.removeFromSuperview()
        self.indicator = indicator
        addSubview(indicator)
    }
}

// MARK: - TweakSegmentTitleCell

private final class TweakSegmentTitleCell: UICollectionViewCell {
    private lazy var label = _label()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(label)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = contentView.bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.textColor = Constants.Color.labelSecondary
    }
}

extension TweakSegmentTitleCell {
    func configTitle(_ title: String) {
        label.text = title
    }
    
    func configProgress(_ progress: CGFloat) {
        // progress: 0 - not selected, 1 - selected
        if progress.isEqual(to: 0) {
            label.textColor = Constants.Color.labelSecondary
        } else if progress.isEqual(to: 1) {
            label.textColor = Constants.Color.actionBlue
        } else {
            let rgba1 = Constants.Color.labelSecondary.rgba
            let rgba2 = Constants.Color.actionBlue.rgba
            let r = rgba1.r + (rgba2.r - rgba1.r) * progress
            let g = rgba1.g + (rgba2.g - rgba1.g) * progress
            let b = rgba1.b + (rgba2.b - rgba1.b) * progress
            let a = rgba1.a + (rgba2.a - rgba1.a) * progress
            label.textColor = UIColor(r: r, g: g, b: b, a: a)
        }
    }
}

extension TweakSegmentTitleCell {
    func _label() -> UILabel {
        let l = UILabel()
        l.textAlignment = .center
        l.textColor = Constants.Color.labelSecondary
        l.font = Constants.Font.segmentTitle
        return l
    }
}

// MARK: - TweakSegmentContentCell

private final class TweakSegmentContentCell: UICollectionViewCell {
    private(set) lazy var listViewController = _listViewController()
}

extension TweakSegmentContentCell {
    override func layoutSubviews() {
        super.layoutSubviews()
        _layoutUI()
    }
}

extension TweakSegmentContentCell {
    func configList(_ list: TweakList, context: TweakContext, in segmentVC: TweakSegmentedViewController) {
        segmentVC.addChildViewController(listViewController) {
            contentView.addSubview($1.tableView)
        }
        let tweaks: [[AnyTweak]] = list.sections.compactMap {
            $0.tweaks.isEmpty ? nil : $0.tweaks
        }
        listViewController.setScene(.list(name: list.name))
        listViewController.setTweaks(tweaks, in: context)
    }
}

private extension TweakSegmentContentCell {
    func _layoutUI() {
        listViewController.tableView.frame = contentView.bounds
        listViewController.tableView.verticalScrollIndicatorInsets.bottom = window?.safeAreaInsets.bottom ?? 0
    }
}

private extension TweakSegmentContentCell {
    func _listViewController() -> TweakListViewController {
        TweakListViewController(scene: .list(name: ""))
    }
}

// MARK: - Helper

private extension UICollectionView {
    func cellVisibility(at indexPath: IndexPath) -> CGFloat {
        guard let cell = cellForItem(at: indexPath), cell.frame.width > 0 else { return 0 }
        let visibleRect = CGRect(x: contentOffset.x, y: contentOffset.y, width: frame.width, height: frame.height)
        let intersectionRect = cell.frame.intersection(visibleRect)
        guard !intersectionRect.isNull else { return 0 }
        return intersectionRect.width / cell.frame.width
    }
}
