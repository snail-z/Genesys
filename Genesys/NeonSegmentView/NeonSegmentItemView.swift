import UIKit
import SnapKit

public final class NeonSegmentItemView: UIView {
    
    // MARK: - UI 组件
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let stackView = UIStackView()
    
    // MARK: - 数据
    private var item: NeonSegmentItem
    private var style: NeonSegmentStyle
    
    // MARK: - 初始化
    public init(item: NeonSegmentItem, style: NeonSegmentStyle) {
        self.item = item
        self.style = style
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI 设置
    private func setupUI() {
        isUserInteractionEnabled = false
        
        // 图标设置
        iconImageView.image = UIImage(systemName: item.icon)
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = style.normalForegroundColor
        
        // 标题设置
        titleLabel.text = item.title
        titleLabel.font = style.font
        titleLabel.textColor = style.normalForegroundColor
        titleLabel.textAlignment = .center
        
        // 堆栈视图设置
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = style.contentSpacing
        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(titleLabel)
        
        addSubview(stackView)
        
        // 约束设置
        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        iconImageView.snp.makeConstraints { make in
            make.width.equalTo(style.iconSize.width)
            make.height.equalTo(style.iconSize.height)
        }
    }
    
    // MARK: - 公开方法
    public func updateColors(foregroundColor: UIColor) {
        iconImageView.tintColor = foregroundColor
        titleLabel.textColor = foregroundColor
    }
    
    public func updateStyle(_ style: NeonSegmentStyle) {
        self.style = style
        titleLabel.font = style.font
        stackView.spacing = style.contentSpacing
        
        iconImageView.snp.updateConstraints { make in
            make.width.equalTo(style.iconSize.width)
            make.height.equalTo(style.iconSize.height)
        }
    }
}

