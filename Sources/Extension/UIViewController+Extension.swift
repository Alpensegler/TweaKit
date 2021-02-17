//
//  UIViewController+Extension.swift
//  TweaKit
//
//  Created by cokile
//

import UIKit

protocol ChildViewControllerContainer: UIViewController {
    var view: UIView! { get }
    func addChild(_ childController: UIViewController)
}
extension UIViewController: ChildViewControllerContainer { }
extension ChildViewControllerContainer {
    func addChildViewController<Child: UIViewController>(_ child: Child, addSubview: (Self, Child) -> Void = { $0.view.addSubview($1.view) }) {
        guard child.parent == nil else { return }
        addChild(child)
        addSubview(self, child)
        child.didMove(toParent: self)
    }
}
extension UIViewController {
    func removeFromParentController() {
        if parent == nil { return }
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}

extension UIAlertController {
    static func actionSheet(title: String? = nil, actions: [UIAlertAction], barButtonItem: UIBarButtonItem, fromVC: UIViewController?) {
        // if there is a layout constraints error log in console, just ignore it. It's an iOS bug with action sheet style alert controller.
        // FYI: https://stackoverflow.com/a/55653274/4155933
        let sheet = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        sheet.popoverPresentationController?.barButtonItem = barButtonItem // prevent crash on iPad
        actions.forEach(sheet.addAction)
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        fromVC?.present(sheet, animated: true)
    }
    
    static func actionSheet(title: String? = nil, actions: [UIAlertAction], view: UIView, fromVC: UIViewController?) {
        // if there is a layout constraints error log in console, just ignore it. It's an iOS bug with action sheet style alert controller.
        // FYI: https://stackoverflow.com/a/55653274/4155933
        let sheet = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        sheet.popoverPresentationController?.sourceView = view // prevent crash on iPad
        sheet.popoverPresentationController?.sourceRect = view.bounds
        actions.forEach(sheet.addAction)
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        fromVC?.present(sheet, animated: true)
    }
    
    static func alert(title: String?, actions: [UIAlertAction] = [], fromVC: UIViewController?) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        if actions.isEmpty {
            alert.addAction(UIAlertAction(title: "OK", style: .default))
        } else {
            actions.forEach(alert.addAction)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        }
        fromVC?.present(alert, animated: true)
    }
}
