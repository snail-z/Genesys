import UIKit

// MARK: - 数据模型
struct SegmentItem {
    let title: String
    let icon: String
    let id: String
    
    init(title: String, icon: String, id: String? = nil) {
        self.title = title
        self.icon = icon
        self.id = id ?? title
    }
}

// MARK: - 自定义分段控制器
class CustomSegmentView: UIView {
    
    // MARK: - 公开属性
    var selectedIndex: Int = 0 {
        didSet {
            updateSelection(animated: true)
        }
    }
    
    var onSelectionChanged: ((Int, SegmentItem) -> Void)?
    
    // MARK: - 私有属性
    private var items: [SegmentItem] = []
    private let containerView = UIView()
    private let selectionIndicator = UIView()
    private var segmentButtons: [UIButton] = []
    private var segmentStackView: UIStackView!
    
    // 手势识别
    private var panGesture: UIPanGestureRecognizer!
    private var initialIndicatorCenter: CGPoint = .zero
    private var initialPanLocation: CGPoint = .zero
    
    // 动画相关
    private var indicatorWidthConstraint: NSLayoutConstraint!
    private var indicatorCenterXConstraint: NSLayoutConstraint!
    
    // 设计参数
    private let containerHeight: CGFloat = 60
    private let indicatorInset: CGFloat = 4
    private let cornerRadius: CGFloat = 30
    
    // MARK: - 初始化
    init(items: [SegmentItem]) {
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
        containerView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        containerView.layer.cornerRadius = cornerRadius
        containerView.clipsToBounds = true
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)
        
        // 选中指示器
        selectionIndicator.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        selectionIndicator.layer.cornerRadius = (containerHeight - indicatorInset * 2) / 2
        selectionIndicator.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(selectionIndicator)
        
        // 创建分段按钮
        createSegmentButtons()
        
        // 创建堆栈视图
        segmentStackView = UIStackView(arrangedSubviews: segmentButtons)
        segmentStackView.axis = .horizontal
        segmentStackView.distribution = .fillEqually
        segmentStackView.alignment = .center
        segmentStackView.spacing = 0
        segmentStackView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(segmentStackView)
        
        setupConstraints()
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
        iconImageView.tintColor = .white
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = item.title
        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 创建垂直堆栈视图
        let stackView = UIStackView(arrangedSubviews: [iconImageView, titleLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isUserInteractionEnabled = false
        
        button.addSubview(stackView)
        button.addTarget(self, action: #selector(segmentTapped(_:)), for: .touchUpInside)
        
        // 约束设置
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            
            iconImageView.widthAnchor.constraint(equalToConstant: 20),
            iconImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        return button
    }
    
    private func setupConstraints() {
        // 计算指示器宽度
        let indicatorWidth = bounds.width > 0 ? bounds.width / CGFloat(items.count) - indicatorInset : 100
        
        indicatorWidthConstraint = selectionIndicator.widthAnchor.constraint(equalToConstant: indicatorWidth)
        indicatorCenterXConstraint = selectionIndicator.centerXAnchor.constraint(equalTo: containerView.leadingAnchor, constant: indicatorWidth / 2 + indicatorInset)
        
        NSLayoutConstraint.activate([
            // 容器约束
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: containerHeight),
            
            // 指示器约束
            selectionIndicator.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            selectionIndicator.heightAnchor.constraint(equalToConstant: containerHeight - indicatorInset * 2),
            indicatorWidthConstraint,
            indicatorCenterXConstraint,
            
            // 堆栈视图约束
            segmentStackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            segmentStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            segmentStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            segmentStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
    
    // MARK: - 手势设置
    private func setupGestures() {
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panGesture.delegate = self
        addGestureRecognizer(panGesture)
    }
    
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        updateIndicatorConstraints()
    }
    
    private func updateIndicatorConstraints() {
        guard bounds.width > 0, !items.isEmpty else { return }
        
        let segmentWidth = bounds.width / CGFloat(items.count)
        let newWidth = segmentWidth - indicatorInset
        let newCenterX = segmentWidth * CGFloat(selectedIndex) + segmentWidth / 2
        
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
    }
    
    private func handlePanChanged(_ gesture: UIPanGestureRecognizer) {
        let currentLocation = gesture.location(in: self)
        let deltaX = currentLocation.x - initialPanLocation.x
        
        // 计算新的指示器位置
        var newCenterX = initialIndicatorCenter.x + deltaX
        let segmentWidth = bounds.width / CGFloat(items.count)
        
        // 限制指示器在有效范围内
        let minX = segmentWidth / 2
        let maxX = bounds.width - segmentWidth / 2
        newCenterX = max(minX, min(maxX, newCenterX))
        
        // 更新指示器位置
        indicatorCenterXConstraint.constant = newCenterX
        layoutIfNeeded()
    }
    
    private func handlePanEnded(_ gesture: UIPanGestureRecognizer) {
        let velocity = gesture.velocity(in: self)
        let currentLocation = gesture.location(in: self)
        
        // 计算应该选中的索引
        let segmentWidth = bounds.width / CGFloat(items.count)
        var targetIndex = Int(currentLocation.x / segmentWidth)
        
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
        
        // 提供触觉反馈
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    // MARK: - 选择更新
    private func setupInitialSelection() {
        updateSelection(animated: false)
    }
    
    private func updateSelection(animated: Bool) {
        guard !items.isEmpty, selectedIndex >= 0, selectedIndex < items.count else { return }
        
        let duration: TimeInterval = animated ? 0.3 : 0
        
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [.curveEaseInOut]) {
            self.updateIndicatorConstraints()
            self.updateSegmentColors()
            self.layoutIfNeeded()
        }
    }
    
    private func updateSegmentColors() {
        for (index, button) in segmentButtons.enumerated() {
            let isSelected = index == selectedIndex
            let color: UIColor = isSelected ? .systemBlue : .white
            
            // 更新图标颜色
            if let stackView = button.subviews.first as? UIStackView,
               let iconImageView = stackView.arrangedSubviews.first as? UIImageView {
                iconImageView.tintColor = color
            }
            
            // 更新文字颜色
            if let stackView = button.subviews.first as? UIStackView,
               let titleLabel = stackView.arrangedSubviews.last as? UILabel {
                titleLabel.textColor = color
            }
        }
    }
    
    // MARK: - 公开方法
    func setSelectedIndex(_ index: Int, animated: Bool = true) {
        guard index >= 0, index < items.count, index != selectedIndex else { return }
        selectedIndex = index
        if animated {
            updateSelection(animated: true)
        }
    }
    
    func updateItems(_ newItems: [SegmentItem]) {
        items = newItems
        
        // 清除旧的按钮
        segmentButtons.forEach { $0.removeFromSuperview() }
        segmentStackView.removeFromSuperview()
        
        // 创建新的按钮和布局
        createSegmentButtons()
        segmentStackView = UIStackView(arrangedSubviews: segmentButtons)
        segmentStackView.axis = .horizontal
        segmentStackView.distribution = .fillEqually
        segmentStackView.alignment = .center
        segmentStackView.spacing = 0
        segmentStackView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(segmentStackView)
        
        // 重新设置约束
        NSLayoutConstraint.activate([
            segmentStackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            segmentStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            segmentStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            segmentStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        // 重置选中状态
        selectedIndex = 0
        updateSelection(animated: false)
    }
}

// MARK: - UIGestureRecognizerDelegate
extension CustomSegmentView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}