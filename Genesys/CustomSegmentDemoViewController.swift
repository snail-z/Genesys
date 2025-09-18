import UIKit
import SnapKit

class CustomSegmentDemoViewController: UIViewController {
    
    // MARK: - UI组件
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // 主要演示组件
    private var mainSegmentView: CustomSegmentView!
    private let mainSelectionLabel = UILabel()
    
    // 不同样式的演示组件
    private var twoSegmentView: CustomSegmentView!
    private var fourSegmentView: CustomSegmentView!
    private var fiveSegmentView: CustomSegmentView!
    
    // 状态标签
    private let twoSegmentLabel = UILabel()
    private let fourSegmentLabel = UILabel()
    private let fiveSegmentLabel = UILabel()
    
    // 实际应用演示
    private var contentSegmentView: CustomSegmentView!
    private let contentDisplayView = UIView()
    private let contentLabel = UILabel()
    
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupSegmentViews()
        setupConstraints()
    }
    
    // MARK: - UI设置
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "自定义segmentView演示"
        
        // 滚动视图设置
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)
        
        scrollView.addSubview(contentView)
        
        // 设置滚动视图约束
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
    }
    
    private func setupSegmentViews() {
        // 1. 主要演示 - 模仿设计图样式
        let mainItems = [
            SegmentItem(title: "Today", icon: "calendar.circle.fill"),
            SegmentItem(title: "游戏", icon: "gamecontroller.fill"),
            SegmentItem(title: "App", icon: "square.stack.3d.up.fill")
        ]
        
        mainSegmentView = CustomSegmentView(items: mainItems)
        mainSegmentView.selectedIndex = 2 // 默认选中App
        mainSegmentView.onSelectionChanged = { [weak self] index, item in
            self?.mainSelectionLabel.text = "当前选中：\\(item.title)（索引：\\(index)）"
            self?.animateSelectionLabel(self?.mainSelectionLabel)
        }
        
        // 主要演示标签
        mainSelectionLabel.text = "当前选中：App（索引：2）"
        mainSelectionLabel.font = .systemFont(ofSize: 16, weight: .medium)
        mainSelectionLabel.textColor = .label
        mainSelectionLabel.textAlignment = .center
        
        // 2. 两段演示
        let twoItems = [
            SegmentItem(title: "左侧", icon: "arrow.left.circle.fill"),
            SegmentItem(title: "右侧", icon: "arrow.right.circle.fill")
        ]
        
        twoSegmentView = CustomSegmentView(items: twoItems)
        twoSegmentView.onSelectionChanged = { [weak self] index, item in
            self?.twoSegmentLabel.text = "选择了：\\(item.title)"
            self?.animateSelectionLabel(self?.twoSegmentLabel)
        }
        
        twoSegmentLabel.text = "选择了：左侧"
        twoSegmentLabel.font = .systemFont(ofSize: 14)
        twoSegmentLabel.textColor = .secondaryLabel
        twoSegmentLabel.textAlignment = .center
        
        // 3. 四段演示
        let fourItems = [
            SegmentItem(title: "首页", icon: "house.fill"),
            SegmentItem(title: "搜索", icon: "magnifyingglass"),
            SegmentItem(title: "收藏", icon: "heart.fill"),
            SegmentItem(title: "设置", icon: "gear.badge")
        ]
        
        fourSegmentView = CustomSegmentView(items: fourItems)
        fourSegmentView.onSelectionChanged = { [weak self] index, item in
            self?.fourSegmentLabel.text = "导航到：\\(item.title)"
            self?.animateSelectionLabel(self?.fourSegmentLabel)
        }
        
        fourSegmentLabel.text = "导航到：首页"
        fourSegmentLabel.font = .systemFont(ofSize: 14)
        fourSegmentLabel.textColor = .secondaryLabel
        fourSegmentLabel.textAlignment = .center
        
        // 4. 五段演示
        let fiveItems = [
            SegmentItem(title: "全部", icon: "rectangle.grid.1x2.fill"),
            SegmentItem(title: "图片", icon: "photo.fill"),
            SegmentItem(title: "视频", icon: "video.fill"),
            SegmentItem(title: "音频", icon: "music.note"),
            SegmentItem(title: "文档", icon: "doc.fill")
        ]
        
        fiveSegmentView = CustomSegmentView(items: fiveItems)
        fiveSegmentView.onSelectionChanged = { [weak self] index, item in
            self?.fiveSegmentLabel.text = "筛选：\\(item.title)内容"
            self?.animateSelectionLabel(self?.fiveSegmentLabel)
        }
        
        fiveSegmentLabel.text = "筛选：全部内容"
        fiveSegmentLabel.font = .systemFont(ofSize: 14)
        fiveSegmentLabel.textColor = .secondaryLabel
        fiveSegmentLabel.textAlignment = .center
        
        // 5. 内容切换演示
        let contentItems = [
            SegmentItem(title: "介绍", icon: "info.circle.fill"),
            SegmentItem(title: "特性", icon: "star.fill"),
            SegmentItem(title: "使用", icon: "play.circle.fill")
        ]
        
        contentSegmentView = CustomSegmentView(items: contentItems)
        contentSegmentView.onSelectionChanged = { [weak self] index, item in
            self?.updateContentDisplay(for: index, item: item)
        }
        
        // 内容显示区域
        contentDisplayView.backgroundColor = .secondarySystemBackground
        contentDisplayView.layer.cornerRadius = 12
        
        contentLabel.font = .systemFont(ofSize: 16)
        contentLabel.textColor = .label
        contentLabel.numberOfLines = 0
        contentLabel.textAlignment = .left
        
        contentDisplayView.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
        
        // 设置初始内容
        updateContentDisplay(for: 0, item: contentItems[0])
    }
    
    private func setupConstraints() {
        // 添加所有视图到contentView
        let titleLabel1 = createTitleLabel("主要演示 - 原设计风格")
        let titleLabel2 = createTitleLabel("两段式选择器")
        let titleLabel3 = createTitleLabel("四段式导航")
        let titleLabel4 = createTitleLabel("五段式筛选器")
        let titleLabel5 = createTitleLabel("实际应用演示 - 内容切换")
        
        contentView.addSubview(titleLabel1)
        contentView.addSubview(mainSegmentView)
        contentView.addSubview(mainSelectionLabel)
        
        contentView.addSubview(titleLabel2)
        contentView.addSubview(twoSegmentView)
        contentView.addSubview(twoSegmentLabel)
        
        contentView.addSubview(titleLabel3)
        contentView.addSubview(fourSegmentView)
        contentView.addSubview(fourSegmentLabel)
        
        contentView.addSubview(titleLabel4)
        contentView.addSubview(fiveSegmentView)
        contentView.addSubview(fiveSegmentLabel)
        
        contentView.addSubview(titleLabel5)
        contentView.addSubview(contentSegmentView)
        contentView.addSubview(contentDisplayView)
        
        // 设置约束
        titleLabel1.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        mainSegmentView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel1.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(60)
        }
        
        mainSelectionLabel.snp.makeConstraints { make in
            make.top.equalTo(mainSegmentView.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        titleLabel2.snp.makeConstraints { make in
            make.top.equalTo(mainSelectionLabel.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        twoSegmentView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel2.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(40)
            make.height.equalTo(60)
        }
        
        twoSegmentLabel.snp.makeConstraints { make in
            make.top.equalTo(twoSegmentView.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        titleLabel3.snp.makeConstraints { make in
            make.top.equalTo(twoSegmentLabel.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        fourSegmentView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel3.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(60)
        }
        
        fourSegmentLabel.snp.makeConstraints { make in
            make.top.equalTo(fourSegmentView.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        titleLabel4.snp.makeConstraints { make in
            make.top.equalTo(fourSegmentLabel.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        fiveSegmentView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel4.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(60)
        }
        
        fiveSegmentLabel.snp.makeConstraints { make in
            make.top.equalTo(fiveSegmentView.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        titleLabel5.snp.makeConstraints { make in
            make.top.equalTo(fiveSegmentLabel.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        contentSegmentView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel5.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(30)
            make.height.equalTo(60)
        }
        
        contentDisplayView.snp.makeConstraints { make in
            make.top.equalTo(contentSegmentView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.greaterThanOrEqualTo(120)
            make.bottom.equalToSuperview().offset(-30)
        }
    }
    
    // MARK: - 辅助方法
    private func createTitleLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = .label
        return label
    }
    
    private func animateSelectionLabel(_ label: UILabel?) {
        guard let label = label else { return }
        
        UIView.animate(withDuration: 0.2, animations: {
            label.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                label.transform = .identity
            }
        }
    }
    
    private func updateContentDisplay(for index: Int, item: SegmentItem) {
        let content: String
        
        switch index {
        case 0: // 介绍
            content = """
            📱 CustomSegmentView 简介
            
            这是一个高度定制化的分段控制器组件，具有以下特点：
            
            • 现代化的视觉设计风格
            • 流畅的动画过渡效果
            • 支持点击和滑动交互
            • 完整的触觉反馈体验
            • 高度可配置的外观选项
            """
            
        case 1: // 特性
            content = """
            ✨ 核心特性
            
            🎨 视觉设计：
            • 胶囊形状容器设计
            • 动态选中指示器
            • 图标+文字垂直布局
            • 自适应颜色主题
            
            🎭 交互体验：
            • 点击快速切换
            • 滑动手势支持
            • 弹性动画效果
            • Haptic Feedback反馈
            
            🔧 技术实现：
            • 纯代码实现
            • SnapKit约束布局
            • Core Animation动画
            • 手势识别处理
            """
            
        case 2: // 使用
            content = """
            🚀 使用方法
            
            1️⃣ 创建数据模型：
            let items = [
                SegmentItem(title: "标题", icon: "图标名称"),
                // 更多项目...
            ]
            
            2️⃣ 初始化组件：
            let segmentView = CustomSegmentView(items: items)
            
            3️⃣ 设置回调：
            segmentView.onSelectionChanged = { index, item in
                // 处理选择变化
            }
            
            4️⃣ 添加到视图：
            view.addSubview(segmentView)
            // 设置约束...
            """
            
        default:
            content = "选择一个选项查看相关内容"
        }
        
        UIView.transition(with: contentDisplayView, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.contentLabel.text = content
        })
    }
}