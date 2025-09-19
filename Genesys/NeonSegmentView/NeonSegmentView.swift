import UIKit
import SnapKit

public final class NeonSegmentView: UIControl {
    
    // MARK: - 公开属性
    public var selectedIndex: Int = 0 {
        didSet {
            updateSelection(animated: true)
        }
    }
    
    public var onSelectionChanged: ((Int, NeonSegmentItem) -> Void)?
    
    // MARK: - 配置属性
    public var containerHeight: CGFloat = 60 {
        didSet {
            updateContainerHeight()
        }
    }
    
    public var indicatorInset: CGFloat = 4 {
        didSet {
            indicator.updateContainerHeight(containerHeight, indicatorInset: indicatorInset)
            setNeedsLayout()
        }
    }
    
    public var cornerRadius: CGFloat = 30 {
        didSet {
            containerView.layer.cornerRadius = cornerRadius
        }
    }
    
    public var segmentSpacing: CGFloat = 0 {
        didSet {
            segmentStackView.spacing = segmentSpacing
            selectedStackView.spacing = segmentSpacing
            setNeedsLayout()
        }
    }
    
    public var springDamping: CGFloat = 0.72
    public var springInitialVelocity: CGFloat = 0.4
    
    public var style: NeonSegmentStyle = .init() {
        didSet {
            applyStyle()
        }
    }
    
    // MARK: - 私有属性
    private(set) var items: [NeonSegmentItem] = []
    private let containerView = UIView()
    internal let indicator = NeonSegmentIndicator(
        style: NeonSegmentStyle(),
        containerHeight: 60,
        indicatorInset: 4
    )
    
    // 分段按钮相关
    private var segmentButtons: [UIButton] = []
    private let segmentStackView = UIStackView()
    
    // 选中色覆盖层
    private let selectedOverlayView = UIView()
    private let selectedStackView = UIStackView()
    private let maskLayer = CAShapeLayer()
    private var selectedItemViews: [NeonSegmentItemView] = []
    private var displayLink: CADisplayLink?
    
    // 手势识别
    private var panGesture: UIPanGestureRecognizer!
    private var initialIndicatorCenter: CGPoint = .zero
    private var initialPanLocation: CGPoint = .zero
    
    // MARK: - 初始化
    public init(items: [NeonSegmentItem]) {
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
        
        setupContainerView()
        setupIndicator()
        setupSegmentButtons()
        setupSegmentStackView()
        setupSelectedOverlay()
        setupConstraints()
        applyStyle()
    }
    
    private func setupContainerView() {
        containerView.backgroundColor = style.backgroundColor
        containerView.layer.cornerRadius = cornerRadius
        containerView.clipsToBounds = true
        addSubview(containerView)
    }
    
    private func setupIndicator() {
        indicator.setupConstraints(in: containerView)
    }
    
    private func setupSegmentButtons() {
        segmentButtons = items.enumerated().map { index, item in
            createSegmentButton(for: item, at: index)
        }
    }
    
    private func createSegmentButton(for item: NeonSegmentItem, at index: Int) -> UIButton {
        let button = UIButton(type: .custom)
        button.tag = index
        button.addTarget(self, action: #selector(segmentTapped(_:)), for: .touchUpInside)
        
        let itemView = NeonSegmentItemView(item: item, style: style)
        button.addSubview(itemView)
        
        itemView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        return button
    }
    
    private func setupSegmentStackView() {
        segmentStackView.axis = .horizontal
        segmentStackView.distribution = .fillEqually
        segmentStackView.alignment = .center
        segmentStackView.spacing = segmentSpacing
        
        segmentButtons.forEach { segmentStackView.addArrangedSubview($0) }
        containerView.addSubview(segmentStackView)
    }
    
    private func setupSelectedOverlay() {
        selectedOverlayView.isUserInteractionEnabled = false
        containerView.addSubview(selectedOverlayView)
        
        // 创建选中色的 ItemView
        selectedItemViews = items.map { item in
            let itemView = NeonSegmentItemView(item: item, style: style)
            itemView.updateColors(foregroundColor: style.selectedForegroundColor)
            return itemView
        }
        
        selectedStackView.axis = .horizontal
        selectedStackView.distribution = .fillEqually
        selectedStackView.alignment = .center
        selectedStackView.spacing = segmentSpacing
        selectedStackView.isUserInteractionEnabled = false
        
        selectedItemViews.forEach { selectedStackView.addArrangedSubview($0) }
        selectedOverlayView.addSubview(selectedStackView)
        selectedOverlayView.layer.mask = maskLayer
    }
    
    private func setupConstraints() {
        // 容器约束
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(containerHeight)
        }
        
        // 分段堆栈约束
        segmentStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 选中覆盖层约束
        selectedOverlayView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        selectedStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
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
        // 先根据当前实际宽度计算并应用指示器的位置与宽度
        // 注意：这里需要在同一轮布局内让约束生效后再取 frame 来绘制 mask，
        // 否则初次显示时可能用到旧 frame，导致首个 item 看起来未选中。
        updateIndicatorConstraints()
        // 让子视图按最新约束完成布局，再读取 indicator 的实际几何信息
        containerView.layoutIfNeeded()
        // 动态同步圆角
        indicator.layer.cornerRadius = indicator.bounds.height / 2
        // 使用最新的 indicator frame 更新遮罩路径
        updateMaskPathToIndicator()
    }
    
    private func updateIndicatorConstraints() {
        guard bounds.width > 0, !items.isEmpty else { return }
        
        let totalSpacing = segmentSpacing * CGFloat(max(0, items.count - 1))
        let segmentWidth = (bounds.width - totalSpacing) / CGFloat(items.count)
        let unit = segmentWidth + segmentSpacing
        let newWidth = max(0, segmentWidth - indicatorInset * 2)
        let newCenterX = unit * CGFloat(selectedIndex) + segmentWidth / 2
        
        // 用 SnapKit 的 update 方法使约束立即生效（非动画），
        // 避免在初次布局时直接改 layoutConstraints 常量导致的时序问题。
        indicator.updatePosition(centerX: newCenterX, width: newWidth, animated: false)
    }
    
    // MARK: - 样式应用
    private func applyStyle() {
        containerView.backgroundColor = style.backgroundColor
        indicator.updateStyle(style)
        
        // 更新所有 ItemView 的样式但不改变颜色
        for button in segmentButtons {
            if let itemView = button.subviews.first as? NeonSegmentItemView {
                itemView.updateStyle(style)
            }
        }
        
        // 更新选中状态的 ItemView 样式
        for itemView in selectedItemViews {
            itemView.updateStyle(style)
            itemView.updateColors(foregroundColor: style.selectedForegroundColor)
        }
        
        setNeedsLayout()
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
        let currentCenterX = indicator.centerXOffset
        let delta = abs(targetCenterX - currentCenterX)
        let distanceNorm = segmentWidth > 0 ? min(1.0, delta / (segmentWidth * 1.5)) : 0

        // 动态时长与初速度：距离越大，越明显；保证从 A→B、B→A 都有可见 spring
        let baseDuration: TimeInterval = 0.32
        let duration = animated ? baseDuration + 0.18 * TimeInterval(distanceNorm) : 0
        let iv = animated ? max(0.0, min(1.6, springInitialVelocity + 0.6 * distanceNorm)) : 0

        if animated { 
            startMaskTrackingDisplayLink() 
            UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: springDamping, initialSpringVelocity: iv, options: [.curveEaseInOut, .allowUserInteraction, .beginFromCurrentState]) {
                self.indicator.setConstraintConstants(centerX: targetCenterX, width: targetWidth)
                self.updateSegmentColors()
                self.layoutIfNeeded()
            } completion: { _ in
                self.stopMaskTrackingDisplayLink()
                self.updateMaskPathToIndicator()
            }
        } else {
            // 非动画模式：直接设置约束，即使bounds.width=0也要设置（与原代码一致）
            indicator.setConstraintConstants(centerX: targetCenterX, width: targetWidth)
            updateSegmentColors()
            layoutIfNeeded()
            updateMaskPathToIndicator()
        }
    }
    
    private func updateSegmentColors() {
        // 正常层始终保持默认色（白色），选中色由覆盖层 + mask 决定。
        // 仅维护可访问性 selected trait
        for (index, button) in segmentButtons.enumerated() {
            let isSelected = index == selectedIndex
            if let itemView = button.subviews.first as? NeonSegmentItemView {
                itemView.updateColors(foregroundColor: style.normalForegroundColor)
            }
            if isSelected {
                button.accessibilityTraits.insert(.selected)
            } else {
                button.accessibilityTraits.remove(.selected)
            }
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
    }
    
    // MARK: - 遮罩处理
    private func updateMaskPathToIndicator() {
        // 使用与原代码完全一致的坐标转换方式
        let rect = indicator.convert(indicator.bounds, to: selectedOverlayView)
        let path = UIBezierPath(roundedRect: rect, cornerRadius: rect.height / 2)
        maskLayer.frame = selectedOverlayView.bounds
        maskLayer.path = path.cgPath
    }
    
    // MARK: - DisplayLink 动画跟踪
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
        if let pres = indicator.layer.presentation() {
            let frameInOverlay = containerView.convert(pres.frame, to: selectedOverlayView)
            let path = UIBezierPath(roundedRect: frameInOverlay, cornerRadius: frameInOverlay.height / 2)
            maskLayer.frame = selectedOverlayView.bounds
            maskLayer.path = path.cgPath
        } else {
            updateMaskPathToIndicator()
        }
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
        initialIndicatorCenter = indicator.center
        initialPanLocation = gesture.location(in: self)
        
        // 提供触觉反馈
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
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
        indicator.setConstraintConstants(centerX: newCenterX, width: indicator.widthValue)
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
    
    // MARK: - 配置更新
    private func updateContainerHeight() {
        containerView.snp.updateConstraints { make in
            make.height.equalTo(containerHeight)
        }
        indicator.updateContainerHeight(containerHeight, indicatorInset: indicatorInset)
        setNeedsLayout()
    }
    
    // MARK: - 公开方法
    public func setSelectedIndex(_ index: Int, animated: Bool = true) {
        guard index >= 0, index < items.count, index != selectedIndex else { return }
        selectedIndex = index
        // selectedIndex 的 didSet 会自动调用 updateSelection(animated: true)
        // 但如果不需要动画，需要重新调用 updateSelection(animated: false)
        if !animated {
            updateSelection(animated: false)
        }
    }
    
    public func updateItems(_ newItems: [NeonSegmentItem]) {
        let oldSelectedId = items.indices.contains(selectedIndex) ? items[selectedIndex].id : nil
        items = newItems
        
        // 清除旧的视图
        segmentButtons.forEach { $0.removeFromSuperview() }
        selectedItemViews.forEach { $0.removeFromSuperview() }
        segmentStackView.arrangedSubviews.forEach { segmentStackView.removeArrangedSubview($0) }
        selectedStackView.arrangedSubviews.forEach { selectedStackView.removeArrangedSubview($0) }
        
        // 创建新的视图
        setupSegmentButtons()
        segmentButtons.forEach { segmentStackView.addArrangedSubview($0) }
        
        selectedItemViews = items.map { item in
            let itemView = NeonSegmentItemView(item: item, style: style)
            itemView.updateColors(foregroundColor: style.selectedForegroundColor)
            return itemView
        }
        selectedItemViews.forEach { selectedStackView.addArrangedSubview($0) }
        
        // 恢复选中状态
        if let currentId = oldSelectedId, let idx = newItems.firstIndex(where: { $0.id == currentId }) {
            selectedIndex = idx
        } else {
            selectedIndex = 0
        }
        
        updateSelection(animated: false)
        applyStyle()
    }
}


// MARK: - UIGestureRecognizerDelegate
extension NeonSegmentView: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}
