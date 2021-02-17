//
//  TweakSearchHistoryViewController.swift
//  TweaKit
//
//  Created by cokile
//

import UIKit

protocol TweakSearchHistoryViewControllerDelegate: AnyObject {
    func searchHistoryViewController(_ viewController: TweakSearchHistoryViewController, didSelectHistory history: String)
    func searchHistoryViewController(_ viewController: TweakSearchHistoryViewController, didDeleteHistory history: String)
}

final class TweakSearchHistoryViewController: UITableViewController {
    private var histories: [String] = []
    
    private weak var delegate: TweakSearchHistoryViewControllerDelegate?
    
    init(delegate: TweakSearchHistoryViewControllerDelegate) {
        self.delegate = delegate
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TweakSearchHistoryViewController {
    func setHistories(_ histories: [String], scrollToTop: Bool) {
        if histories == self.histories {
            if scrollToTop, !histories.isEmpty {
                tableView.scrollToRow(at: .init(row: 0, section: 0), at: .bottom, animated: false)
            }
            return
        }
        
        if #available(iOS 13, *), !tableView.isHidden {
            _reloadPartially(with: histories)
        } else {
            _reloadAll(with: histories)
        }
    }
}

extension TweakSearchHistoryViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        _setupUI()
    }
}

extension TweakSearchHistoryViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        histories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(cell: TweakSearchHistoryCell.self, for: indexPath)
        let history = histories[indexPath.row]
        cell.configWith(text: history) { [weak self] in
            guard let self = self else { return }
            self.delegate?.searchHistoryViewController(self, didDeleteHistory: history)
        }
        return cell
    }
}

extension TweakSearchHistoryViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.searchHistoryViewController(self, didSelectHistory: histories[indexPath.row])
    }
}

private extension TweakSearchHistoryViewController {
    func _setupUI() {
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 50
        tableView.tableFooterView = UIView()
        tableView.register(cell: TweakSearchHistoryCell.self)
    }
}

private extension TweakSearchHistoryViewController {
    @available(iOS 13, *)
    func _reloadPartially(with newHistories: [String]) {
        let oldHistories = self.histories
        histories = newHistories
        let diff = newHistories.difference(from: oldHistories)
        var deletedIndexPaths: [IndexPath] = []
        var insertedIndexPaths: [IndexPath] = []
        for change in diff {
            switch change {
            case let .remove(offset, _, _):
                deletedIndexPaths.append(.init(row: offset, section: 0))
            case let .insert(offset, _, _):
                insertedIndexPaths.append(.init(row: offset, section: 0))
            }
        }
        tableView.beginUpdates()
        if !deletedIndexPaths.isEmpty {
            tableView.deleteRows(at: deletedIndexPaths, with: .top)
        }
        if !insertedIndexPaths.isEmpty {
            tableView.insertRows(at: insertedIndexPaths, with: .none)
        }
        tableView.endUpdates()
    }
    
    func _reloadAll(with newHistories: [String]) {
        histories = newHistories
        tableView.reloadData()
    }
}

// MARK: - TweakSearchHistoryCell

private final class TweakSearchHistoryCell: UITableViewCell {
    private var onDeleteButtonTap: (() -> Void)?
    
    private lazy var label = _label()
    private lazy var button = _button()
    private lazy var hairline = _hairline()
    private lazy var highlightBackground = _highlightBackground()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        _setupUI()
        _layoutUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TweakSearchHistoryCell {
    override func layoutSubviews() {
        super.layoutSubviews()
        _calibrateUI()
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        _setHighlight(highlighted, animated: animated)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        _setHighlight(selected, animated: animated)
    }
}

extension TweakSearchHistoryCell {
    func configWith(text: String, onDeleteButtonTap: @escaping () -> Void) {
        label.text = text
        self.onDeleteButtonTap = onDeleteButtonTap
    }
}

private extension TweakSearchHistoryCell {
    func _setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        contentView.addSubview(label)
        contentView.addSubview(button)
        contentView.addSubview(hairline)
        contentView.addSubview(highlightBackground)
    }
    
    func _layoutUI() {
        contentView.subviews.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            button.leadingAnchor.constraint(greaterThanOrEqualTo: label.trailingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            button.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            hairline.leadingAnchor.constraint(equalTo: label.leadingAnchor),
            hairline.trailingAnchor.constraint(equalTo: button.trailingAnchor),
            hairline.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            hairline.heightAnchor.constraint(equalToConstant: 1),
        ])
    }
    
    func _calibrateUI() {
        highlightBackground.frame = contentView.bounds
    }
}

private extension TweakSearchHistoryCell {
    @objc func _handleDeleteButtonTap(_ sender: UIButton) {
        onDeleteButtonTap?()
    }
    
    func _setHighlight(_ flag: Bool, animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.25, delay: 0, options: .beginFromCurrentState, animations: { [unowned self] in
                highlightBackground.alpha = flag ? 0.1 : 0
                hairline.alpha = flag ? 0 : 1
            })
        } else {
            highlightBackground.alpha = flag ? 0.1 : 0
            hairline.alpha = flag ? 0 : 1
        }
    }
}

private extension TweakSearchHistoryCell {
    func _label() -> UILabel {
        let l = UILabel()
        l.textColor = Constants.Color.labelPrimary
        l.font = .systemFont(ofSize: 18)
        return l
    }
    
    func _button() -> UIButton {
        let b = HitOutsideButton(type: .system)
        b.setImage(Constants.Assets.cross, for: .normal)
        b.addTarget(self, action: #selector(_handleDeleteButtonTap), for: .touchUpInside)
        b.extendInset = .init(inset: -11)
        b.tintColor = Constants.Color.labelSecondary
        return b
    }
    
    func _highlightBackground() -> UIView {
        let v = UIView()
        v.isUserInteractionEnabled = false
        v.backgroundColor = Constants.Color.actionBlue
        v.alpha = 0
        return v
    }
    
    func _hairline() -> UIView {
        let v = UIView()
        v.backgroundColor = Constants.Color.seperator
        v.isUserInteractionEnabled = false
        return v
    }
}
