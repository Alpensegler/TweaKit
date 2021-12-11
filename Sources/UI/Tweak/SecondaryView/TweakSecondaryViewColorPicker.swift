//
//  TweakSecondaryViewColorPicker.swift
//  TweaKit
//
//  Created by cokile
//

import UIKit

final class TweakSecondaryViewColorPicker: UITableViewController {
    private weak var currentTweak: AnyTweak?
    private var currentColor: Color?
    
    init() {
        super.init(style: .grouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TweakSecondaryViewColorPicker {
    override func viewDidLoad() {
        super.viewDidLoad()
        _setupUI()
    }
}

extension TweakSecondaryViewColorPicker {
    override func numberOfSections(in tableView: UITableView) -> Int {
        ColorComponent.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(cell: Cell.self, for: indexPath)
        cell.configWith(colorComponent: ColorComponent.allCases[indexPath.section], colorUpdater: self)
        if let color = currentColor {
            cell.render(withColor: color)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        Constants.UI.SecondaryView.rowHeight
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        Constants.UI.SecondaryView.sectionHeaderHeight
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        Constants.UI.SecondaryView.sectionFooterHeight
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeue(headerFooter: SectionHeaderView.self)
        header.config(with: ColorComponent.allCases[section])
        return header
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        tableView.dequeue(headerFooter: SectionFooterView.self)
    }
}

extension TweakSecondaryViewColorPicker: TweakSecondaryView {
    var estimatedHeight: CGFloat {
        let componentHeight = Constants.UI.SecondaryView.sectionHeaderHeight
            + Constants.UI.SecondaryView.rowHeight
            + Constants.UI.SecondaryView.sectionFooterHeight
        return Constants.UI.SecondaryView.headerHeight
            + CGFloat(ColorComponent.allCases.count) * componentHeight
            + Constants.UI.SecondaryView.footerHeight
    }
    
    func reload(withTweak tweak: AnyTweak, manually: Bool) {
        view.isUserInteractionEnabled = false
        defer { view.isUserInteractionEnabled = true }
        guard let color = tweak.currentValue as? UIColor else { return }
        currentTweak = tweak
        if currentColor == nil || currentColor!.rgba != color.rgba.ui {
            tableView.endEditing(true)
            currentColor = _color(from: color)
            colorRenderers.forEach { $0.render(withColor: currentColor!) }
        }
    }
}

extension TweakSecondaryViewColorPicker: ColorUpdater {
    private var colorRenderers: [ColorRenderer] {
        var views: [UIView?] = .init(capacity: 5)
        views.append(tableView.tableHeaderView)
        if tableView.window != nil {
            views.append(contentsOf: tableView.visibleCells)
        }
        return views.compactMap { $0 as? ColorRenderer }
    }
    
    fileprivate func updateColor(with update: ColorUpdate) {
        let newUIColor: UIColor?
        switch update {
        case .whole(let hex):
           newUIColor = _makeNewUIColor(with: hex)
        case let .component(comp, value):
            newUIColor = _makeNewUIColor(with: comp, value: value)
        }
        guard let uiColor = newUIColor, let tweak = currentTweak else { return }
        updateTweak(tweak, withValue: uiColor, manually: true)
    }
    
    private func _makeNewUIColor(with hex: String) -> UIColor? {
        if hex == currentColor?.hex { return nil }
        return UIColor(hexString: hex)
    }
    
    private func _makeNewUIColor(with colorComponent: ColorComponent, value: Int) -> UIColor? {
        guard let rgba = currentColor?.rgba else { return nil }
        switch colorComponent {
        case .r where value != rgba.r:
            return UIColor(r: CGFloat(value), g: CGFloat(rgba.g), b: CGFloat(rgba.b), a: CGFloat(rgba.a) / 100)
        case .g where value != rgba.g:
            return UIColor(r: CGFloat(rgba.r), g: CGFloat(value), b: CGFloat(rgba.b), a: CGFloat(rgba.a) / 100)
        case .b where value != rgba.b:
            return UIColor(r: CGFloat(rgba.r), g: CGFloat(rgba.g), b: CGFloat(value), a: CGFloat(rgba.a) / 100)
        case .a where value != rgba.a:
            return UIColor(r: CGFloat(rgba.r), g: CGFloat(rgba.g), b: CGFloat(rgba.b), a: CGFloat(value) / 100)
        default:
            return nil
        }
    }
    
    private func _color(from uiColor: UIColor) -> Color {
        (uiColor, uiColor.rgba.ui, uiColor.toRGBHexString(includePrefix: false))
    }
}

private extension TweakSecondaryViewColorPicker {
    func _setupUI() {
        view.backgroundColor = .clear
        tableView.bounces = false
        tableView.keyboardDismissMode = .onDrag
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.showsVerticalScrollIndicator = false
        tableView.tableHeaderView = HeaderView(frame: .init(x: 0, y: 0, width: tableView.frame.width, height: 124), updater: self)
        tableView.tableFooterView = UIView(frame: .init(x: 0, y: 0, width: 0, height: 34))
        tableView.register(cell: Cell.self)
        tableView.register(headerFooter: SectionHeaderView.self)
        tableView.register(headerFooter: SectionFooterView.self)
    }
}

// MARK: - HeaderView

private final class HeaderView: UIView {
    private lazy var allowedCharacters = _allowedCharacters()
    private lazy var previewView = _previewView()
    private lazy var textField = _textField()
    private lazy var airline = _airline()
    
    private unowned let updater: ColorUpdater
    
    init(frame: CGRect, updater: ColorUpdater) {
        self.updater = updater
        super.init(frame: frame)
        _setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        _layoutUI()
    }
}

extension HeaderView: ColorRenderer {
    func render(withColor color: Color) {
        textField.text = color.hex
        previewView.update(withColor: color)
    }
}

private extension HeaderView {
    func _setupUI() {
        addSubview(previewView)
        addSubview(textField)
        addSubview(airline)
    }
    
    func _layoutUI() {
        textField.frame.origin = .init(
            x: frame.width - Constants.UI.SecondaryView.horizontalPadding - textField.frame.width,
            y: ceil(previewView.frame.minY + (previewView.frame.height - textField.frame.height).half)
        )
        previewView.frame = .init(
            x: Constants.UI.SecondaryView.horizontalPadding,
            y: 17,
            width: textField.frame.minX - 24 - Constants.UI.SecondaryView.horizontalPadding,
            height: 75
        )
        airline.frame = .init(
            x: Constants.UI.SecondaryView.horizontalPadding,
            y: previewView.frame.maxY + 15,
            width: frame.width - 2 * Constants.UI.SecondaryView.horizontalPadding,
            height: 1
        )
    }
}

private extension HeaderView {
    func _allowedCharacters() -> CharacterSet {
        .init(charactersIn: "0123456789ABCDEF")
    }
    
    func _previewView() -> PreviewView {
        let v = PreviewView()
        v.isUserInteractionEnabled = false
        return v
    }
    
    func _textField() -> TextField {
        let tf = TextField(frame: .init(x: 0, y: 0, width: 170, height: 36))
        tf.prefix = "Hex #"
        tf.autocapitalizationType = .allCharacters
        tf.inputTextTransformer = { [unowned self] text in
            guard text.count <= 6 && text.uppercased().unicodeScalars.allSatisfy({ allowedCharacters.contains($0) }) else {
                return nil
            }
            return text.uppercased()
        }
        tf.canCommitText = { [unowned self] text in
            text.count == 6 && text.unicodeScalars.allSatisfy { allowedCharacters.contains($0) }
        }
        tf.commitText = { [unowned self] text in
            updater.updateColor(with: .whole(text))
        }
        return tf
    }
    
    func _airline() -> UIView {
        let v = UIView()
        v.backgroundColor = Constants.Color.separator
        v.isUserInteractionEnabled = false
        return v
    }
}

// MARK: - Section Header View / Section Footer View

private final class SectionHeaderView: UITableViewHeaderFooterView {
    private lazy var label = _label()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        _setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        _layoutUI()
    }
}

extension SectionHeaderView {
    func config(with component: ColorComponent) {
        label.text = component.rawValue
    }
}

private extension SectionHeaderView {
    func _setupUI() {
        addSubview(label)
    }
    
    func _layoutUI() {
        label.frame = bounds.insetBy(dx: Constants.UI.SecondaryView.horizontalPadding, dy: 0)
    }
}

private extension SectionHeaderView {
    func _label() -> UILabel {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14, weight: .bold)
        l.textColor = Constants.Color.labelSecondary
        return l
    }
}

private final class SectionFooterView: UITableViewHeaderFooterView { }

// MARK: - Cell

private final class Cell: UITableViewCell {
    private lazy var slider = _slider()
    private lazy var textField = _textField()
    
    private var colorComponent: ColorComponent?
    private weak var colorUpdater: ColorUpdater?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        _setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        _layoutUI()
    }
}

extension Cell: ColorRenderer {
    func render(withColor color: Color) {
        guard let colorComponent = colorComponent else { return }
        _renderSliderWith(colorComponent: colorComponent, color: color)
        _renderTextFieldWith(colorComponent: colorComponent, color: color)
    }
}

extension Cell {
    func configWith(colorComponent: ColorComponent, colorUpdater: ColorUpdater) {
        self.colorComponent = colorComponent
        self.colorUpdater = colorUpdater
        _configTextField(with: colorComponent)
        _configSlider(with: colorComponent)
    }
}

private extension Cell {
    func _renderSliderWith(colorComponent: ColorComponent, color: Color) {
        slider.updateWith(colorComponent: colorComponent, color: color)
    }
    
    func _renderTextFieldWith(colorComponent: ColorComponent, color: Color) {
        switch colorComponent {
        case .r:
            textField.text = color.rgba.r.description
        case .g:
            textField.text = color.rgba.g.description
        case .b:
            textField.text = color.rgba.b.description
        case .a:
            textField.text = color.rgba.a.description
        }
    }
    
    func _configSlider(with colorComponent: ColorComponent) {
        slider.onValueChange = { [unowned self] value in
            colorUpdater?.updateColor(with: .component(colorComponent, value))
        }
    }
    
    func _configTextField(with colorComponent: ColorComponent) {
        switch colorComponent {
        case .r, .g, .b:
            textField.suffix = nil
            textField.inputTextTransformer = { text in
                if text.isEmpty { return text }
                guard let value = Int(text) else { return nil }
                return 0 <= value && value <= 255 ? text : nil
            }
            textField.canCommitText = { text in
                guard let value = Int(text) else { return false }
                return 0 <= value && value <= 255
            }
        case .a:
            textField.suffix = "%"
            textField.inputTextTransformer = { text in
                if text.isEmpty { return text }
                guard let value = Int(text) else { return nil }
                return 0 <= value && value <= 100 ? text : nil
            }
            textField.canCommitText = { text in
                guard let value = Int(text) else { return false }
                return 0 <= value && value <= 100
            }
        }
        textField.commitText = { [unowned self] text in
            guard let value = Int(text) else { return }
            colorUpdater?.updateColor(with: .component(colorComponent, value))
        }
    }
}

private extension Cell {
    func _setupUI() {
        backgroundColor = .clear
        contentView.addSubview(slider)
        contentView.addSubview(textField)
    }
    
    func _layoutUI() {
        textField.frame.origin = .init(
            x: contentView.frame.width - Constants.UI.SecondaryView.horizontalPadding - textField.frame.width,
            y: (contentView.frame.height - textField.frame.height).half
        )
        slider.frame = .init(
            x: Constants.UI.SecondaryView.horizontalPadding,
            y: 0,
            width: textField.frame.minX - Constants.UI.SecondaryView.horizontalPadding - 16,
            height: frame.height)
    }
}

private extension Cell {
    @objc func _handleInputDone(_ sender: TextField) {
        textField.resignFirstResponder()
    }
}

private extension Cell {
    func _slider() -> Slider {
        let s = Slider()
        return s
    }
    
    func _textField() -> TextField {
        let tf = TextField(frame: .init(x: 0, y: 0, width: 75, height: 36))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(_handleInputDone))
        tf.addItems([space, done])
        tf.keyboardType = .numberPad
        return tf
    }
}

// MARK: - Slider

private final class Slider: HitOutsideView {
    private lazy var cursor = _cursor()
    private lazy var cursorFill = _cursorFill()
    private lazy var leftCorner = _corner(isLeft: true)
    private lazy var rightCorner = _corner(isLeft: false)
    private lazy var gradient = _gradient()
    private lazy var backgroundImage = _backgroundImageView()
    
    private var value: Int = 0
    private var range: ClosedRange<Int>!
    var onValueChange: ((Int) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        _layoutUI()
    }
}

extension Slider {
    func updateWith(colorComponent: ColorComponent, color: Color) {
        _updateRangeWith(colorComponent: colorComponent, color: color)
        _updateCursorWith(colorComponent: colorComponent, color: color)
        _updateBackgroundImageWith(colorComponent: colorComponent, color: color)
        disableImplicitAnimation {
            _updateCursorFillWith(colorComponent: colorComponent, color: color)
            _updateGradientWith(colorComponent: colorComponent, color: color)
        }
    }
    
    func _updateRangeWith(colorComponent: ColorComponent, color: Color) {
        if colorComponent == .a {
            range = 0...100
        } else {
            range = 0...255
        }
    }
    
    func _updateCursorWith(colorComponent: ColorComponent, color: Color) {
        let percent: CGFloat
        switch colorComponent {
        case .r where value != color.rgba.r:
            percent = CGFloat(color.rgba.r) / CGFloat(range.distance)
            value = color.rgba.r
        case .g where value != color.rgba.g:
            percent = CGFloat(color.rgba.g) / CGFloat(range.distance)
            value = color.rgba.g
        case .b where value != color.rgba.b:
            percent = CGFloat(color.rgba.b) / CGFloat(range.distance)
            value = color.rgba.b
        case .a where value != color.rgba.a:
            percent = CGFloat(color.rgba.a) / CGFloat(range.distance)
            value = color.rgba.a
        default:
            return
        }
        if frame.size == .zero {
            // dispatch to next run loop since slider haven't layouted in superview
            DispatchQueue.main.async { [unowned self] in
                cursor.center.x = (gradient.frame.minX + gradient.frame.width * percent).clamped(from: gradient.frame.minX, to: gradient.frame.maxX)
            }
        } else {
            cursor.center.x = (gradient.frame.minX + gradient.frame.width * percent).clamped(from: gradient.frame.minX, to: gradient.frame.maxX)
        }
    }
    
    func _updateBackgroundImageWith(colorComponent: ColorComponent, color: Color) {
        if colorComponent == .a {
            if backgroundImage.image == nil {
                backgroundImage.image = Constants.Assets.alphaBackground.resizableImage(withCapInsets: .zero, resizingMode: .tile)
            }
        } else {
            if backgroundImage.image != nil {
                backgroundImage.image = nil
            }
        }
    }
    
    func _updateCursorFillWith(colorComponent: ColorComponent, color: Color) {
        cursorFill.backgroundColor = color.uiColor.cgColor
    }
    
    func _updateGradientWith(colorComponent: ColorComponent, color: Color) {
        let leftColor: UIColor
        let rightColor: UIColor
        switch colorComponent {
        case .r:
            leftColor = UIColor(r: 0, g: CGFloat(color.rgba.g), b: CGFloat(color.rgba.b))
            rightColor = UIColor(r: 255, g: CGFloat(color.rgba.g), b: CGFloat(color.rgba.b))
        case .g:
            leftColor = UIColor(r: CGFloat(color.rgba.r), g: 0, b: CGFloat(color.rgba.b))
            rightColor = UIColor(r: CGFloat(color.rgba.r), g: 255, b: CGFloat(color.rgba.b))
        case .b:
            leftColor = UIColor(r: CGFloat(color.rgba.r), g: CGFloat(color.rgba.g), b: 0)
            rightColor = UIColor(r: CGFloat(color.rgba.r), g: CGFloat(color.rgba.g), b: 255)
        case .a:
            leftColor = .clear
            rightColor = color.uiColor.withAlphaComponent(1)
        }
        leftCorner.backgroundColor = leftColor.cgColor
        rightCorner.backgroundColor = rightColor.cgColor
        gradient.colors = [leftCorner.backgroundColor!, rightCorner.backgroundColor!]
    }
}

private extension Slider {
    func _setupUI() {
        extendInset = .init(inset: -8)
        addSubview(backgroundImage)
        layer.addSublayer(leftCorner)
        layer.addSublayer(gradient)
        layer.addSublayer(rightCorner)
        addSubview(cursor)
        cursor.layer.addSublayer(cursorFill)
        cursor.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(_handlePan)))
    }
    
    func _layoutUI() {
        layer.addCorner(radius: frame.halfHeight, clipsContent: true)
        
        backgroundImage.frame = bounds
        
        disableImplicitAnimation {
            gradient.frame = bounds.insetBy(dx: frame.halfHeight, dy: 0)
            leftCorner.frame = .init(x: 0, y: 0, width: frame.halfHeight, height: frame.height)
            rightCorner.frame = .init(x: frame.width - frame.halfHeight, y: 0, width: frame.halfHeight, height: frame.height)
        }
    }
}

private extension Slider {
    @objc func _handlePan(_ pan: UIPanGestureRecognizer) {
        switch pan.state {
        case .changed:
            let translation = pan.translation(in: self)
            pan.setTranslation(.zero, in: self)
            cursor.center.x = (cursor.center.x + translation.x).clamped(from: gradient.frame.minX, to: gradient.frame.maxX)
            _setValue(((cursor.center.x - gradient.frame.minX) / gradient.frame.width).clamped(from: 0, to: 1))
        case .ended:
            break
        default:
            break
        }
    }
    
    func _setValue(_ percent: CGFloat) {
        guard let range = range else { return }
        let value = Int((CGFloat(range.lowerBound) + CGFloat(range.distance) * percent).rounded(to: .integer))
        guard self.value != value else { return }
        self.value = value
        onValueChange?(value)
    }
}

private extension Slider {
    func _cursor() -> UIView {
        let v = HitOutsideView()
        v.extendInset = .init(inset: -6)
        v.frame = .init(x: 2, y: 2, width: 32, height: 32)
        v.backgroundColor = UIColor.white
        v.layer.addCorner(radius: v.frame.halfHeight)
        v.layer.addShadow(color: UIColor.black.withAlphaComponent(0.2), radius: 2)
        return v
    }
    
    func _cursorFill() -> CALayer {
        let l = CALayer()
        l.frame = cursor.bounds.insetBy(dx: 3, dy: 3)
        l.addCorner(radius: l.frame.halfHeight)
        l.addShadow(color: UIColor.black.withAlphaComponent(0.2), radius: 1.5)
        return l
    }
    
    func _corner(isLeft: Bool) -> CALayer {
        let l = CALayer()
        return l
    }
    
    func _gradient() -> CAGradientLayer {
        let l = CAGradientLayer()
        l.startPoint = .init(x: 0, y: 0.5)
        l.endPoint = .init(x: 1, y: 0.5)
        return l
    }
    
    func _backgroundImageView() -> UIImageView {
        let v = UIImageView()
        return v
    }
}

// MARK: - Preview View

private final class PreviewView: UIView {
    private lazy var left = _left()
    private lazy var right = _right()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        _layoutUI()
    }
}

extension PreviewView {
    func update(withColor color: Color) {
        left.backgroundColor = color.uiColor.withAlphaComponent(1)
        right.backgroundColor = color.uiColor
    }
}

private extension PreviewView {
    func _setupUI() {
        addSubview(left)
        addSubview(right)
    }
    
    func _layoutUI() {
        left.frame = .init(x: 0, y: 0, width: ceil(frame.halfWidth), height: frame.height)
        right.frame = .init(x: left.frame.maxX, y: 0, width: left.frame.width, height: frame.height)
    }
}

private extension PreviewView {
    func _left() -> UIView {
        let v = UIView()
        v.isUserInteractionEnabled = false
        v.layer.addCorner(radius: 4, mask: .left)
        return v
    }
    
    func _right() -> UIView {
        let v = UIView()
        v.isUserInteractionEnabled = false
        v.layer.addCorner(radius: 4, mask: .right)
        return v
    }
}

// MARK: - TextField

private final class TextField: TweakValidatedTextField {
    var prefix: String? {
        didSet { _setDecoration(prefix, viewPath: \.leftView, modePath: \.leftViewMode) }
    }
    var suffix: String? {
        didSet { _setDecoration(suffix, viewPath: \.rightView, modePath: \.rightViewMode) }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension TextField {
    func _setupUI() {
        textAlignment = .center
        returnKeyType = .done
        font = .systemFont(ofSize: 18)
        textColor = Constants.Color.labelPrimary
        backgroundColor = UIColor(light: .white, dark: .black)
        layer.addCorner(radius: 8, clipsContent: true)
    }
    
    func _setDecoration(_ decoration: String?, viewPath: ReferenceWritableKeyPath<UITextField, UIView?>, modePath: ReferenceWritableKeyPath<UITextField, ViewMode>) {
        self[keyPath: viewPath]?.subviews.forEach { $0.removeFromSuperview() }
        if let decoration = decoration {
            let label = _label(for: decoration)
            let view = UIView(frame: label.bounds)
            view.addSubview(label)
            self[keyPath: viewPath] = view
            self[keyPath: modePath] = .always
        } else {
            self[keyPath: viewPath] = nil
            self[keyPath: modePath] = .never
        }
    }
}

private extension TextField {
    func _label(for decoration: String) -> UILabel {
        let l = UILabel()
        l.textAlignment = .center
        l.font = .systemFont(ofSize: 18)
        l.text = decoration
        l.frame.size.width = l.sizeThatFits(.init(width: CGFloat.greatestFiniteMagnitude, height: .greatestFiniteMagnitude)).width + 16
        l.frame.size.height = frame.height
        l.backgroundColor = UIColor(light: UIColor(hexString: "F8F8FB")!, dark: UIColor(hexString: "111111")!)
        l.textColor = Constants.Color.labelSecondary
        return l
    }
}

// MARK: - Helpers

private typealias Color = (uiColor: UIColor, rgba: RGBA, hex: String)

private typealias RGBA = (r: Int, g: Int, b: Int, a: Int)
private extension UIColor.RGBA {
    var ui: RGBA {
        (
            Int(r.rounded(to: .integer)),
            Int(g.rounded(to: .integer)),
            Int(b.rounded(to: .integer)),
            Int((a * 100).rounded(to: .integer))
        )
    }
}

private enum ColorComponent: String, CaseIterable {
    case r = "R"
    case g = "G"
    case b = "B"
    case a
}

private enum ColorUpdate {
    case whole(String)
    case component(ColorComponent, Int)
}

private protocol ColorRenderer: AnyObject {
    func render(withColor color: Color)
}

private protocol ColorUpdater: AnyObject {
    func updateColor(with update: ColorUpdate)
}

private extension ClosedRange where Bound == Int {
    var distance: Int { upperBound - lowerBound }
}

private extension Constants.UI.SecondaryView {
    static let headerHeight: CGFloat = 124
    static let footerHeight: CGFloat = 34
    static let sectionHeaderHeight: CGFloat = 30
    static let sectionFooterHeight: CGFloat = 12
    static let rowHeight: CGFloat = 36
}
