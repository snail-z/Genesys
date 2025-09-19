import UIKit
import SnapKit

public final class NeonSegmentIndicator: UIView {
    
    // MARK: - 约束引用
    private var widthConstraint: Constraint?
    private var centerXConstraint: Constraint?
    private var heightConstraint: Constraint?
    
    // MARK: - 配置
    private var style: NeonSegmentStyle
    private var containerHeight: CGFloat
    private var indicatorInset: CGFloat
    
    // MARK: - 初始化
    public init(style: NeonSegmentStyle, containerHeight: CGFloat, indicatorInset: CGFloat) {
        self.style = style
        self.containerHeight = containerHeight
        self.indicatorInset = indicatorInset
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI 设置
    private func setupUI() {
        backgroundColor = style.indicatorColor
        updateCornerRadius()
    }
    
    // MARK: - 布局
    public override func layoutSubviews() {
        super.layoutSubviews()
        updateCornerRadius()
    }
    
    private func updateCornerRadius() {
        layer.cornerRadius = bounds.height / 2
    }
    
    // MARK: - 公开方法
    public func setupConstraints(in containerView: UIView) {
        containerView.addSubview(self)
        
        snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            self.heightConstraint = make.height.equalTo(containerHeight - indicatorInset * 2).constraint
            self.widthConstraint = make.width.equalTo(100).constraint // 默认宽度，后续会更新
            self.centerXConstraint = make.centerX.equalTo(containerView.snp.leading).offset(50).constraint // 默认位置
        }
    }
    
    public func updatePosition(centerX: CGFloat, width: CGFloat, animated: Bool = true) {
        centerXConstraint?.update(offset: centerX)
        widthConstraint?.update(offset: width)
        if !animated {
            superview?.layoutIfNeeded()
        }
    }
    
    // 直接访问约束常量的方法，与原代码兼容
    public func setConstraintConstants(centerX: CGFloat, width: CGFloat) {
        centerXConstraint?.layoutConstraints.first?.constant = centerX
        widthConstraint?.layoutConstraints.first?.constant = width
    }
    
    public func updateStyle(_ style: NeonSegmentStyle) {
        self.style = style
        backgroundColor = style.indicatorColor
    }
    
    public func updateContainerHeight(_ height: CGFloat, indicatorInset: CGFloat) {
        self.containerHeight = height
        self.indicatorInset = indicatorInset
        heightConstraint?.update(offset: height - indicatorInset * 2)
        updateCornerRadius()
    }
    
    // MARK: - 约束访问器（供动画使用）
    public var centerXOffset: CGFloat {
        get { centerXConstraint?.layoutConstraints.first?.constant ?? 0 }
        set { centerXConstraint?.update(offset: newValue) }
    }
    
    public var widthValue: CGFloat {
        get { widthConstraint?.layoutConstraints.first?.constant ?? 0 }
        set { widthConstraint?.update(offset: newValue) }
    }
}