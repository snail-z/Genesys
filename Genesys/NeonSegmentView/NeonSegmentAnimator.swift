import UIKit

public protocol NeonSegmentAnimatorDelegate: AnyObject {
    func animatorDidUpdateSelection(_ animator: NeonSegmentAnimator, to index: Int)
    func animatorShouldUpdateIndicatorPosition(_ animator: NeonSegmentAnimator, centerX: CGFloat)
    func animatorDidRequestLayoutUpdate(_ animator: NeonSegmentAnimator)
    func animatorDidRequestMaskUpdate(_ animator: NeonSegmentAnimator)
}

public final class NeonSegmentAnimator: NSObject {
    
    // MARK: - 代理
    public weak var delegate: NeonSegmentAnimatorDelegate?
    
    // MARK: - 动画配置
    public var springDamping: CGFloat = 0.72
    public var springInitialVelocity: CGFloat = 0.4
    
    // MARK: - 手势相关
    private var panGesture: UIPanGestureRecognizer!
    private var initialIndicatorCenter: CGPoint = .zero
    private var initialPanLocation: CGPoint = .zero
    
    // MARK: - 动画相关
    private var displayLink: CADisplayLink?
    
    // MARK: - 数据
    private var segmentCount: Int = 0
    private var segmentSpacing: CGFloat = 0
    private var containerWidth: CGFloat = 0
    private var selectedIndex: Int = 0
    
    // MARK: - 初始化
    public init(targetView: UIView) {
        super.init()
        setupGestures(for: targetView)
    }
    
    // MARK: - 手势设置
    private func setupGestures(for view: UIView) {
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panGesture.delegate = self
        view.addGestureRecognizer(panGesture)
    }
    
    // MARK: - 配置更新
    public func updateConfiguration(segmentCount: Int, segmentSpacing: CGFloat, containerWidth: CGFloat, selectedIndex: Int) {
        self.segmentCount = segmentCount
        self.segmentSpacing = segmentSpacing
        self.containerWidth = containerWidth
        self.selectedIndex = selectedIndex
    }
    
    // MARK: - 选择更新动画
    public func animateToSelection(_ index: Int, from currentIndex: Int, completion: (() -> Void)? = nil) {
        guard segmentCount > 0, index >= 0, index < segmentCount else { return }
        
        // 计算目标位置
        let totalSpacing = segmentSpacing * CGFloat(max(0, segmentCount - 1))
        let segmentWidth = (containerWidth - totalSpacing) / CGFloat(segmentCount)
        let unit = segmentWidth + segmentSpacing
        let targetCenterX = unit * CGFloat(index) + segmentWidth / 2
        
        // 计算动画参数
        let currentCenterX = unit * CGFloat(currentIndex) + segmentWidth / 2
        let delta = abs(targetCenterX - currentCenterX)
        let distanceNorm = segmentWidth > 0 ? min(1.0, delta / (segmentWidth * 1.5)) : 0
        
        // 动态时长与初速度
        let baseDuration: TimeInterval = 0.32
        let duration = baseDuration + 0.18 * TimeInterval(distanceNorm)
        let iv = max(0.0, min(1.6, springInitialVelocity + 0.6 * distanceNorm))
        
        startMaskTrackingDisplayLink()
        
        UIView.animate(
            withDuration: duration,
            delay: 0,
            usingSpringWithDamping: springDamping,
            initialSpringVelocity: iv,
            options: [.curveEaseInOut, .allowUserInteraction, .beginFromCurrentState]
        ) {
            self.delegate?.animatorShouldUpdateIndicatorPosition(self, centerX: targetCenterX)
            self.delegate?.animatorDidRequestLayoutUpdate(self)
        } completion: { _ in
            self.stopMaskTrackingDisplayLink()
            self.delegate?.animatorDidRequestMaskUpdate(self)
            completion?()
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
        guard let view = gesture.view else { return }
        
        // 获取当前指示器的实际中心位置（与原代码一致）
        if let indicator = (view as? NeonSegmentView)?.indicator {
            initialIndicatorCenter = indicator.center
        } else {
            // 备用计算方案
            let totalSpacing = segmentSpacing * CGFloat(max(0, segmentCount - 1))
            let segmentWidth = (containerWidth - totalSpacing) / CGFloat(segmentCount)
            let unit = segmentWidth + segmentSpacing
            let currentCenterX = unit * CGFloat(selectedIndex) + segmentWidth / 2
            initialIndicatorCenter = CGPoint(x: currentCenterX, y: 0)
        }
        initialPanLocation = gesture.location(in: view)
        
        // 触觉反馈
        NeonHaptics.impactLight()
    }
    
    private func handlePanChanged(_ gesture: UIPanGestureRecognizer) {
        guard let view = gesture.view else { return }
        
        let currentLocation = gesture.location(in: view)
        let deltaX = currentLocation.x - initialPanLocation.x
        
        // 计算新的指示器位置
        var newCenterX = initialIndicatorCenter.x + deltaX
        let totalSpacing = segmentSpacing * CGFloat(max(0, segmentCount - 1))
        let segmentWidth = (containerWidth - totalSpacing) / CGFloat(segmentCount)
        let unit = segmentWidth + segmentSpacing
        
        // 限制指示器在有效范围内
        let minX = segmentWidth / 2
        let maxX = unit * CGFloat(segmentCount - 1) + segmentWidth / 2
        newCenterX = max(minX, min(maxX, newCenterX))
        
        // 更新指示器位置
        delegate?.animatorShouldUpdateIndicatorPosition(self, centerX: newCenterX)
        delegate?.animatorDidRequestLayoutUpdate(self)
        delegate?.animatorDidRequestMaskUpdate(self)
    }
    
    private func handlePanEnded(_ gesture: UIPanGestureRecognizer) {
        guard let view = gesture.view else { return }
        
        let velocity = gesture.velocity(in: view)
        let currentLocation = gesture.location(in: view)
        
        // 计算应该选中的索引
        let totalSpacing = segmentSpacing * CGFloat(max(0, segmentCount - 1))
        let segmentWidth = (containerWidth - totalSpacing) / CGFloat(segmentCount)
        let unit = segmentWidth + segmentSpacing
        var targetIndex = Int(currentLocation.x / unit)
        
        // 考虑滑动速度
        if abs(velocity.x) > 500 {
            if velocity.x > 0 && targetIndex < segmentCount - 1 {
                targetIndex += 1
            } else if velocity.x < 0 && targetIndex > 0 {
                targetIndex -= 1
            }
        }
        
        // 确保索引在有效范围内
        targetIndex = max(0, min(segmentCount - 1, targetIndex))
        
        // 如果索引发生变化，更新选中状态
        if targetIndex != selectedIndex {
            selectedIndex = targetIndex
            delegate?.animatorDidUpdateSelection(self, to: targetIndex)
            NeonHaptics.selectionChanged()
        } else {
            // 如果没有变化，动画回到原位置
            animateToSelection(selectedIndex, from: selectedIndex)
        }
    }
    
    // MARK: - 遮罩动画跟踪
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
        delegate?.animatorDidRequestMaskUpdate(self)
    }
}

// MARK: - UIGestureRecognizerDelegate
extension NeonSegmentAnimator: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}