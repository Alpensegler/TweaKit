//
//  TweakSecondaryViewReorderer.swift
//  TweaKit
//
//  Created by cokile
//

import UIKit

final class TweakSecondaryViewReorderer<Item: TweakSecondaryViewItemConvertible>: UITableViewController {
    private weak var currentTweak: AnyTweak?
    private var items: [Item] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        _setupUI()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(cell: Cell.self, for: indexPath)
        cell.configContent(items[indexPath.row])
        return cell
    }

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .none
    }

    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        false
    }

    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if sourceIndexPath == destinationIndexPath { return }
        let item = items[sourceIndexPath.row]
        items.remove(at: sourceIndexPath.row)
        items.insert(item, at: destinationIndexPath.row)
        if let tweak = currentTweak {
            updateTweak(tweak, withValue: items, manually: true)
        }
    }
}

extension TweakSecondaryViewReorderer: TweakSecondaryView {
    func reload(withTweak tweak: AnyTweak, manually: Bool) {
        guard let allItems = tweak.currentValue as? [Item] else { return }
        currentTweak = tweak
        if allItems == items { return }
        items = allItems
        tableView.reloadData()
    }
}

private extension TweakSecondaryViewReorderer {
    func _setupUI() {
        view.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.isEditing = true
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 50
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.register(cell: Cell.self)
    }
}

// MARK: - Cell

private extension TweakSecondaryViewReorderer {
    final class Cell: UITableViewCell {
        private lazy var displayTextLabel = _displayTextLabel()
        private lazy var separator = _separator()

        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            _setupUI()
            _layoutUI()
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

extension TweakSecondaryViewReorderer.Cell {
    func configContent(_ item: Item) {
        displayTextLabel.text = item.displayText
    }
}

private extension TweakSecondaryViewReorderer.Cell {
    func _setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        contentView.addSubview(separator)
        contentView.addSubview(displayTextLabel)
    }

    func _layoutUI() {
        contentView.subviews.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        NSLayoutConstraint.activate([
            displayTextLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            displayTextLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),
            displayTextLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.UI.SecondaryView.horizontalPadding),
            displayTextLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -50),
            separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.UI.SecondaryView.horizontalPadding),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.UI.SecondaryView.horizontalPadding),
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1),
        ])
    }
}

private extension TweakSecondaryViewReorderer.Cell {
    func _displayTextLabel() -> UILabel {
        let l = UILabel()
        l.numberOfLines = 0
        l.textColor = Constants.Color.labelPrimary
        l.font = .systemFont(ofSize: 18)
        return l
    }

    func _separator() -> UIView {
        let v = UIView()
        v.isUserInteractionEnabled = false
        v.backgroundColor = Constants.Color.separator
        return v
    }
}
