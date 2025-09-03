import UIKit
import SnapKit

/// Widget 尺寸模型
struct WidgetSize {
    let name: String
    let widgetSize: CGSize
}

class WidgetAddViewController: UIViewController {
    
    private let widgetSizes: [WidgetSize] = [
        WidgetSize(name: "小", widgetSize: CGSize(width: 120, height: 120)),
        WidgetSize(name: "中", widgetSize: CGSize(width: 260, height: 120)),  
        WidgetSize(name: "大", widgetSize: CGSize(width: 260, height: 260))
    ]
    
    private var backgroundView: UIVisualEffectView!
    private var headerView: UIView!
    private var headerTitleLabel: UILabel!
    private var closeButton: UIButton!
    private var scrollView: UIScrollView!
    private var pageControl: UIPageControl!
    private var addButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        setupBackground()
        setupHeaderView()
        setupScrollView()
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
    
    private func setupHeaderView() {
        headerView = UIView()
        headerView.backgroundColor = .systemBackground
        headerView.layer.cornerRadius = 20
        headerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.addSubview(headerView)
        
        headerTitleLabel = UILabel()
        headerTitleLabel.text = "智能叠放"
        headerTitleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        headerTitleLabel.textAlignment = .center
        headerView.addSubview(headerTitleLabel)
        
        closeButton = UIButton(type: .system)
        closeButton.setTitle("✕", for: .normal)
        closeButton.setTitleColor(.secondaryLabel, for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        headerView.addSubview(closeButton)
    }
    
    private func setupScrollView() {
        scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        view.addSubview(scrollView)
        
        // 创建简化的Widget预览卡片
        for (index, widget) in widgetSizes.enumerated() {
            let cardView = createSimpleWidgetCard(for: widget, at: index)
            cardView.backgroundColor = (index % 2 == 0) ? UIColor.cyan : .orange
            scrollView.addSubview(cardView)
            scrollView.backgroundColor = .gray
        }
    }
    
    private func createSimpleWidgetCard(for widget: WidgetSize, at index: Int) -> UIView {
        // 直接返回Widget预览，不需要白色卡片包装
        let widgetPreview = createWidgetPreview(for: widget, at: index)
        
        // 设置Widget位置
        let screenWidth = UIScreen.main.bounds.width
        let widgetX = (screenWidth - widget.widgetSize.width) / 2 + CGFloat(index) * screenWidth
        let widgetY: CGFloat = (300 - widget.widgetSize.height) / 2
        
        widgetPreview.frame = CGRect(x: widgetX, y: widgetY, width: widget.widgetSize.width, height: widget.widgetSize.height)
        
        return widgetPreview
    }
    
    private func createWidgetPreview(for widget: WidgetSize, at index: Int) -> UIView {
        let widgetView = UIView()
        widgetView.backgroundColor = .systemBackground
        widgetView.layer.cornerRadius = index == 2 ? 20 : 16
        widgetView.layer.shadowColor = UIColor.black.cgColor
        widgetView.layer.shadowOffset = CGSize(width: 0, height: 2)
        widgetView.layer.shadowRadius = 10
        widgetView.layer.shadowOpacity = 0.1
        
        // 根据不同尺寸添加不同的内容
        switch index {
        case 0: // 小号
            addSmallWidgetContent(to: widgetView)
        case 1: // 中号
            addMediumWidgetContent(to: widgetView)
        case 2: // 大号
            addLargeWidgetContent(to: widgetView)
        default:
            break
        }
        
        return widgetView
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
        
        // 头部视图约束
        headerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(60)
            make.left.equalToSuperview().offset(30)
            make.right.equalToSuperview().offset(-30)
            make.height.equalTo(80)
        }
        
        // 头部标题约束
        headerTitleLabel.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
        
        // 关闭按钮约束
        closeButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
            make.size.equalTo(30)
        }
        
        // 滚动视图约束
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(40)
            make.left.right.equalToSuperview()
            make.height.equalTo(300)
        }
        
        // 页面控制器约束
        pageControl.snp.makeConstraints { make in
            make.top.equalTo(scrollView.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
        }
        
        // 添加按钮约束
        addButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-30)
            make.left.equalToSuperview().offset(30)
            make.right.equalToSuperview().offset(-30)
            make.height.equalTo(50)
        }
        
        // 设置scrollView的contentSize
        DispatchQueue.main.async {
            let screenWidth = UIScreen.main.bounds.width
            self.scrollView.contentSize = CGSize(width: CGFloat(self.widgetSizes.count) * screenWidth, height: 300)
        }
    }
}

// MARK: - ScrollView Delegate
extension WidgetAddViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = Int((scrollView.contentOffset.x + scrollView.frame.width / 2) / scrollView.frame.width)
        let clampedPage = max(0, min(page, widgetSizes.count - 1))
        
        if pageControl.currentPage != clampedPage {
            pageControl.currentPage = clampedPage
        }
    }
}
