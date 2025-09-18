import UIKit

// MARK: - 数据模型（外部可直接使用）
/// 分段项模型（默认以 title 做 id，可自定义）
public struct SegmentItem: Equatable, Hashable {
    public let title: String
    public let icon: String
    public let id: String

    public init(title: String, icon: String, id: String? = nil) {
        self.title = title
        self.icon = icon
        self.id = id ?? title
    }
}

// MARK: - 样式配置（对外暴露，便于主题化）
public struct SegmentStyle {
    public var backgroundColor: UIColor = UIColor.black.withAlphaComponent(0.8)
    public var indicatorColor: UIColor = UIColor.white.withAlphaComponent(0.15)
    public var normalForegroundColor: UIColor = .white
    public var selectedForegroundColor: UIColor = .systemBlue
    public var font: UIFont = .systemFont(ofSize: 12, weight: .medium)
    public var iconSize: CGSize = CGSize(width: 20, height: 20)
    public var contentSpacing: CGFloat = 4

    public init() { }
}

// MARK: - 自定义分段控制器（对外主控件）
public final class CustomSegmentView: UIControl {
    
    // MARK: - 公开属性
    /// 当前选中索引（设置后自动触发动画与回调）
    public var selectedIndex: Int = 0 {
        didSet {
            updateSelection(animated: true)
        }
    }
    /// 选择变化回调（可选），同时会发送 UIControl.Event.valueChanged
    public var onSelectionChanged: ((Int, SegmentItem) -> Void)?
    
    // MARK: - 私有属性
    private(set) var items: [SegmentItem] = []
    private let containerView = UIView()
    private let selectionIndicator = UIView()
    private var segmentButtons: [UIButton] = []            // 正常色按钮
    private var segmentStackView: UIStackView!             // 正常色容器
    // 选中色覆盖层（使用 mask 实现“框内为选中色，框外为默认色”）
    private let selectedOverlayView = UIView()
    private var selectedStackView: UIStackView!            // 选中色容器（不接收事件）
    private let maskLayer = CAShapeLayer()
    private var displayLink: CADisplayLink?
    
    // 手势识别
    private var panGesture: UIPanGestureRecognizer!
    private var initialIndicatorCenter: CGPoint = .zero
    private var initialPanLocation: CGPoint = .zero
    
    // 动画相关
    private var indicatorWidthConstraint: NSLayoutConstraint!
    private var indicatorCenterXConstraint: NSLayoutConstraint!
    private var indicatorHeightConstraint: NSLayoutConstraint!
    private var containerHeightConstraint: NSLayoutConstraint!
    
    // 设计参数（对外可自定义）
    public var containerHeight: CGFloat = 60 { didSet { containerHeightConstraint?.constant = containerHeight; setNeedsLayout() } }
    public var indicatorInset: CGFloat = 4 { didSet { indicatorHeightConstraint?.constant = containerHeight - indicatorInset * 2; setNeedsLayout() } }
    public var cornerRadius: CGFloat = 30 { didSet { containerView.layer.cornerRadius = cornerRadius } }
    public var segmentSpacing: CGFloat = 0 { didSet { segmentStackView?.spacing = segmentSpacing; selectedStackView?.spacing = segmentSpacing; setNeedsLayout() } }
    // 弹性动画（系统 spring 动画参数，越接近 1.0 弹性越小）
    public var springDamping: CGFloat = 0.72
    public var springInitialVelocity: CGFloat = 0.4

    /// 主题样式（外部可整体替换）
    public var style: SegmentStyle = .init() { didSet { applyStyle() } }
    
    // MARK: - 初始化
    public init(items: [SegmentItem]) {
        super.init(frame: .zero)
        self.items = items
        setupUI()
        setupGestures()
        setupInitialSelection()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - UI设置
    private func setupUI() {
        backgroundColor = .clear
        
        // 容器视图
        containerView.backgroundColor = style.backgroundColor
        containerView.layer.cornerRadius = cornerRadius
        containerView.clipsToBounds = true
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)
        
        // 选中指示器
        selectionIndicator.backgroundColor = style.indicatorColor
        selectionIndicator.layer.cornerRadius = (containerHeight - indicatorInset * 2) / 2
        selectionIndicator.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(selectionIndicator)
        
        // 创建分段按钮
        createSegmentButtons()
        
        // 创建堆栈视图（正常色）
        segmentStackView = UIStackView(arrangedSubviews: segmentButtons)
        segmentStackView.axis = .horizontal
        segmentStackView.distribution = .fillEqually
        segmentStackView.alignment = .center
        segmentStackView.spacing = segmentSpacing
        segmentStackView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(segmentStackView)
        
        // 创建选中色覆盖层及其堆栈：与正常层同结构，但图标/文字使用选中色；通过 mask 显示“指示框内”的部分
        selectedOverlayView.translatesAutoresizingMaskIntoConstraints = false
        selectedOverlayView.isUserInteractionEnabled = false
        containerView.addSubview(selectedOverlayView)
        selectedStackView = UIStackView(arrangedSubviews: createSelectedOverlayItems())
        selectedStackView.axis = .horizontal
        selectedStackView.distribution = .fillEqually
        selectedStackView.alignment = .center
        selectedStackView.spacing = segmentSpacing
        selectedStackView.translatesAutoresizingMaskIntoConstraints = false
        selectedStackView.isUserInteractionEnabled = false
        selectedOverlayView.addSubview(selectedStackView)
        selectedOverlayView.layer.mask = maskLayer
        
        setupConstraints()
    }

    // 当前选中 id（若有）
    private func onSafeCurrentId() -> String? {
        guard items.indices.contains(selectedIndex) else { return nil }
        return items[selectedIndex].id
    }

    // 应用样式到现有子视图
    private func applyStyle() {
        containerView.backgroundColor = style.backgroundColor
        selectionIndicator.backgroundColor = style.indicatorColor
        // 正常层颜色/字体
        segmentButtons.forEach { btn in
            if let stack = btn.subviews.first as? UIStackView,
               let icon = stack.arrangedSubviews.first as? UIImageView,
               let lab = stack.arrangedSubviews.last as? UILabel {
                icon.tintColor = style.normalForegroundColor
                lab.textColor = style.normalForegroundColor
                lab.font = style.font
            }
        }
        // 选中色层
        selectedStackView?.arrangedSubviews.forEach { v in
            if let stack = v.subviews.first as? UIStackView,
               let icon = stack.arrangedSubviews.first as? UIImageView,
               let lab = stack.arrangedSubviews.last as? UILabel {
                icon.tintColor = style.selectedForegroundColor
                lab.textColor = style.selectedForegroundColor
                lab.font = style.font
            }
        }
        setNeedsLayout()
    }
    
    private func createSegmentButtons() {
        segmentButtons = items.enumerated().map { index, item in
            let button = createSegmentButton(for: item, at: index)
            return button
        }
    }
    
    private func createSegmentButton(for item: SegmentItem, at index: Int) -> UIButton {
        let button = UIButton(type: .custom)
        button.tag = index
        
        // 创建图标和文字的垂直布局
        let iconImageView = UIImageView()
        iconImageView.image = UIImage(systemName: item.icon)
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = style.normalForegroundColor
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = item.title
        titleLabel.font = style.font
        titleLabel.textColor = style.normalForegroundColor
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 创建垂直堆栈视图
        let stackView = UIStackView(arrangedSubviews: [iconImageView, titleLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = style.contentSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isUserInteractionEnabled = false
        
        button.addSubview(stackView)
        button.addTarget(self, action: #selector(segmentTapped(_:)), for: .touchUpInside)
        
        // 约束设置
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            
            iconImageView.widthAnchor.constraint(equalToConstant: style.iconSize.width),
            iconImageView.heightAnchor.constraint(equalToConstant: style.iconSize.height)
        ])
        
        return button
    }
    
    private func setupConstraints() {
        // 计算指示器宽度（考虑分段间距，左右各预留 inset）
        let totalSpacing = segmentSpacing * CGFloat(max(0, items.count - 1))
        let baseSegmentWidth = bounds.width > 0 ? (bounds.width - totalSpacing) / CGFloat(items.count) : 0
        let indicatorWidth = bounds.width > 0 ? max(0, baseSegmentWidth - indicatorInset * 2) : 100
        
        indicatorWidthConstraint = selectionIndicator.widthAnchor.constraint(equalToConstant: indicatorWidth)
        indicatorCenterXConstraint = selectionIndicator.centerXAnchor.constraint(equalTo: containerView.leadingAnchor, constant: indicatorWidth / 2 + indicatorInset)
        containerHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: containerHeight)
        indicatorHeightConstraint = selectionIndicator.heightAnchor.constraint(equalToConstant: containerHeight - indicatorInset * 2)

        NSLayoutConstraint.activate([
            // 容器约束
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerHeightConstraint,
            
            // 指示器约束
            selectionIndicator.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            indicatorHeightConstraint,
            indicatorWidthConstraint,
            indicatorCenterXConstraint,
            
            // 堆栈视图约束
            segmentStackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            segmentStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            segmentStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            segmentStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        // 选中色覆盖层与容器填充
        NSLayoutConstraint.activate([
            selectedOverlayView.topAnchor.constraint(equalTo: containerView.topAnchor),
            selectedOverlayView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            selectedOverlayView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            selectedOverlayView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            selectedStackView.topAnchor.constraint(equalTo: selectedOverlayView.topAnchor),
            selectedStackView.leadingAnchor.constraint(equalTo: selectedOverlayView.leadingAnchor),
            selectedStackView.trailingAnchor.constraint(equalTo: selectedOverlayView.trailingAnchor),
            selectedStackView.bottomAnchor.constraint(equalTo: selectedOverlayView.bottomAnchor)
        ])
    }
    
    // MARK: - 手势设置
    private func setupGestures() {
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panGesture.delegate = self
        addGestureRecognizer(panGesture)
    }
    
    // MARK: - 布局
    public override func layoutSubviews() {
        super.layoutSubviews()
        updateIndicatorConstraints()
        // 动态同步圆角
        selectionIndicator.layer.cornerRadius = selectionIndicator.bounds.height / 2
        updateMaskPathToIndicator()
    }
    
    private func updateIndicatorConstraints() {
        guard bounds.width > 0, !items.isEmpty else { return }

        let totalSpacing = segmentSpacing * CGFloat(max(0, items.count - 1))
        let segmentWidth = (bounds.width - totalSpacing) / CGFloat(items.count)
        let unit = segmentWidth + segmentSpacing
        let newWidth = max(0, segmentWidth - indicatorInset * 2)
        let newCenterX = unit * CGFloat(selectedIndex) + segmentWidth / 2

        indicatorWidthConstraint.constant = newWidth
        indicatorCenterXConstraint.constant = newCenterX
    }
    
    // MARK: - 手势处理
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            handlePanBegan(gesture)
        case .changed:
            handlePanChanged(gesture)
        case .ended, .cancelled:
            handlePanEnded(gesture)
        default:
            break
        }
    }
    
    private func handlePanBegan(_ gesture: UIPanGestureRecognizer) {
        initialIndicatorCenter = selectionIndicator.center
        initialPanLocation = gesture.location(in: self)
        
        // 提供触觉反馈
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        // 仅系统回弹：拖动开始不做额外缩放
    }
    
    private func handlePanChanged(_ gesture: UIPanGestureRecognizer) {
        let currentLocation = gesture.location(in: self)
        let deltaX = currentLocation.x - initialPanLocation.x
        
        // 计算新的指示器位置（考虑 segmentSpacing）
        var newCenterX = initialIndicatorCenter.x + deltaX
        let totalSpacing = segmentSpacing * CGFloat(max(0, items.count - 1))
        let segmentWidth = (bounds.width - totalSpacing) / CGFloat(items.count)
        let unit = segmentWidth + segmentSpacing
        
        // 限制指示器在有效范围内
        let minX = segmentWidth / 2
        let maxX = unit * CGFloat(items.count - 1) + segmentWidth / 2
        newCenterX = max(minX, min(maxX, newCenterX))
        
        // 更新指示器位置
        indicatorCenterXConstraint.constant = newCenterX
        layoutIfNeeded()
        updateMaskPathToIndicator()
    }
    
    private func handlePanEnded(_ gesture: UIPanGestureRecognizer) {
        let velocity = gesture.velocity(in: self)
        let currentLocation = gesture.location(in: self)
        
        // 计算应该选中的索引（考虑 segmentSpacing）
        let totalSpacing = segmentSpacing * CGFloat(max(0, items.count - 1))
        let segmentWidth = (bounds.width - totalSpacing) / CGFloat(items.count)
        let unit = segmentWidth + segmentSpacing
        var targetIndex = Int(currentLocation.x / unit)
        
        // 考虑滑动速度
        if abs(velocity.x) > 500 {
            if velocity.x > 0 && targetIndex < items.count - 1 {
                targetIndex += 1
            } else if velocity.x < 0 && targetIndex > 0 {
                targetIndex -= 1
            }
        }
        
        // 确保索引在有效范围内
        targetIndex = max(0, min(items.count - 1, targetIndex))
        
        // 如果索引发生变化，更新选中状态
        if targetIndex != selectedIndex {
            selectedIndex = targetIndex
            onSelectionChanged?(selectedIndex, items[selectedIndex])
            
            // 提供选择反馈
            let selectionFeedback = UISelectionFeedbackGenerator()
            selectionFeedback.selectionChanged()
            sendActions(for: .valueChanged)
        } else {
            // 如果没有变化，动画回到原位置
            updateSelection(animated: true)
        }

        }
    
    // MARK: - 点击处理
    @objc private func segmentTapped(_ sender: UIButton) {
        let newIndex = sender.tag
        guard newIndex != selectedIndex else { return }
        
        selectedIndex = newIndex
        onSelectionChanged?(selectedIndex, items[selectedIndex])
        sendActions(for: .valueChanged)
        
        // 提供触觉反馈
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        // 仅系统回弹：轻点不做额外缩放
    }
    
    // MARK: - 选择更新
    private func setupInitialSelection() {
        updateSelection(animated: false)
    }
    
    private func updateSelection(animated: Bool) {
        guard !items.isEmpty, selectedIndex >= 0, selectedIndex < items.count else { return }

        // 计算目标位置（考虑分段间距与 inset），用于动态设置动画时长和初速度
        let totalSpacing = segmentSpacing * CGFloat(max(0, items.count - 1))
        let segmentWidth = (bounds.width - totalSpacing) / CGFloat(items.count)
        let unit = segmentWidth + segmentSpacing
        let targetCenterX = unit * CGFloat(selectedIndex) + segmentWidth / 2
        let targetWidth = max(0, segmentWidth - indicatorInset * 2)
        let currentCenterX = indicatorCenterXConstraint.constant
        let delta = abs(targetCenterX - currentCenterX)
        let distanceNorm = segmentWidth > 0 ? min(1.0, delta / (segmentWidth * 1.5)) : 0

        // 动态时长与初速度：距离越大，越明显；保证从 A→B、B→A 都有可见 spring
        let baseDuration: TimeInterval = 0.32
        let duration = animated ? baseDuration + 0.18 * TimeInterval(distanceNorm) : 0
        let iv = animated ? max(0.0, min(1.6, springInitialVelocity + 0.6 * distanceNorm)) : 0

        if animated { startMaskTrackingDisplayLink() }
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: springDamping, initialSpringVelocity: iv, options: [.curveEaseInOut, .allowUserInteraction, .beginFromCurrentState]) {
            self.indicatorWidthConstraint.constant = targetWidth
            self.indicatorCenterXConstraint.constant = targetCenterX
            self.updateSegmentColors()
            self.layoutIfNeeded()
        } completion: { _ in
            self.stopMaskTrackingDisplayLink()
            self.updateMaskPathToIndicator()
        }
    }

    // MARK: - 弹性动画
    // 使用系统 spring（由 updateSelection 驱动），不做额外缩放/关键帧，避免抖动
    
    private func updateSegmentColors() {
        // 正常层始终保持默认色（白色），选中色由覆盖层 + mask 决定。
        // 仅维护可访问性 selected trait
        for (index, button) in segmentButtons.enumerated() {
            let isSelected = index == selectedIndex
            if let stackView = button.subviews.first as? UIStackView,
               let iconImageView = stackView.arrangedSubviews.first as? UIImageView,
               let titleLabel = stackView.arrangedSubviews.last as? UILabel {
                iconImageView.tintColor = style.normalForegroundColor
                titleLabel.textColor = style.normalForegroundColor
            }
            if isSelected {
                button.accessibilityTraits.insert(.selected)
            } else {
                button.accessibilityTraits.remove(.selected)
            }
        }
    }
    
    // MARK: - 公开方法
    public func setSelectedIndex(_ index: Int, animated: Bool = true) {
        guard index >= 0, index < items.count, index != selectedIndex else { return }
        selectedIndex = index
        if animated {
            updateSelection(animated: true)
        }
    }
    
    /// 更新 items，尽量保持原选中（按 id 匹配），否则退回 0
    public func updateItems(_ newItems: [SegmentItem]) {
        // 记录旧选中 id
        let oldSelectedId = items.indices.contains(selectedIndex) ? items[selectedIndex].id : nil
        items = newItems
        
        // 清除旧的按钮
        segmentButtons.forEach { $0.removeFromSuperview() }
        segmentStackView.removeFromSuperview()
        // 清除旧的覆盖层
        selectedStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        selectedStackView.removeFromSuperview()
        selectedOverlayView.removeFromSuperview()
        
        // 创建新的按钮和布局
        createSegmentButtons()
        segmentStackView = UIStackView(arrangedSubviews: segmentButtons)
        segmentStackView.axis = .horizontal
        segmentStackView.distribution = .fillEqually
        segmentStackView.alignment = .center
        segmentStackView.spacing = segmentSpacing
        segmentStackView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(segmentStackView)
        
        // 重建选中色覆盖层
        containerView.addSubview(selectedOverlayView)
        selectedStackView = UIStackView(arrangedSubviews: createSelectedOverlayItems())
        selectedStackView.axis = .horizontal
        selectedStackView.distribution = .fillEqually
        selectedStackView.alignment = .center
        selectedStackView.spacing = segmentSpacing
        selectedStackView.translatesAutoresizingMaskIntoConstraints = false
        selectedStackView.isUserInteractionEnabled = false
        selectedOverlayView.addSubview(selectedStackView)
        selectedOverlayView.layer.mask = maskLayer
        
        // 重新设置约束
        NSLayoutConstraint.activate([
            segmentStackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            segmentStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            segmentStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            segmentStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        NSLayoutConstraint.activate([
            selectedOverlayView.topAnchor.constraint(equalTo: containerView.topAnchor),
            selectedOverlayView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            selectedOverlayView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            selectedOverlayView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            selectedStackView.topAnchor.constraint(equalTo: selectedOverlayView.topAnchor),
            selectedStackView.leadingAnchor.constraint(equalTo: selectedOverlayView.leadingAnchor),
            selectedStackView.trailingAnchor.constraint(equalTo: selectedOverlayView.trailingAnchor),
            selectedStackView.bottomAnchor.constraint(equalTo: selectedOverlayView.bottomAnchor)
        ])
        
        // 恢复选中（优先 id 匹配）
        if let currentId = oldSelectedId, let idx = newItems.firstIndex(where: { $0.id == currentId }) {
            selectedIndex = idx
        } else {
            selectedIndex = 0
        }
        updateSelection(animated: false)
        applyStyle()
    }

    // MARK: - 选中色覆盖层生成
    private func createSelectedOverlayItems() -> [UIView] {
        // 与 createSegmentButton 的内部布局一致，但不使用 UIButton，不接收事件
        return items.map { item in
            let container = UIView()
            container.isUserInteractionEnabled = false
            let iconImageView = UIImageView()
            iconImageView.image = UIImage(systemName: item.icon)
            iconImageView.contentMode = .scaleAspectFit
            iconImageView.tintColor = style.selectedForegroundColor
            iconImageView.translatesAutoresizingMaskIntoConstraints = false
            
            let titleLabel = UILabel()
            titleLabel.text = item.title
            titleLabel.font = style.font
            titleLabel.textColor = style.selectedForegroundColor
            titleLabel.textAlignment = .center
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            
            let stackView = UIStackView(arrangedSubviews: [iconImageView, titleLabel])
            stackView.axis = .vertical
            stackView.alignment = .center
            stackView.spacing = style.contentSpacing
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.isUserInteractionEnabled = false
            
            container.addSubview(stackView)
            NSLayoutConstraint.activate([
                stackView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                stackView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
                iconImageView.widthAnchor.constraint(equalToConstant: style.iconSize.width),
                iconImageView.heightAnchor.constraint(equalToConstant: style.iconSize.height)
            ])
            return container
        }
    }

    // 更新 mask 路径为当前指示器的圆角矩形（在 overlay 坐标系）
    private func updateMaskPathToIndicator() {
        let rect = selectionIndicator.convert(selectionIndicator.bounds, to: selectedOverlayView)
        let path = UIBezierPath(roundedRect: rect, cornerRadius: rect.height / 2)
        maskLayer.frame = selectedOverlayView.bounds
        maskLayer.path = path.cgPath
    }

    private func startMaskTrackingDisplayLink() {
        stopMaskTrackingDisplayLink()
        displayLink = CADisplayLink(target: self, selector: #selector(maskAnimationTick))
        displayLink?.add(to: .main, forMode: .common)
    }
    private func stopMaskTrackingDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }
    @objc private func maskAnimationTick() {
        // 使用 presentation layer 的 frame 来平滑跟随动画中的指示器
        if let pres = selectionIndicator.layer.presentation() {
            let frameInOverlay = containerView.convert(pres.frame, to: selectedOverlayView)
            let path = UIBezierPath(roundedRect: frameInOverlay, cornerRadius: frameInOverlay.height / 2)
            maskLayer.frame = selectedOverlayView.bounds
            maskLayer.path = path.cgPath
        } else {
            updateMaskPathToIndicator()
        }
    }
}

// MARK: - UIGestureRecognizerDelegate
extension CustomSegmentView: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}
