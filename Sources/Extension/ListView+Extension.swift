//
//  ListView+Extension.swift
//  TweaKit
//
//  Created by cokile
//

import UIKit

extension UITableView {
    func register<Cell: UITableViewCell>(cell: Cell.Type) {
        register(cell.self, forCellReuseIdentifier: NSStringFromClass(cell.self))
    }
    
    func dequeue<Cell: UITableViewCell>(cell: Cell.Type, for indexPath: IndexPath) -> Cell {
        dequeueReusableCell(withIdentifier: NSStringFromClass(cell.self), for: indexPath) as! Cell
    }
    
    func register<HeaderFooter: UITableViewHeaderFooterView>(headerFooter: HeaderFooter.Type) {
        register(headerFooter.self, forHeaderFooterViewReuseIdentifier: NSStringFromClass(headerFooter.self))
    }
    
    func dequeue<HeaderFooter: UITableViewHeaderFooterView>(headerFooter: HeaderFooter.Type) -> HeaderFooter {
        dequeueReusableHeaderFooterView(withIdentifier: NSStringFromClass(headerFooter.self)) as! HeaderFooter
    }
}

extension UICollectionView {
    func register<Cell: UICollectionViewCell>(cell: Cell.Type) {
        register(cell.self, forCellWithReuseIdentifier: NSStringFromClass(cell.self))
    }
    
    func dequeue<Cell: UICollectionViewCell>(cell: Cell.Type, for indexPath: IndexPath) -> Cell {
        dequeueReusableCell(withReuseIdentifier: NSStringFromClass(cell.self), for: indexPath) as! Cell
    }
}
