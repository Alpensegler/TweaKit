//
//  TweakListView.swift
//  TweaKit
//
//  Copyright © 2021 daycam. All rights reserved.
//

import UIKit

enum TweakListViewScene {
    case normal
    case search
}

final class TweakListViewController: UITableViewController {
    private let scene: TweakListViewScene
    private var tweaks: [[AnyTweak]] = []
    private unowned var context: TweakContext!
    let primaryViewRecycler = TweakPrimaryViewRecycler()
    
    init(scene: TweakListViewScene) {
        self.scene = scene
        super.init(style: .grouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TweakListViewController {
    func setTweaks(_ tweaks: [[AnyTweak]], in context: TweakContext, scrollToTop: Bool = false) {
        guard self.tweaks.count != tweaks.count || self.tweaks.flatMap({ $0.map(\.id) }) != tweaks.flatMap({ $0.map(\.id) }) else {
            if scrollToTop, !tweaks.isEmpty {
                scrollToRow(at: .init(row: 0, section: 0), at: .bottom, animated: false)
            }
            return
        }
        
        self.tweaks = tweaks
        self.context = context
        _reload()
    }
}

extension TweakListViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        _setupUI()
    }
}

extension TweakListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        tweaks.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tweaks[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(cell: TweakListViewCell.self, for: indexPath)
        let sectionTweaks = tweaks[indexPath.section]
        let isLast = indexPath.row == sectionTweaks.count - 1
        cell.config(with: sectionTweaks[indexPath.row], isLast: isLast, delegate: self)
        return cell
    }
}

extension TweakListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeue(headerFooter: TweakListSectionHeader.self)
        header.configWith(delegate: self, section: section)
        return header
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath) as! TweakListViewCell
        cell.handleSelection(for: tweaks[indexPath.section][indexPath.row])
    }
}

extension TweakListViewController: TweakListSectionHeaderDelegate {
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
        
    }
}

extension TweakListViewController: TweakListViewCellDelegate {
    var listView: TweakListViewController {
        self
    }
}

private extension TweakListViewController {
    func _setupUI() {
        backgroundColor = .clear
        keyboardDismissMode = .onDrag
        separatorStyle = .none
        rowHeight = UITableView.automaticDimension
        estimatedRowHeight = 60
        sectionHeaderHeight = UITableView.automaticDimension
        estimatedSectionHeaderHeight = 66
        sectionFooterHeight = 0
        tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: Constants.UI.ListView.verticalPadding))
        tableFooterView = UIView()
        backgroundView = {
            switch scene {
            case .normal: return Constants.UI.tweakEmptyView
            case .search: return Constants.UI.tweakEmptyResultView
            }
        }()
        
        dataSource = self
        delegate = self
        register(cell: TweakListViewCell.self)
        register(headerFooter: TweakListSectionHeader.self)
    }
}

private extension TweakListViewController {
    func _reload() {
        _reloadData()
        _reloadEmptyView()
    }
    
    func _reloadData() {
        reloadData()
    }
    
    func _reloadEmptyView() {
        backgroundView?.isHidden = !tweaks.isEmpty
    }
}

extension Constants.UI {
    enum ListView {
        static let horizontalPadding: CGFloat = 10
        static let verticalPadding: CGFloat = 8
        static let cornerRadius: CGFloat = 10
        static let shadowRadius: CGFloat = 2
        static let shadowOffset = CGSize(width: 0, height: 2)
        static let shadowColor = UIColor.black.withAlphaComponent(0.08).cgColor
        static let contentLeading: CGFloat = 10
    }
}
