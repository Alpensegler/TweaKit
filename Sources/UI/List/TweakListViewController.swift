//
//  TweakListViewController.swift
//  TweaKit
//
//  Created by cokile
//

import UIKit

final class TweakListViewController: UITableViewController {
    private unowned var context: TweakContext!
    private var scene: TweakListViewScene
    private var tweaks: [[AnyTweak]] = []
    private var emptyView: TweakListEmptyView?
    private lazy var debouncer = Debouncer(dueTime: 0.1)
    private(set) lazy var primaryViewRecycler = TweakPrimaryViewRecycler()

    private var floatingSecion: Int?
    private var floatingHeader: TweakListSectionHeader?
    private var floatingSectionCover: UIView?
    private var floatingSectionSnapshot: CALayer?
    private var floatingIcon: CALayer?
    private var floatingIconBackground: CALayer?
    
    init(scene: TweakListViewScene) {
        self.scene = scene
        super.init(style: scene.isFloating ? .plain : .grouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TweakListViewController {
    func setScene(_ scene: TweakListViewScene) {
        switch (self.scene, scene) {
        case (.list, .list), (.search, .search), (.floating, .floating):
            self.scene = scene
        default:
            fatalError("unmatched scene: \(self.scene) -> \(scene)")
        }
    }
    
    func setTweaks(_ tweaks: [[AnyTweak]], in context: TweakContext, scrollToTop: Bool = false) {
        if self.tweaks.isEmpty && tweaks.isEmpty {
            _reloadEmptyView()
            return
        }
        
        guard self.tweaks.count != tweaks.count || self.tweaks.flatMap({ $0.map(\.id) }) != tweaks.flatMap({ $0.map(\.id) }) else {
            if scrollToTop, !tweaks.isEmpty {
                tableView.scrollToRow(at: .init(row: 0, section: 0), at: .bottom, animated: false)
            }
            return
        }
        
        self.tweaks = tweaks
        self.context = context
        _reload()
    }
    
    func scrollTo(tweak: AnyTweak, animated: Bool) {
        guard let section = tweaks.firstIndex(where: { $0.first?.section === tweak.section }) else { return }
        guard let row = tweaks[section].firstIndex(where: { $0 === tweak }) else { return }
        tableView.scrollToRow(at: .init(row: row, section: section), at: .top, animated: animated)
    }
    
    func iconFrame(in section: Int) -> CGRect {
        let indexPath = IndexPath(item: 0, section: section)
        if tableView.indexPathsForVisibleRows?.contains(indexPath) == true {
            let cell = tableView.cellForRow(at: indexPath) as! TweakListViewCell
            return tableView.convert(cell.iconFrame, to: cell.contentView)
        } else {
            return .zero
        }
    }
}

extension TweakListViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        _setupUI()
    }
}

extension TweakListViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        tweaks.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tweaks[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(cell: TweakListViewCell.self, for: indexPath)
        let sectionTweaks = tweaks[indexPath.section]
        let isLast = indexPath.row == sectionTweaks.count - 1
        cell.config(with: sectionTweaks[indexPath.row], isLast: isLast, scene: scene, delegate: self)
        return cell
    }
}

extension TweakListViewController {
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if scene.isFloating {
            return nil
        } else {
            let header = tableView.dequeue(headerFooter: TweakListSectionHeader.self)
            header.configWith(delegate: self, section: section)
            return header
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath) as! TweakListViewCell
        cell.handleSelection(for: tweaks[indexPath.section][indexPath.row])
    }
}

extension TweakListViewController: TweakListSectionHeaderDelegate {
    var headerHostViewController: UIViewController {
        self
    }
    
    func sectionHeader(_ header: TweakListSectionHeader, titleForSection section: Int) -> String {
        tweaks[section].first?.section?.name ?? "Section"
    }
    
    func sectionHeader(_ header: TweakListSectionHeader, tweaksForSection section: Int) -> [AnyTweak] {
        tweaks[section]
    }
    
    func sectionHeader(_ header: TweakListSectionHeader, contextForSection section: Int) -> TweakContext {
        context
    }
    
    func sectionHeader(_ header: TweakListSectionHeader, didActivateFloatingForSection section: Int) {
        floatingSecion = section
        floatingHeader = header
        context.floatingTransitioner?.animateTransition(from: self, to: TweakFloatingBall(context: context), tweaks: tweaks[section])
    }
}

extension TweakListViewController: TweakListViewCellDelegate {
    var cellHostViewController: UIViewController {
        self
    }
    
    func tweakListViewCellNeedsLayout(_ cell: TweakListViewCell) {
        // tirgger cell height update
        // 1. no need to update invisible cells
        // 2. debounce here since there maybe multiple cells need layout
        // 3. animation is disabled since shadow is updated without animation
        guard tableView.visibleCells.contains(cell) else { return }
        debouncer.call { [weak self] in
            UIView.performWithoutAnimation {
                self?.tableView.beginUpdates()
                self?.tableView.endUpdates()
            }
        }
    }
}

extension TweakListViewController: TweakFloatingPrimaryParticipant {
    var category: TweakFloatingParticipantCategory {
        switch scene {
        case .list: return .normalList
        case .search: return .searchList
        case .floating: return .normalList
        }
    }
    
    func prepareTransition(to category: TweakFloatingParticipantCategory) {
        guard category == . ball, let section = floatingSecion else { return }
        if tableView.isDecelerating || tableView.isTracking || tableView.isDragging { return }
        _toggleIsFloating(to: true)
        _fakeFloatingSection(section)
    }
    
    func transit(to category: TweakFloatingParticipantCategory) {
        guard category == .ball else { return }
        guard let ballPosition = context.floatingTransitioner?.ballPosition() else { return }
        _showBallAnimationUI()
        _animateToBall(position: ballPosition)
    }
    
    func prepareTransition(from category: TweakFloatingParticipantCategory) {
        guard let section = floatingSecion else { return }
        switch category {
        case .ball:
            _fakeFloatingSection(section)
        case .normalList, .searchList, .panel:
            break
        }
    }
    
    func transit(from category: TweakFloatingParticipantCategory) {
        switch category {
        case .ball:
            guard let ballPosition = context.floatingTransitioner?.ballPosition() else { break }
            _showBallAnimationUI()
            _animateFromBall(position: ballPosition)
        case .normalList, .searchList, .panel:
            break
        }
    }
    
    func completeTransition(from category: TweakFloatingParticipantCategory) {
        _toggleIsFloating(to: false)
        _endTransistion()
        _endFloating()
    }
    
    func completeTransition(to category: TweakFloatingParticipantCategory) {
        _endTransistion()
    }
}

private extension TweakListViewController {
    func _setupUI() {
        tableView.backgroundColor = .clear
        tableView.keyboardDismissMode = .onDrag
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        tableView.sectionHeaderHeight = scene.isFloating ? 0 : UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = scene.isFloating ? 0 : 66
        tableView.sectionFooterHeight = 0
        tableView.tableHeaderView = scene.isFloating
            ? nil
            : UIView(frame: CGRect(x: 0, y: 0, width: 0, height: Constants.UI.ListView.verticalPadding))
        tableView.tableFooterView = UIView()
        tableView.emptyView = scene.emptyView
        tableView.register(cell: TweakListViewCell.self)
        tableView.register(headerFooter: TweakListSectionHeader.self)
    }
}

private extension TweakListViewController {
    func _reload() {
        _cancelCellUpdate()
        _reloadData()
        _reloadEmptyView()
    }
    
    func _cancelCellUpdate() {
        debouncer.cancel()
    }
    
    func _reloadData() {
        tableView.reloadData()
    }
    
    func _reloadEmptyView() {
        tableView.emptyView?.isHidden = !tweaks.isEmpty
        switch scene {
        case let .list(name):
            if name.isEmpty {
                tableView.emptyView?.setText(text: "No Tweaks")
            } else {
                tableView.emptyView?.setText(text: #"No Tweaks in \#(name)"#)
            }
        case let .search(keyword):
            if keyword.isEmpty {
                tableView.emptyView?.setText(text: "No Tweaks")
            } else {
                tableView.emptyView?.setText(text: #"No Tweaks with "\#(keyword)""#)
            }
        case .floating:
            break
        }
    }
}

private extension TweakListViewController {
    func _toggleIsFloating(to flag: Bool) {
        context.showingWindow?.markIsFloating(flag)
    }
    
    func _endTransistion() {
        floatingSectionCover?.removeFromSuperview()
        floatingSectionCover = nil
        floatingSectionSnapshot?.removeFromSuperlayer()
        floatingSectionSnapshot = nil
        floatingIcon?.removeFromSuperlayer()
        floatingIcon = nil
        floatingIconBackground?.removeFromSuperlayer()
        floatingIconBackground = nil
    }
    
    func _endFloating() {
        floatingHeader = nil
        floatingSecion = nil
    }
    
    func _fakeFloatingSection(_ section: Int) {
        floatingSectionCover = _makeFloatingCover(sectionFrame: _calculateSectionCoverFrame(forSection: section))
        tableView.addSubview(floatingSectionCover!)
        floatingSectionSnapshot = _makeFloatingSnapshot(sectionFrame: _calculateSectionSnapshotFrame(forSection: section))
        tableView.window?.layer.addSublayer(floatingSectionSnapshot!)
        let iconFrame = _calculateIconFrame(for: section, snapshot: UIView(frame: floatingSectionSnapshot!.frame))
        let (icon, background) = _makeIcon(section: section, frame: iconFrame)
        floatingIcon = icon
        floatingIconBackground = background
        floatingSectionSnapshot?.addSublayer(background)
        floatingSectionSnapshot?.addSublayer(icon)
    }
    
    func _calculateSectionCoverFrame(forSection section: Int) -> CGRect {
        tableView.rect(forSection: section)
    }
    
    func _makeFloatingCover(sectionFrame: CGRect) -> UIView {
        let view = UIView(frame: sectionFrame)
        view.backgroundColor = Constants.Color.backgroundPrimary
        view.isUserInteractionEnabled = false
        view.alpha = 0
        return view
    }
    
    func _calculateSectionSnapshotFrame(forSection section: Int) -> CGRect {
        let sectionRect = tableView.rect(forSection: section)
        let visibleRect: CGRect = .init(
            x: tableView.contentOffset.x,
            y: tableView.contentOffset.y,
            width: tableView.frame.width,
            height: tableView.frame.height
        )
        if visibleRect.contains(sectionRect) {
            return sectionRect
                .insetBy(dx: Constants.UI.ListView.horizontalPadding, dy: Constants.UI.ListView.verticalPadding)
        } else if visibleRect.minY > sectionRect.minY {
            let topDiff = max(0, Constants.UI.ListView.verticalPadding - (visibleRect.minY - sectionRect.minY))
            return .init(
                x: Constants.UI.ListView.horizontalPadding,
                y: visibleRect.minY + topDiff,
                width: tableView.frame.width - 2 * Constants.UI.ListView.horizontalPadding,
                height: sectionRect.maxY - visibleRect.minY - Constants.UI.ListView.verticalPadding - topDiff
            )
        } else {
            let bottomDiff = max(0, Constants.UI.ListView.verticalPadding - (sectionRect.maxY - visibleRect.maxY))
            return .init(
                x: Constants.UI.ListView.horizontalPadding,
                y: sectionRect.minY + Constants.UI.ListView.verticalPadding,
                width: tableView.frame.width - 2 * Constants.UI.ListView.horizontalPadding,
                height: visibleRect.maxY - sectionRect.minY - Constants.UI.ListView.verticalPadding - bottomDiff
            )
        }
    }
    
    func _makeFloatingSnapshot(sectionFrame: CGRect) -> CALayer {
        let image = UIGraphicsImageRenderer(bounds: tableView.bounds).image { _ in
            tableView.drawHierarchy(in: tableView.bounds, afterScreenUpdates: true)
        }
        let scale = image.scale
        let croppingRect = sectionFrame
            .offsetBy(dx: 0, dy: -tableView.contentOffset.y)
            .scaled(by: scale)
        
        let layer = CALayer()
        layer.masksToBounds = true
        layer.frame = tableView.convert(sectionFrame, to: nil)
        layer.contents = image.cgImage?.cropping(to: croppingRect)
        layer.opacity = 0
        return layer
    }
    
    func _calculateIconFrame(for section: Int, snapshot: UIView) -> CGRect {
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: section)) as? TweakListViewCell {
            return cell.contentView.convert(cell.iconFrame, to: snapshot)
        } else if let header = floatingHeader {
            // use a estimated frame in case header is visible but cell is not visible
            let iconFrame = CGRect(
                x: header.frame.minX + Constants.UI.ListView.horizontalPadding * 2,
                y: header.frame.maxY + 15,
                width: Constants.UI.ListView.iconSize,
                height: Constants.UI.ListView.iconSize
            )
            return tableView.convert(iconFrame, to: snapshot)
        } else {
            // neither header nor cells are visible, floating can't be activated
            return .zero
        }
    }
    
    func _makeIcon(section: Int, frame: CGRect) -> (icon: CALayer, background: CALayer) {
        let tweak = tweaks[section][0]
        let icon = CALayer()
        icon.frame = frame
        icon.contents = Constants.UI.shapeImage(of: tweak).cgImage
        icon.contentsScale = UIScreen.main.scale
        icon.contentsGravity = .resizeAspectFill
        icon.opacity = 0
        let background = CALayer()
        background.frame = icon.frame
        background.backgroundColor = Constants.UI.shapeColor(of: tweak).cgColor
        background.addCorner(radius: Constants.UI.ListView.iconCornerRadius)
        background.opacity = 0
        return (icon, background)
    }
    
    func _showBallAnimationUI() {
        floatingSectionCover?.alpha = 1
        floatingSectionSnapshot?.opacity = 1
        floatingIconBackground?.opacity = 1
        floatingIcon?.opacity = 1
    }
    
    func _animateToBall(position: CGPoint) {
        guard let snapshot = floatingSectionSnapshot else { return }
        let duration: TimeInterval = Constants.UI.Floating.ballAnimationDuration
        
        if let icon = floatingIcon {
            let scale = Constants.UI.Floating.ballIconSize / Constants.UI.ListView.iconSize
            let scaleAnim = CABasicAnimation(keyPath: "transform.scale", toValue: scale, duration: duration)
            icon.add(scaleAnim, forKey: "icon-scale")
            let position = CGPoint(x: Constants.UI.Floating.ballSize.half, y: Constants.UI.Floating.ballSize.half)
            let postionAnim = CABasicAnimation(keyPath: #keyPath(CALayer.position), toValue: position, duration: duration)
            icon.add(postionAnim, forKey: "icon-position")
        }

        if let background = floatingIconBackground {
            let bacgroundScale = ceil(max(snapshot.frame.width / background.frame.halfWidth, snapshot.frame.height / background.frame.halfHeight))
            let anim = CABasicAnimation(keyPath: "transform.scale", toValue: bacgroundScale, duration: duration)
            background.add(anim, forKey: "background-sacle")
        }
        
        let postionAnim = CABasicAnimation(keyPath: #keyPath(CALayer.position), fromValue: snapshot.position, toValue: position, duration: duration)
        snapshot.add(postionAnim, forKey: "snapshot-position")
        let ballSize = CGSize(width: Constants.UI.Floating.ballSize, height: Constants.UI.Floating.ballSize)
        let sizeAnim = CABasicAnimation(keyPath: "bounds.size", fromValue: snapshot.frame.size, toValue: ballSize, duration: duration)
        snapshot.add(sizeAnim, forKey: "snapshot-size")
        let cornerAnim = CABasicAnimation(keyPath: #keyPath(CALayer.cornerRadius), fromValue: 0, toValue: Constants.UI.Floating.ballSize.half, duration: duration)
        snapshot.add(cornerAnim, forKey: "snapshot-corner")
    }
    
    func _animateFromBall(position: CGPoint) {
        guard let snapshot = floatingSectionSnapshot else { return }
        let duration = Constants.UI.Floating.ballAnimationDuration
        
        if let icon = floatingIcon {
            let scale = Constants.UI.Floating.ballIconSize / Constants.UI.ListView.iconSize
            let scaleAnim = CABasicAnimation(keyPath: "transform.scale", fromValue: scale, toValue: 1, duration: duration)
            icon.add(scaleAnim, forKey: "icon-scale")
            let position = CGPoint(x: Constants.UI.Floating.ballSize.half, y: Constants.UI.Floating.ballSize.half)
            let postionAnim = CABasicAnimation(keyPath: #keyPath(CALayer.position), fromValue: position, toValue: icon.position, duration: duration)
            icon.add(postionAnim, forKey: "icon-position")
        }
        
        if let background = floatingIconBackground {
            let bacgroundScale = ceil(max(snapshot.frame.width / background.frame.halfWidth, snapshot.frame.height / background.frame.halfHeight))
            let anim = CABasicAnimation(keyPath: "transform.scale", fromValue: bacgroundScale, toValue: 1, duration: duration)
            background.add(anim, forKey: "background-sacle")
        }
        
        let postionAnim = CABasicAnimation(keyPath: #keyPath(CALayer.position), fromValue: position, toValue: snapshot.position, duration: duration)
        snapshot.add(postionAnim, forKey: "snapshot-position")
        let ballSize = CGSize(width: Constants.UI.Floating.ballSize, height: Constants.UI.Floating.ballSize)
        let sizeAnim = CABasicAnimation(keyPath: "bounds.size", fromValue: ballSize, toValue: snapshot.frame.size, duration: duration)
        snapshot.add(sizeAnim, forKey: "snapshot-size")
        let cornerAnim = CABasicAnimation(keyPath: #keyPath(CALayer.cornerRadius), fromValue: Constants.UI.Floating.ballSize.half, toValue: 0, duration: duration)
        snapshot.add(cornerAnim, forKey: "snapshot-corner")
    }
}

extension Constants.UI {
    enum ListView {
        static let horizontalPadding: CGFloat = 10
        static let verticalPadding: CGFloat = 8
        static let cornerRadius: CGFloat = 10
        static let shadowRadius: CGFloat = 2
        static let shadowY: CGFloat = 2
        static let shadowColor = UIColor.black.withAlphaComponent(0.08)
        static let contentLeading: CGFloat = 10
        static let iconCornerRadius: CGFloat = 8
        static let iconSize: CGFloat = 30
    }
}
private extension UITableView {
    var emptyView: TweakListEmptyView? {
        get { backgroundView as? TweakListEmptyView }
        set { backgroundView = newValue }
    }
}
