//
//  SimpleSketchView.swift
//  TweaKit-Demo
//  Created by cokile
//
//

import UIKit
import TweaKit

protocol SketchViewDelegate: AnyObject {
    func sketchViewDidUpdate(_ sketchView: SketchView, hasContent: Bool)
}

final class SketchView: UIView {
    var lineWidth: CGFloat = 1
    var lineColor: UIColor = .black
    
    unowned var delegate: SketchViewDelegate!
    
    private var lines: [Line] = []
    private var isFirstTouch = true
}

extension SketchView {
    override var canBecomeFirstResponder: Bool {
        true
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        _drawLines()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else { return }
        _createLine(at: touch.location(in: self))
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let touch = touches.first else { return }
        let isFirstMove = _updateLine(at: touch.location(in: self), smooth: true)
        if isFirstMove {
            _registerUndo(at: lines.count - 1)
        }
        _notifyUpdate()
        setNeedsDisplay()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard let touch = touches.first else { return }
        _updateLine(at: touch.location(in: self), smooth: false)
        setNeedsDisplay()
    }
}

private extension SketchView {
    final class Line {
        let color: UIColor
        var endPoint: CGPoint
        let path: UIBezierPath
        var isHidden = false
        var hasMoved = false
        
        init(color: UIColor, width: CGFloat, location: CGPoint) {
            self.color = color
            self.endPoint = location
            self.path = .init()
            self.path.lineWidth = width
        }
        
        var isVisible: Bool {
            !isHidden && hasMoved
        }
    }
}

private extension SketchView {
    func _createLine(at location: CGPoint) {
        let line = Line(color: lineColor, width: lineWidth, location: location)
        line.path.move(to: location)
        lines.append(line)
        isFirstTouch = true
    }
    
    // return: a flag indicates where it's the line's first movement
    @discardableResult
    func _updateLine(at location: CGPoint, smooth: Bool) -> Bool {
        guard let line = lines.last, location != line.endPoint else { return false }
        if smooth, !isFirstTouch {
            let midPoint = CGPoint(x: (location.x + line.endPoint.x) * 0.5, y: (location.y + line.endPoint.y) * 0.5)
            line.path.addQuadCurve(to: midPoint, controlPoint: line.endPoint)
        } else {
            line.path.addLine(to: location)
        }
        defer {
            line.endPoint = location
            line.hasMoved = true
            isFirstTouch = false
        }
        return !line.hasMoved
    }
    
    func _drawLines() {
        for line in lines where line.isVisible {
            line.color.setStroke()
            line.path.stroke()
        }
    }
    
    func _markLineHidden(_ flag: Bool, at index: Int) {
        lines[index].isHidden = flag
    }
    
    func _clearLines() {
        lines.removeAll(keepingCapacity: true)
    }
    
    func _registerUndo(at index: Int) {
        undoManager?.registerUndo(withTarget: self) { target in
            target._markLineHidden(true, at: index)
            target._registerRedo(at: index)
        }
    }
    
    func _registerRedo(at index: Int) {
        undoManager?.registerUndo(withTarget: self) { target in
            target._markLineHidden(false, at: index)
            target._registerUndo(at: index)
        }
    }
    
    func _clearUndos() {
        undoManager?.removeAllActions(withTarget: self)
    }
    
    func _performUndo() {
        guard undoManager?.canUndo == true else { return }
        undoManager?.undo()
    }
    
    func _performRedo() {
        guard undoManager?.canRedo == true else { return }
        undoManager?.redo()
    }
    
    func _notifyUpdate() {
        delegate.sketchViewDidUpdate(self, hasContent: lines.contains { $0.isVisible })
    }
}

private extension SketchView {
    func isActionEnabled(for action: SketchAction) -> Bool {
        switch action {
        case .clear: return lines.contains { $0.isVisible }
        case .undo: return undoManager?.canUndo == true
        case .redo: return undoManager?.canRedo == true
        }
    }
    
    func selector(for action: SketchAction) -> Selector {
        switch action {
        case .clear: return #selector(_clear)
        case .undo: return  #selector(_undo)
        case .redo: return  #selector(_redo)
        }
    }
    
    func image(for action: SketchAction) -> UIImage? {
        switch action {
        case .clear: return UIImage(named: "icon_sketch_clear")
        case .undo: return  UIImage(named: "icon_sketch_undo")
        case .redo: return  UIImage(named: "icon_sketch_redo")
        }
    }
    
    @objc func _clear(_ sender: UIButton) {
        _clearLines()
        _clearUndos()
        _notifyUpdate()
        setNeedsDisplay()
    }
    
    @objc func _undo(_ sender: UIButton) {
        _performUndo()
        _notifyUpdate()
        setNeedsDisplay()
    }
    
    @objc func _redo(_ sender: UIButton) {
        _performRedo()
        _notifyUpdate()
        setNeedsDisplay()
    }
}

// MARK: - Aciton

enum SketchAction: String, CaseIterable, TradedTweakable, TweakSecondaryViewItemConvertible {
    case clear
    case undo
    case redo
}

final class SketchActionView: UIView {
    private var buttons: [SketchAction: UIButton] = [:]
    private let buttonSize: CGSize = .init(width: 40, height: 40)
    private let buttonPadding: CGFloat = 16
}

extension SketchActionView {
    override var intrinsicContentSize: CGSize {
        .init(width: buttonSize.width, height: CGFloat(buttons.count) * (buttonSize.height + buttonPadding))
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        _calibratetButtons(for: buttons.keys.map { $0 })
    }
}

extension SketchActionView {
    func reload(with actions: [SketchAction], for sketchView: SketchView) {
        let oldButtonCount = buttons.count
        let newButtonCount = actions.count
        _upsertButtons(for: actions, in: sketchView)
        _layoutButtons(for: actions)
        _calibratetButtons(for: actions)
        if oldButtonCount != newButtonCount {
            invalidateIntrinsicContentSize()
        }
    }
}

private extension SketchActionView {
    func _upsertButtons(for actions: [SketchAction], in sketchView: SketchView) {
        actions.forEach {
            _upsertButton(for: $0, in: sketchView)
        }
    }
    
    func _layoutButtons(for actions: [SketchAction]) {
        actions.enumerated().forEach { index, action in
            _layoutButton(for: action, at: index)
        }
    }
    
    func _calibratetButtons(for actions: [SketchAction]) {
        actions.forEach {
            _calibratetButton(for: $0)
        }
    }
}

private extension SketchActionView {
    func _upsertButton(for action: SketchAction, in sketchView: SketchView) {
        let button: UIButton
        if let existingButton = buttons[action] {
            button = existingButton
        } else {
            button = UIButton(type: .custom)
            buttons[action] = button
            button.setImage(sketchView.image(for: action), for: .normal)
            button.addTarget(sketchView, action: sketchView.selector(for: action), for: .touchUpInside)
            if #available(iOS 13.0, *) { button.layer.cornerCurve = .circular }
            button.layer.cornerRadius = buttonSize.height * 0.5
            button.layer.shadowPath = UIBezierPath(roundedRect: .init(origin: .zero, size: buttonSize), cornerRadius: buttonSize.height * 0.5).cgPath
            button.layer.shadowColor = UIColor.black.withAlphaComponent(0.06).cgColor
            button.layer.shadowOffset = .init(width: 0, height: 6)
            button.layer.shadowRadius = 5
            addSubview(button)
        }
        let isEnabled = sketchView.isActionEnabled(for: action)
        if button.isEnabled != isEnabled {
            button.isEnabled = isEnabled
            button.backgroundColor = UIColor(named: button.isEnabled ? "color_button_background" : "color_button_background_disabled")
        }
    }
    
    func _layoutButton(for action: SketchAction, at index: Int) {
        guard let button = buttons[action] else { return }
        button.frame = .init(origin: .init(x: 0, y: CGFloat(index) * (buttonSize.height + buttonPadding)), size: buttonSize)
    }
    
    func _calibratetButton(for action: SketchAction) {
        guard let button = buttons[action] else { return }
        if #available(iOS 13.0, *), traitCollection.userInterfaceStyle == .dark {
            button.layer.shadowOpacity = 0
        } else {
            button.layer.shadowOpacity = 1
        }
    }
}
