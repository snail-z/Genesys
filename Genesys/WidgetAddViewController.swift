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
        WidgetSize(name: "大", widgetSize: CGSize(width: 260, height: 260), type: .large),
        
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
        collectionView.backgroundColor = .clear
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
        
        // 注册三种不同的cell
        collectionView.register(SmallWidgetCell.self, forCellWithReuseIdentifier: "SmallWidgetCell")
        collectionView.register(MediumWidgetCell.self, forCellWithReuseIdentifier: "MediumWidgetCell")
        collectionView.register(LargeWidgetCell.self, forCellWithReuseIdentifier: "LargeWidgetCell")
        
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
        
        // 集合视图约束 (充分增加高度以完全显示大号Widget的阴影效果)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(140)
            make.left.right.equalToSuperview()
            make.height.equalTo(450) // 大号Widget(293pt) + 阴影(60pt) + 3D旋转缓冲(50pt) + 安全边距(47pt)
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
        let widgetSize = widgetSizes[indexPath.item]
        
        // 根据类型选择对应的cell
        switch widgetSize.type {
        case .small:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SmallWidgetCell", for: indexPath) as! SmallWidgetCell
            cell.configure(indexPath: indexPath)
            return cell
        case .medium:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediumWidgetCell", for: indexPath) as! MediumWidgetCell
            cell.configure(indexPath: indexPath)
            return cell
        case .large:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LargeWidgetCell", for: indexPath) as! LargeWidgetCell
            cell.configure(indexPath: indexPath)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // 直接使用传入的cell参数，不要重新dequeue
        if let baseCell = cell as? BaseWidgetCell {
//            baseCell.startAnim()
        }
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

// MARK: - Base Widget Cell
class BaseWidgetCell: UICollectionViewCell {
    
    var widgetView: UIView!
    let colors: [UIColor] = [.systemRed, .systemBlue, .systemGreen, .systemOrange, .systemPurple, .systemPink, .systemYellow]
    
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
        
        // configure()在外部调用时传入indexPath
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // 不要停止动画，让3D旋转动画持续进行
        // 这样可以避免动画重新开始时的状态跳跃
    }
    
    func startAnim() {
        // 确保在视图完全稳定后启动动画，避免闪动
        startAnimationWhenReady()
    }
    
    private func startAnimationWhenReady() {
        // 检查动画是否已经在运行
        if widgetView?.layer.animation(forKey: "cornerRotation") != nil {
            return // 动画已存在，不重复启动
        }
        
        // 确保视图布局完成
        widgetView?.layoutIfNeeded()
        
        
        // 在下一个 runloop cycle 启动动画，确保所有布局都已稳定
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let widgetView = self.widgetView else { return }
            
            // 再次检查动画是否已启动（可能在异步等待期间被其他地方启动）
            if widgetView.layer.animation(forKey: "cornerRotation") == nil {
                self.startWidgetAnimation()
            }
        }
    }
    
    func stopAnim() {
        // 停止3D卡片动画
        widgetView?.stopCard3DAnimation()
        
        // 重置transform状态，避免残留状态影响下次使用
        widgetView?.layer.removeAllAnimations()
        widgetView?.layer.transform = CATransform3DIdentity
    }
    
    func configure(indexPath: IndexPath) {
        // 创建新的 widgetView
        widgetView?.removeFromSuperview()
        widgetView = UIView()
        widgetView.layer.cornerRadius = 12
        widgetView.layer.masksToBounds = false
        
        contentView.addSubview(widgetView)
        
        // 设置约束让 widget 居中显示
        widgetView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 设置随机颜色
        widgetView.backgroundColor = colors.randomElement()
        
        // 添加内容（由子类实现）
        addWidgetContent(to: widgetView)
        
        
        
        // 设置阴影效果（只需要设置一次）
        setupShadowEffect(for: widgetView)
        
        // 强制立即完成布局
        setNeedsLayout()
        layoutIfNeeded()
        
        // 设置3D透视效果，并添加静态3D变换来展示效果
        widgetView.setupCard3DPerspective()
        setupStatic3DEffect(for: widgetView, cellType: indexPath.item % 3)
    }
    
    /// 设置阴影效果（只在初始化时调用一次）
    private func setupShadowEffect(for view: UIView) {
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 40)
        view.layer.shadowRadius = 20
        view.layer.shadowOpacity = 0.25
        view.layer.masksToBounds = false
    }
    
    /// 设置静态3D效果来展示透视效果
    /// - Parameters:
    ///   - view: 目标视图
    ///   - cellType: cell类型 (0=小, 1=中, 2=大)
    private func setupStatic3DEffect(for view: UIView, cellType: Int) {
        var transform = view.layer.transform
        
        // 根据不同的cell类型设置不同的静态3D旋转角度
        switch cellType {
        case 0: // 小 Widget - X轴倾斜 + Y轴轻微旋转
            transform = CATransform3DRotate(transform, 0.3, 1.0, 0.0, 0.0) // X轴倾斜
            transform = CATransform3DRotate(transform, 0.15, 0.0, 1.0, 0.0) // Y轴轻微旋转
        case 1: // 中 Widget - X轴轻微倾斜 + Y轴轻微反向旋转
            transform = CATransform3DRotate(transform, 0.15, 1.0, 0.0, 0.0) // X轴轻微倾斜
            transform = CATransform3DRotate(transform, -0.1, 0.0, 1.0, 0.0) // Y轴轻微反向旋转
        case 2: // 大 Widget - X轴反向倾斜 + Y轴旋转（调整为更协调的角度）
            transform = CATransform3DRotate(transform, -0.12, 1.0, 0.0, 0.0) // X轴轻微反向倾斜
            transform = CATransform3DRotate(transform, 0.08, 0.0, 1.0, 0.0) // Y轴轻微旋转
        default:
            break
        }
        
        view.layer.transform = transform
    }
    
    // 由子类实现具体的动画参数
    func startWidgetAnimation() {
        // 子类重写此方法，设置适合自己尺寸的动画参数
    }
    
    // 由子类实现具体的内容添加
    func addWidgetContent(to view: UIView) {
        // 子类重写此方法
    }
}

// MARK: - Small Widget Cell
class SmallWidgetCell: BaseWidgetCell {
    
    override func startWidgetAnimation() {
        // 直接启动动画，因为BaseWidgetCell已经处理了重复启动检查
        widgetView?.startCard3DAnimation(isSmallCard: true)
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
        widgetView?.startCard3DAnimation(isSmallCard: false)
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
        widgetView?.startCard3DAnimation(isSmallCard: false)
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

