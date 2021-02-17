//
//  TweakSearchViewController.swift
//  TweaKit
//
//  Created by cokile
//

import UIKit

final class TweakSearchViewController: UIViewController {
    private lazy var textField = _textField()
    private lazy var cancelButton = _cancelButton()
    private lazy var hairline = _hairline()
    private lazy var loadingIndicator = _loadingIndicator()
    private lazy var resultViewController = _resultViewController()
    private lazy var historyViewController = _historyViewController()
    
    private unowned let context: TweakContext
    private var searcher: TweakSearcher
    private var lastText: String?
    
    deinit {
        _deactivateSearch()
        _unregisterNotifications()
    }
    
    init(context: TweakContext) {
        self.context = context
        self.searcher = .init(context: context)
        super.init(nibName: nil, bundle: nil)
        self.searcher.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TweakSearchViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        _registerNotifications()
        _bindSearcher()
        _setupUI()
        _layoutUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startListeningFloating(in: context)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopListeningFloating(in: context)
    }
}

extension TweakSearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
}

extension TweakSearchViewController: TweakSearcherDelegate {
    var currentKeyword: String? {
        textField.text
    }
}

extension TweakSearchViewController: TweakSearchHistoryViewControllerDelegate {
    func searchHistoryViewController(_ viewController: TweakSearchHistoryViewController, didSelectHistory history: String) {
        _searchHistory(history)
    }
    
    func searchHistoryViewController(_ viewController: TweakSearchHistoryViewController, didDeleteHistory history: String) {
        _removeHistory(history)
    }
}

extension TweakSearchViewController: TweakFloatingAudience {
    func willTransist(fromCategory: TweakFloatingParticipantCategory, toCategory: TweakFloatingParticipantCategory) {
        guard fromCategory == .searchList else { return }
        _endTyping()
        _toggleDimmingViewToShow(false)
    }
    
    func transist(fromCategory: TweakFloatingParticipantCategory, toCategory: TweakFloatingParticipantCategory) {
        if fromCategory == .searchList {
            _toggleContainerToShow(false, animated: true)
        } else if toCategory == .searchList {
            _toggleContainerToShow(true, animated: true)
        }
    }
    
    func didTransist(fromCategory: TweakFloatingParticipantCategory, toCategory: TweakFloatingParticipantCategory) {
        if fromCategory == .searchList {
            _toggleContainerToShow(false, animated: false)
            _toggleDimmingViewToShow(false)
        } else if toCategory == .searchList {
            _toggleContainerToShow(true, animated: false)
            _toggleDimmingViewToShow(true)
        }
    }
}

private extension TweakSearchViewController {
    func _bindSearcher() {
        searcher.bind { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .showLoading:
                self.loadingIndicator.startAnimating()
                self.resultViewController.tableView.isHidden = true
                self.historyViewController.tableView.isHidden = true
            case .showResult:
                self.loadingIndicator.stopAnimating()
                self.resultViewController.tableView.isHidden = false
                self.historyViewController.tableView.isHidden = true
            case .showHistory:
                self.loadingIndicator.stopAnimating()
                self.resultViewController.tableView.isHidden = true
                self.historyViewController.tableView.isHidden = false
            case let .updateTweakResults(tweaks, keyword):
                self.resultViewController.setScene(.search(keyword: keyword))
                self.resultViewController.setTweaks(tweaks, in: self.context, scrollToTop: true)
            case .updateHistories(let histories):
                self.historyViewController.setHistories(histories, scrollToTop: true)
            }
        }
        
        searcher.bootstrap(async: view.window == nil)
    }
    
    func _setupUI() {
        view.backgroundColor = Constants.Color.backgroundPrimary
        addChildViewController(resultViewController)
        addChildViewController(historyViewController)
        view.addSubview(textField)
        view.addSubview(cancelButton)
        view.addSubview(hairline)
        view.addSubview(loadingIndicator)
        
        textField.becomeFirstResponder()
    }
    
    func _layoutUI() {
        view.subviews.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            textField.heightAnchor.constraint(equalToConstant: Constants.UI.Search.textFieldHeight),
            textField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 22),
            textField.trailingAnchor.constraint(equalTo: cancelButton.leadingAnchor, constant: -14),
            cancelButton.centerYAnchor.constraint(equalTo: textField.centerYAnchor),
            cancelButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            hairline.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            hairline.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            hairline.heightAnchor.constraint(equalToConstant: 1),
            hairline.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 12),
            loadingIndicator.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            loadingIndicator.topAnchor.constraint(equalTo: hairline.bottomAnchor, constant: 50),
            resultViewController.tableView.topAnchor.constraint(equalTo: hairline.bottomAnchor),
            resultViewController.tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            resultViewController.tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            resultViewController.tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            historyViewController.tableView.topAnchor.constraint(equalTo: hairline.bottomAnchor),
            historyViewController.tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            historyViewController.tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            historyViewController.tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}

private extension TweakSearchViewController {
    func _registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(_onWillTernimate), name: UIApplication.willTerminateNotification, object: nil)
    }
    
    func _unregisterNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func _onWillTernimate(_ notification: Notification) {
        _deactivateSearch()
    }
}

private extension TweakSearchViewController {
    var dimmingView: UIView? {
        if #available(iOS 13.0, *), traitCollection.userInterfaceIdiom == .phone {
            // hack logic to get the card presentation style dimming view through "Debug View Hierarchy"
            // window
            // -- UITransitionView
            //   -- UIDropShadowView
            //     -- UIDimmingView
            // -- UITransitionView
            //   -- ...
            return view.window?.subviews.first?.subviews.first?.subviews.first {
                NSStringFromClass(type(of: $0)).contains("UIDimming")
            }
        } else {
            return nil
        }
    }
    
    var containerView: UIView {
        if #available(iOS 13.0, *), traitCollection.userInterfaceIdiom == .phone {
            return presentationController?.containerView ?? view
        } else {
            return view
        }
    }
    
    func _endTyping() {
        guard textField.isFirstResponder else { return }
        textField.resignFirstResponder()
    }
    
    func _toggleDimmingViewToShow(_ flag: Bool) {
        dimmingView?.isHidden = !flag
    }
    
    func _toggleContainerToShow(_ flag: Bool, animated: Bool) {
        let key = "floating-opacity"
        
        guard animated else {
            disableImplicityAnimation {
                containerView.layer.opacity = flag ? 1 : 0
                containerView.layer.removeAnimation(forKey: key)
            }
            return
        }
        
        let anim = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
        anim.fromValue = flag ? 0 : 1
        anim.toValue = flag ? 1 : 0
        anim.duration = Constants.UI.Floating.fadeDuration
        anim.fillMode = .both
        anim.isRemovedOnCompletion = false
        containerView.layer.add(anim, forKey: key)
    }
}

private extension TweakSearchViewController {
    func _search(with keyword: String) {
        searcher.search(with: keyword, debounce: true)
    }
    
    func _searchHistory(_ history: String) {
        textField.text = history
        searcher.search(with: history, debounce: false)
    }
    
    func _removeHistory(_ history: String) {
        searcher.removeHistory(history)
    }
    
    func _deactivateSearch() {
        searcher.deactivate()
    }
}

private extension TweakSearchViewController {
    @objc func _cancelButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @objc func _textFieldTextChanged(_ sender: UITextField) {
        lastText = sender.text
        guard sender.markedTextRange == nil else { return }
        _search(with: sender.text ?? "")
    }
    
    @objc func _textFieldDidExit(_ sender: UITextField) {
        guard lastText != sender.text else { return }
        // text is auto corrected
        _search(with: sender.text ?? "")
    }
}

private extension TweakSearchViewController {
    func _textField() -> UITextField {
        let iconSize: CGFloat = 18
        let iconPadding: CGFloat = 6
        let view = UIView(frame: .init(x: 0, y: (Constants.UI.Search.textFieldHeight - iconSize).half, width: iconSize + 2 * iconPadding, height: iconSize))
        let icon = UIImageView(frame: .init(x: iconPadding, y: 0, width: iconSize, height: iconSize))
        icon.image = Constants.Assets.naviSearch.withRenderingMode(.alwaysTemplate)
        icon.tintColor = Constants.Color.searchPlaceholder
        icon.contentMode = .scaleAspectFill
        view.addSubview(icon)
        let f = UITextField()
        f.leftView = view
        f.leftViewMode = .always
        f.clearButtonMode = .whileEditing
        f.returnKeyType = .search
        f.enablesReturnKeyAutomatically = true
        f.backgroundColor = Constants.Color.searchBachground
        f.font = .systemFont(ofSize: 17)
        f.textColor = Constants.Color.searchText
        f.tintColor = f.textColor
        f.attributedPlaceholder = NSAttributedString(string: "Search", attributes: [
            .foregroundColor: Constants.Color.searchPlaceholder,
            .font: f.font!,
        ])
        f.layer.addCorner(radius: 10)
        f.addTarget(self, action: #selector(_textFieldTextChanged), for: .editingChanged)
        f.addTarget(self, action: #selector(_textFieldDidExit), for: .editingDidEndOnExit)
        f.delegate = self
        return f
    }
    
    func _cancelButton() -> UIButton {
        let b = UIButton(type: .system)
        b.addTarget(self, action: #selector(_cancelButtonTapped), for: .touchUpInside)
        b.setTitle("Cancel", for: .normal)
        b.tintColor = Constants.Color.actionBlue
        b.titleLabel?.font = .systemFont(ofSize: 18)
        return b
    }
    
    func _hairline() -> UIView {
        let v = UIView()
        v.isUserInteractionEnabled = false
        v.backgroundColor = Constants.Color.seperator
        return v
    }
    
    func _loadingIndicator() -> UIActivityIndicatorView {
        let v: UIActivityIndicatorView
        if #available(iOS 13.0, *) {
            v = UIActivityIndicatorView(style: .medium)
        } else {
            v = UIActivityIndicatorView(style: .gray)
        }
        return v
    }
    
    func _resultViewController() -> TweakListViewController {
        let v = TweakListViewController(scene: .search(keyword: ""))
        return v
    }
    
    func _historyViewController() -> TweakSearchHistoryViewController {
        let v = TweakSearchHistoryViewController(delegate: self)
        v.tableView.backgroundColor = view.backgroundColor
        return v
    }
}

private extension Constants.UI.Search {
    static let textFieldHeight: CGFloat = 36
}
