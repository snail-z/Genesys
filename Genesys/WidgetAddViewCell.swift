//
//  WidgetAddViewCell.swift
//  Genesys
//
//  Created by Aholt on 2025/9/4.
//

import UIKit

// MARK: - Base Widget Cell
class BaseWidgetCell: UICollectionViewCell {
    
    private let colors: [UIColor] = [.systemRed, .systemBlue, .systemGreen, .systemOrange, .systemPurple, .systemPink, .systemYellow]
    
    lazy var widgetView: UIView = {
        let widgetView = UIView()
        widgetView.layer.cornerRadius = 12
        widgetView.layer.masksToBounds = false
        widgetView.backgroundColor = colors.randomElement()
        return widgetView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBaseUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupBaseUI()
    }
    
    private func setupBaseUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        contentView.addSubview(widgetView)
        widgetView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        configureContent()
        setupEffects()
    }
    
    // MARK: - Animation Methods
    func startAnim() {
        // 检查动画是否已经在运行
        if widgetView.layer.animation(forKey: "cornerRotation") != nil {
            return
        }
        
//        widgetView.layer.transform = .
        
        stopAnim()
        setupStatic3DEffect(for: widgetView)
        
       
        
        // 确保布局完成后启动动画
        DispatchQueue.main.async { [weak self] in
            self?.startWidgetAnimation()
        }
    }
    
    func stopAnim() {
        widgetView.stopCard3DAnimation()
        widgetView.layer.removeAllAnimations()
        widgetView.layer.transform = CATransform3DIdentity
    }
    
    private func configureContent() {
        addWidgetContent(to: widgetView)
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    private func setupEffects() {
        setupShadowEffect(for: widgetView)
        widgetView.setupCard3DPerspective()
        setupStatic3DEffect(for: widgetView)
    }
    
    // MARK: - Private Methods
    private func setupShadowEffect(for view: UIView) {
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 40)
        view.layer.shadowRadius = 20
        view.layer.shadowOpacity = 0.25
        view.layer.masksToBounds = false
    }
    
    /// 子类重写此方法设置各自的3D效果
    func setupStatic3DEffect(for view: UIView) {
        // 子类实现
    }
    
    // MARK: - Override Methods
    /// 子类重写此方法实现具体动画
    func startWidgetAnimation() {
        // 子类实现
    }
    
    /// 子类重写此方法添加内容
    func addWidgetContent(to view: UIView) {
        // 子类实现
    }
}

// MARK: - Small Widget Cell
class SmallWidgetCell: BaseWidgetCell {
    
    override func startWidgetAnimation() {
        widgetView.startCard3DAnimation(isSmallCard: true)
    }
    
    override func setupStatic3DEffect(for view: UIView) {
        view.setToFirstFrameState(isSmallCard: true)
    }
    
    override func addWidgetContent(to view: UIView) {
        let iconView = UIView()
        iconView.backgroundColor = .systemGray4
        iconView.layer.cornerRadius = 4
        
        let line1 = UIView()
        line1.backgroundColor = .systemGray5
        line1.layer.cornerRadius = 2
        
        let line2 = UIView()
        line2.backgroundColor = .systemGray5
        line2.layer.cornerRadius = 2
        
        let line3 = UIView()
        line3.backgroundColor = .systemGray5
        line3.layer.cornerRadius = 2
        
        view.addSubview(iconView)
        view.addSubview(line1)
        view.addSubview(line2)
        view.addSubview(line3)
        
        iconView.snp.makeConstraints { make in
            make.top.left.equalToSuperview().inset(16)
            make.size.equalTo(20)
        }
        
        line1.snp.makeConstraints { make in
            make.top.equalTo(iconView.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(16)
            make.width.equalTo(70)
            make.height.equalTo(4)
        }
        
        line2.snp.makeConstraints { make in
            make.top.equalTo(line1.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(16)
            make.width.equalTo(60)
            make.height.equalTo(4)
        }
        
        line3.snp.makeConstraints { make in
            make.top.equalTo(line2.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(16)
            make.width.equalTo(50)
            make.height.equalTo(4)
        }
    }
}

// MARK: - Medium Widget Cell
class MediumWidgetCell: BaseWidgetCell {
    
    override func startWidgetAnimation() {
        widgetView.startCard3DAnimation(isSmallCard: false)
    }
    
    override func setupStatic3DEffect(for view: UIView) {
        view.setToFirstFrameState(isSmallCard: false)
    }
    
    override func addWidgetContent(to view: UIView) {
        let iconView = UIView()
        iconView.backgroundColor = .systemGray4
        iconView.layer.cornerRadius = 4
        
        let titleLine = UIView()
        titleLine.backgroundColor = .systemGray4
        titleLine.layer.cornerRadius = 2
        
        let line1 = UIView()
        line1.backgroundColor = .systemGray5
        line1.layer.cornerRadius = 2
        
        let line2 = UIView()
        line2.backgroundColor = .systemGray5
        line2.layer.cornerRadius = 2
        
        view.addSubview(iconView)
        view.addSubview(titleLine)
        view.addSubview(line1)
        view.addSubview(line2)
        
        iconView.snp.makeConstraints { make in
            make.top.left.equalToSuperview().inset(16)
            make.size.equalTo(16)
        }
        
        titleLine.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.equalTo(iconView.snp.right).offset(12)
            make.width.equalTo(120)
            make.height.equalTo(6)
        }
        
        line1.snp.makeConstraints { make in
            make.top.equalTo(titleLine.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(4)
        }
        
        line2.snp.makeConstraints { make in
            make.top.equalTo(line1.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(16)
            make.width.equalTo(180)
            make.height.equalTo(4)
        }
    }
}

// MARK: - Large Widget Cell
class LargeWidgetCell: BaseWidgetCell {
    
    override func startWidgetAnimation() {
        widgetView.startCard3DAnimation(isSmallCard: false)
    }
    
    override func setupStatic3DEffect(for view: UIView) {
        view.setToFirstFrameState(isSmallCard: false)
    }
    
    override func addWidgetContent(to view: UIView) {
        // 左侧照片网格
        let photoGridView = UIView()
        photoGridView.backgroundColor = .systemBackground
        photoGridView.layer.cornerRadius = 12
        
        // 右侧文字内容
        let textContentView = UIView()
        textContentView.backgroundColor = .systemBackground
        textContentView.layer.cornerRadius = 12
        
        view.addSubview(photoGridView)
        view.addSubview(textContentView)
        
        // 在照片网格中添加4x4的小方块
        for row in 0..<4 {
            for col in 0..<4 {
                let photoView = UIView()
                photoView.backgroundColor = .systemGray4
                photoView.layer.cornerRadius = 4
                photoGridView.addSubview(photoView)
                
                photoView.snp.makeConstraints { make in
                    make.size.equalTo(16)
                    make.top.equalToSuperview().offset(12 + row * 20)
                    make.left.equalToSuperview().offset(12 + col * 20)
                }
            }
        }
        
        // 在文字区域添加线条
        for i in 0..<8 {
            let line = UIView()
            line.backgroundColor = .systemGray5
            line.layer.cornerRadius = 2
            textContentView.addSubview(line)
            
            line.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(12 + i * 12)
                make.left.equalToSuperview().offset(12)
                make.width.equalTo(i % 3 == 0 ? 60 : 40)
                make.height.equalTo(3)
            }
        }
        
        photoGridView.snp.makeConstraints { make in
            make.top.left.equalToSuperview().inset(12)
            make.size.equalTo(120)
        }
        
        textContentView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.left.equalTo(photoGridView.snp.right).offset(8)
            make.right.equalToSuperview().offset(-12)
            make.height.equalTo(120)
        }
    }
}
