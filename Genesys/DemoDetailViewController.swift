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
            
        case "透明组件演示":
            return """
            透明组件演示功能：
            
            1. 透明背景视图的创建和配置
            2. 半透明效果的实现技巧
            3. 毛玻璃效果（UIVisualEffectView）的使用
            4. 透明度渐变动画效果
            5. 背景模糊和色彩叠加
            6. 透明组件的层级管理
            7. 不同透明度级别的视觉对比
            8. 透明组件与用户交互的处理
            
            这个演示展示了iOS中各种透明效果的实现方法，包括完全透明、半透明、毛玻璃效果等。
            """
            
        case "清晰小日历组件":
            return """
            清晰小日历组件功能演示：
            
            1. 多种日历组件样式展示
            2. 简约月视图日历组件
            3. 紧凑周视图日历组件
            4. 数字时钟风格日历
            5. 卡片式日历组件
            6. 带事件指示的日历
            7. 透明背景日历组件
            8. 动态颜色主题切换
            9. 自定义字体和尺寸
            10. 响应式布局适配
            
            这个演示展示了多种精美的小日历组件设计，适用于不同的应用场景和设计风格。
            每个组件都具有清晰的视觉效果和良好的用户体验。
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
            
        case "添加Widget弹窗":
            return """
            Widget添加弹窗演示：
            
            1. 创建添加Widget界面
            2. 展示可用的Widget类型
            3. 预览不同尺寸的Widget
            4. 配置Widget参数
            5. 实现拖拽添加功能
            6. 处理添加确认和取消
            
            这个功能模拟系统的Widget添加流程，让用户能够方便地预览和配置Widget。
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
            
        case "工具面板演示":
            return """
            工具面板演示功能：
            
            1. 多功能工具集合界面
            2. 网格布局工具按钮
            3. 工具图标和标签展示
            4. 点击交互和反馈效果
            5. 分类工具组织方式
            6. 自适应布局设计
            7. 工具搜索和筛选
            
            这个演示展示了如何创建一个实用的工具面板界面，包含多种常用工具的快速访问。
            """
            
        case "高级Widget示例":
            return """
            高级Widget示例演示：
            
            1. 复杂数据处理和展示
            2. 多层级交互设计
            3. 自定义动画效果
            4. 高级布局技巧
            5. 性能优化策略
            6. 错误处理机制
            7. 无障碍功能支持
            
            这个演示展示了Widget开发中的高级技术和最佳实践。
            """
            
        case "自定义segmentView":
            return """
            自定义segmentView演示功能：
            
            1. 自定义分段控制器样式设计
            2. 流畅的切换动画效果
            3. 可定制的选中状态指示器
            4. 支持多种颜色主题
            5. 可配置的段数和标题
            6. 响应式布局适配
            7. 手势交互优化
            8. 状态管理和回调处理
            9. 无障碍功能支持
            10. 性能优化实现
            
            这个演示展示了如何创建一个功能完善的自定义分段控制器，
            提供比系统UISegmentedControl更丰富的视觉效果和交互体验。
            """
            
        default:
            return "这是一个Widget演示示例，展示了Widget开发的各种技术和最佳实践。"
        }
    }
    
    @objc private func runDemoTapped() {
        switch demoItem.title {
        case "透明组件演示":
            let transparentVC = TransparentComponentViewController()
            navigationController?.pushViewController(transparentVC, animated: true)
            
        case "清晰小日历组件":
            let calendarGridVC = CalendarGridViewController()
            navigationController?.pushViewController(calendarGridVC, animated: true)
            
        case "日历Widget":
            let calendarVC = CalendarViewController()
            navigationController?.pushViewController(calendarVC, animated: true)
            
        case "添加Widget弹窗":
            let widgetAddVC = WidgetAddViewController()
            widgetAddVC.modalPresentationStyle = .pageSheet
            if let sheet = widgetAddVC.sheetPresentationController {
                sheet.detents = [.large()]
                sheet.prefersGrabberVisible = true
                sheet.preferredCornerRadius = 20
            }
            present(widgetAddVC, animated: true)
            
        case "工具面板演示":
            let toolPanelVC = ToolPanelViewController()
            navigationController?.pushViewController(toolPanelVC, animated: true)
            
        case "高级Widget示例":
            let alert = UIAlertController(
                title: "高级Widget演示",
                message: "这是一个复杂的Widget功能演示，包含了多种高级特性和交互效果。",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "查看演示", style: .default) { _ in
                // 这里可以跳转到具体的高级演示页面
                let demoAlert = UIAlertController(
                    title: "演示功能",
                    message: "• 复杂数据处理\n• 自定义动画\n• 多层级交互\n• 性能优化",
                    preferredStyle: .alert
                )
                demoAlert.addAction(UIAlertAction(title: "确定", style: .default))
                self.present(demoAlert, animated: true)
            })
            alert.addAction(UIAlertAction(title: "取消", style: .cancel))
            present(alert, animated: true)
            
        case "自定义segmentView":
            let customSegmentDemoVC = CustomSegmentDemoViewController()
            navigationController?.pushViewController(customSegmentDemoVC, animated: true)
            
        default:
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