import UIKit

class DemoDetailViewController: UIViewController {
    
    private let demoItem: DemoItem
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let detailTextView = UITextView()
    private let runDemoButton = UIButton(type: .system)
    
    init(demoItem: DemoItem) {
        self.demoItem = demoItem
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        configureContent()
    }
    
    private func setupNavigationBar() {
        title = demoItem.title
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .systemBlue
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .boldSystemFont(ofSize: 28)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.font = .systemFont(ofSize: 18)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        
        detailTextView.translatesAutoresizingMaskIntoConstraints = false
        detailTextView.font = .systemFont(ofSize: 16)
        detailTextView.textColor = .label
        detailTextView.backgroundColor = .secondarySystemBackground
        detailTextView.layer.cornerRadius = 12
        detailTextView.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        detailTextView.isEditable = false
        detailTextView.isScrollEnabled = false
        
        runDemoButton.translatesAutoresizingMaskIntoConstraints = false
        runDemoButton.setTitle("运行演示", for: .normal)
        runDemoButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
        runDemoButton.backgroundColor = .systemBlue
        runDemoButton.setTitleColor(.white, for: .normal)
        runDemoButton.layer.cornerRadius = 12
        runDemoButton.addTarget(self, action: #selector(runDemoTapped), for: .touchUpInside)
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(detailTextView)
        contentView.addSubview(runDemoButton)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            iconImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 32),
            iconImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 80),
            iconImageView.heightAnchor.constraint(equalToConstant: 80),
            
            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            detailTextView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 32),
            detailTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            detailTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            runDemoButton.topAnchor.constraint(equalTo: detailTextView.bottomAnchor, constant: 32),
            runDemoButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            runDemoButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            runDemoButton.heightAnchor.constraint(equalToConstant: 50),
            runDemoButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
        ])
    }
    
    private func configureContent() {
        iconImageView.image = UIImage(systemName: demoItem.icon)
        titleLabel.text = demoItem.title
        descriptionLabel.text = demoItem.description
        
        let detailText = getDetailText(for: demoItem.title)
        detailTextView.text = detailText
    }
    
    private func getDetailText(for title: String) -> String {
        switch title {
        case "Widget基础示例":
            return """
            这个演示将展示如何创建一个基础的Widget：
            
            1. 定义Widget的配置
            2. 创建TimelineEntry
            3. 实现TimelineProvider
            4. 设计Widget视图
            5. 配置Widget种类和大小
            
            Widget是iOS 14引入的功能，允许应用在主屏幕和今日视图中显示实时信息。
            """
            
        case "Timeline更新":
            return """
            Timeline更新机制演示：
            
            1. 理解Timeline的概念
            2. 创建多个TimelineEntry
            3. 设置刷新策略
            4. 处理后台更新
            5. 优化更新频率
            
            合理的Timeline更新策略能够确保Widget内容的及时性，同时不会过度消耗系统资源。
            """
            
        case "用户配置":
            return """
            Widget用户配置演示：
            
            1. 创建配置Intent
            2. 定义配置选项
            3. 实现配置界面
            4. 处理配置变更
            5. 保存用户偏好
            
            用户配置让Widget更加个性化，满足不同用户的需求。
            """
            
        case "动态内容":
            return """
            动态内容展示演示：
            
            1. 实时数据获取
            2. 内容动态更新
            3. 状态管理
            4. 动画效果
            5. 错误处理
            
            动态内容让Widget保持活跃，为用户提供最新的信息。
            """
            
        case "网络数据":
            return """
            网络数据获取演示：
            
            1. 网络请求实现
            2. 数据解析和处理
            3. 缓存机制
            4. 错误状态显示
            5. 离线数据处理
            
            从网络获取数据是许多Widget的核心功能。
            """
            
        case "深度链接":
            return """
            深度链接演示：
            
            1. 配置URL Scheme
            2. 处理Widget点击
            3. 应用内导航
            4. 参数传递
            5. 用户体验优化
            
            深度链接让用户能够快速访问应用的特定功能。
            """
            
        case "多尺寸适配":
            return """
            多尺寸适配演示：
            
            1. 小尺寸Widget设计
            2. 中等尺寸Widget设计
            3. 大尺寸Widget设计
            4. 响应式布局
            5. 内容优先级
            
            不同尺寸的Widget需要展示不同详细程度的信息。
            """
            
        case "日历Widget":
            return """
            日历Widget演示：
            
            1. 日历视图创建
            2. 当前日期高亮
            3. 事件和提醒显示
            4. 月份切换动画
            5. 不同尺寸的日历布局
            6. 节假日标记
            7. 点击日期跳转
            
            日历Widget让用户快速查看日期和重要事件，是最实用的Widget类型之一。
            """
            
        case "Live Activity":
            return """
            Live Activity演示：
            
            1. Live Activity配置
            2. 实时状态更新
            3. Dynamic Island集成
            4. 推送通知更新
            5. 生命周期管理
            
            Live Activity为正在进行的活动提供实时更新。
            """
            
        default:
            return "这是一个Widget演示示例，展示了Widget开发的各种技术和最佳实践。"
        }
    }
    
    @objc private func runDemoTapped() {
        // 如果是日历Widget，直接跳转到日历页面
        if demoItem.title == "日历Widget" {
            let calendarVC = CalendarViewController()
            navigationController?.pushViewController(calendarVC, animated: true)
        } else {
            let alert = UIAlertController(
                title: "演示运行",
                message: "演示\"\(demoItem.title)\"已启动！\n\n在实际项目中，这里会执行具体的演示代码。",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "确定", style: .default))
            present(alert, animated: true)
        }
    }
}