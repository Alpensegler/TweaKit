//
//  TweakSecondaryViewSelector.swift
//  TweaKit
//
//  Created by cokile
//

import UIKit

final class TweakSecondaryViewSelector<Item: Selectable>: UITableViewController {
    private weak var currentTweak: AnyTweak?
    private var selectedIndex = 0
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
        cell.configIsSelected(indexPath.row == selectedIndex)
        return cell
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? Cell else { return }
        cell.configIsSelected(indexPath.row == selectedIndex)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let tweak = currentTweak, indexPath.row != selectedIndex else { return }
        updateTweak(tweak, withValue: items[indexPath.row], manually: true)
    }
}

extension TweakSecondaryViewSelector: TweakSecondaryView {
    func reload(withTweak tweak: AnyTweak, manually: Bool) {
        guard let allItems = (tweak as? SelectableTweak<Item>)?.options else { return }
        guard let selectedItem = tweak.currentValue as? Item else { return }
        currentTweak = tweak
        let oldSelectedIndex = selectedIndex
        selectedIndex = allItems.firstIndex(of: selectedItem) ?? 0

        if allItems != items {
            items = allItems
            tableView.reloadData()
        } else if oldSelectedIndex != selectedIndex {
            (tableView.cellForRow(at: IndexPath(row: oldSelectedIndex, section: 0)) as? Cell)?.configIsSelected(false)
            (tableView.cellForRow(at: IndexPath(row: selectedIndex, section: 0)) as? Cell)?.configIsSelected(true)
        }
    }
}

private extension TweakSecondaryViewSelector {
    func _setupUI() {
        view.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 50
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.register(cell: Cell.self)
    }
}

// MARK: - Cell

private extension TweakSecondaryViewSelector {
    final class Cell: UITableViewCell {
        private lazy var displayTextLabel = _displayTextLabel()
        private lazy var tickImageView = _tickImageView()
        private lazy var separator = _separator()
        private lazy var highlightBackground = _highlightBackground()

        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            _setupUI()
            _layoutUI()
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            _calibrateUI()
        }

        override func setSelected(_ selected: Bool, animated: Bool) {
            super.setSelected(selected, animated: animated)
            _setHighlight(selected, animated: animated)
        }

        override func setHighlighted(_ highlighted: Bool, animated: Bool) {
            super.setHighlighted(highlighted, animated: animated)
            _setHighlight(highlighted, animated: animated)
        }
    }
}

extension TweakSecondaryViewSelector.Cell {
    func configContent(_ item: Item) {
        displayTextLabel.text = item.displayText
    }

    func configIsSelected(_ flag: Bool) {
        tickImageView.isHidden = !flag
    }
}

private extension TweakSecondaryViewSelector.Cell {
    func _setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        contentView.addSubview(separator)
        contentView.addSubview(highlightBackground)
        contentView.addSubview(displayTextLabel)
        contentView.addSubview(tickImageView)
    }

    func _layoutUI() {
        contentView.subviews.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        NSLayoutConstraint.activate([
            displayTextLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            displayTextLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),
            displayTextLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.UI.SecondaryView.horizontalPadding),
            tickImageView.leadingAnchor.constraint(greaterThanOrEqualTo: displayTextLabel.trailingAnchor, constant: 25),
            tickImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            tickImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.UI.SecondaryView.horizontalPadding),
            separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.UI.SecondaryView.horizontalPadding),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.UI.SecondaryView.horizontalPadding),
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1),
        ])
    }

    func _calibrateUI() {
        highlightBackground.frame = contentView.bounds
    }

    func _setHighlight(_ flag: Bool, animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.25, delay: 0, options: .beginFromCurrentState, animations: { [unowned self] in
                highlightBackground.alpha = flag ? 0.1 : 0
                separator.alpha = flag ? 0 : 1
            })
        } else {
            highlightBackground.alpha = flag ? 0.1 : 0
            separator.alpha = flag ? 0 : 1
        }
    }
}

private extension TweakSecondaryViewSelector.Cell {
    func _displayTextLabel() -> UILabel {
        let l = UILabel()
        l.numberOfLines = 0
        l.textColor = Constants.Color.labelPrimary
        l.font = .systemFont(ofSize: 18)
        return l
    }

    func _tickImageView() -> UIImageView {
        let v = UIImageView()
        v.isHidden = true
        v.image = Constants.Assets.tick
        return v
    }

    func _separator() -> UIView {
        let v = UIView()
        v.isUserInteractionEnabled = false
        v.backgroundColor = Constants.Color.separator
        return v
    }

    func _highlightBackground() -> UIView {
        let v = UIView()
        v.isUserInteractionEnabled = false
        v.backgroundColor = Constants.Color.actionBlue
        v.alpha = 0
        return v
    }
}
