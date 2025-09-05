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
        collectionView.isPagingEnabled = true
        
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
            return cell
        case .medium:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediumWidgetCell", for: indexPath) as! MediumWidgetCell
            return cell
        case .large:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LargeWidgetCell", for: indexPath) as! LargeWidgetCell
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // 直接使用传入的cell参数，不要重新dequeue
        if let baseCell = cell as? BaseWidgetCell {
            baseCell.startAnim()
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension WidgetAddViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        guard indexPath.item < widgetSizes.count else { return .zero }
        
        let widgetSize = widgetSizes[indexPath.item]
        
        switch widgetSize.type {
        case .small:
            return CGSize(width: 140, height: 140)
        case .medium:
            return CGSize(width: (collectionView.frame.width - 100), height: 140)
        case .large:
            return CGSize(width: (collectionView.frame.width - 100), height: (collectionView.frame.width - 100))
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = Int((scrollView.contentOffset.x + scrollView.frame.width / 2) / scrollView.frame.width)
        let clampedPage = max(0, min(page, widgetSizes.count - 1))
        
        if pageControl.currentPage != clampedPage {
            pageControl.currentPage = clampedPage
        }
    }
}

