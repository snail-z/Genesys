import UIKit
import SnapKit

/// Widget 尺寸模型
struct WidgetSize {
    let name: String
    let widgetSize: CGSize
    let type: WidgetType
}

enum WidgetType: Int, CaseIterable {
    case small = 0
    case medium = 1
    case large = 2
}

class WidgetAddViewController: UIViewController {
    
    private let widgetSizes: [WidgetSize] = [
        WidgetSize(name: "小", widgetSize: CGSize(width: 120, height: 120), type: .small),
        WidgetSize(name: "中", widgetSize: CGSize(width: 260, height: 120), type: .medium),  
        WidgetSize(name: "大", widgetSize: CGSize(width: 260, height: 260), type: .large)
    ]
    
    private var backgroundView: UIVisualEffectView!
    private var headerView: UIView!
    private var headerTitleLabel: UILabel!
    private var closeButton: UIButton!
    private var collectionView: UICollectionView!
    private var pageControl: UIPageControl!
    private var addButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        setupBackground()
        setupCollectionView()
        setupPageControl()
        setupAddButton()
        setupConstraints()
    }
    
    private func setupBackground() {
        // 模糊背景效果
        let blurEffect = UIBlurEffect(style: .systemMaterial)
        backgroundView = UIVisualEffectView(effect: blurEffect)
        view.addSubview(backgroundView)
    }
    
    private func setupCollectionView() {
        let layout = DynamicSpacingFlowLayout()
        layout.minimumLineSpacing = 20
        layout.sideInset = 20
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
//        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.isPagingEnabled = true
        
//        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        collectionView.backgroundColor = .clear
//        collectionView.isPagingEnabled = false  // 关闭系统分页，使用自定义停靠
//        collectionView.showsHorizontalScrollIndicator = false
//        collectionView.dataSource = self
//        collectionView.delegate = self
//        collectionView.decelerationRate = UIScrollView.DecelerationRate.fast
        
        // 注册cell
        collectionView.register(WidgetPreviewCell.self, forCellWithReuseIdentifier: "WidgetPreviewCell")
        
        view.addSubview(collectionView)
    }
    
    
    private func setupPageControl() {
        pageControl = UIPageControl()
        pageControl.numberOfPages = widgetSizes.count
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = .systemGray4
        pageControl.currentPageIndicatorTintColor = .systemGray2
        view.addSubview(pageControl)
    }
    
    private func setupAddButton() {
        addButton = UIButton(type: .system)
        addButton.setTitle("添加小组件", for: .normal)
        addButton.setTitleColor(.white, for: .normal)
        addButton.backgroundColor = .systemBlue
        addButton.layer.cornerRadius = 25
        addButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        view.addSubview(addButton)
    }
    
    private func setupConstraints() {
        // 背景视图约束
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 集合视图约束
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(140)
            make.left.right.equalToSuperview()
            make.height.equalTo(300)
        }
        
        // 页面控制器约束
        pageControl.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
        }
        
        // 添加按钮约束
        addButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-30)
            make.left.equalToSuperview().offset(30)
            make.right.equalToSuperview().offset(-30)
            make.height.equalTo(50)
        }
    }
    
    let colors: [UIColor] = [.systemRed, .systemBlue, .systemGreen, .systemOrange, .systemPurple, .systemPink, .systemYellow]
}

// MARK: - UICollectionViewDataSource
extension WidgetAddViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return widgetSizes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WidgetPreviewCell", for: indexPath) as! WidgetPreviewCell
        let widgetSize = widgetSizes[indexPath.item]
        cell.configure(with: widgetSize)
//        cell.contentView.backgroundColor = (indexPath.item % 2 == 0 ) ? .orange : .cyan
        
//        cell.backgroundColor = colors[indexPath.item % colors.count]
//        cell.layer.cornerRadius = 12
//        cell.layer.masksToBounds = true
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension WidgetAddViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        switch indexPath.item % 3 {
        case 0:
            return CGSize(width: 140, height: 140)
        case 1:
            return CGSize(width: (collectionView.frame.width - 100), height: 140)
        case 2:
            return CGSize(width: (collectionView.frame.width - 100), height: (collectionView.frame.width - 100))
        default:
            return  .zero
        }
        
//        let widgetSize = widgetSizes[indexPath.item]
//        let heightt: CGFloat = 260
//        return CGSize(width: widgetSize.widgetSize.width, height: heightt)
//        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = Int((scrollView.contentOffset.x + scrollView.frame.width / 2) / scrollView.frame.width)
        let clampedPage = max(0, min(page, widgetSizes.count - 1))
        
        if pageControl.currentPage != clampedPage {
            pageControl.currentPage = clampedPage
        }
    }
}

// MARK: - WidgetPreviewCell
class WidgetPreviewCell: UICollectionViewCell {
    
    private var widgetView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    
    let colors: [UIColor] = [.systemRed, .systemBlue, .systemGreen, .systemOrange, .systemPurple, .systemPink, .systemYellow]
    private var isConfigured = false
    private var currentWidgetType: WidgetType?
    
    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // 停止3D卡片动画
        widgetView?.stopCard3DAnimation()
        
        // 重置状态标记
        isConfigured = false
        currentWidgetType = nil
        
        // 移除视图
        widgetView?.removeFromSuperview()
        widgetView = nil
    }
    
    // 已移动到 Card3DAnimationUtil 工具类中
    
    func configure(with widgetSize: WidgetSize) {
        // 如果已经配置过相同类型，直接返回，避免重复创建
        if isConfigured && currentWidgetType == widgetSize.type {
            return
        }
        
        // 清除之前的动画
        widgetView?.stopCard3DAnimation()
        
        // 只有在类型改变或首次配置时才重新创建
        if !isConfigured || currentWidgetType != widgetSize.type {
            // 清除之前的 widgetView
            widgetView?.removeFromSuperview()
            
            // 创建新的 widgetView
            widgetView = UIView()
            widgetView.layer.cornerRadius = 12
            widgetView.layer.masksToBounds = false
            
            contentView.addSubview(widgetView)
            
            // 设置约束让 widget 居中显示
            widgetView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            
            // 根据类型添加内容
            switch widgetSize.type {
            case .small:
                addSmallWidgetContent(to: widgetView)
            case .medium:
                addMediumWidgetContent(to: widgetView)
            case .large:
                addLargeWidgetContent(to: widgetView)
            }
            
            // 标记已配置
            isConfigured = true
            currentWidgetType = widgetSize.type
        }
        
        // 每次都设置颜色（这个比较轻量）
        widgetView.backgroundColor = colors.randomElement()
        
        // 设置3D透视效果
        widgetView.setupCard3DPerspective()
        
        // 开始3D卡片动画
        let isSmallWidget = (widgetSize.type == .small)
        widgetView.startCard3DAnimation(isSmallCard: isSmallWidget)
    }
    
    private func addSmallWidgetContent(to view: UIView) {
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
    
    private func addMediumWidgetContent(to view: UIView) {
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
    
    private func addLargeWidgetContent(to view: UIView) {
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

