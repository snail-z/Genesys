import UIKit

struct DemoItem {
    let title: String
    let description: String
    let icon: String
}

class DemoListViewController: UIViewController {
    
    private var tableView: UITableView!
    
    private let demoItems: [DemoItem] = [
        DemoItem(title: "Widget基础示例", description: "展示基础Widget的创建和配置", icon: "square.fill"),
        DemoItem(title: "透明组件演示", description: "展示透明背景和半透明效果的组件实现", icon: "circle.dashed"),
        DemoItem(title: "Timeline更新", description: "演示Widget的时间线更新机制", icon: "clock.fill"),
        DemoItem(title: "添加Widget弹窗", description: "演示Widget添加弹窗和配置界面", icon: "plus.circle.fill"),
        DemoItem(title: "Widget使用教程", description: "如何将小组件添加到主屏幕", icon: "questionmark.circle.fill"),
        DemoItem(title: "工具面板演示", description: "展示多功能工具面板界面和交互效果", icon: "wrench.and.screwdriver.fill"),
        DemoItem(title: "动态内容", description: "显示动态变化的Widget内容", icon: "arrow.triangle.2.circlepath"),
        DemoItem(title: "网络数据", description: "从网络获取数据并显示在Widget中", icon: "network"),
        DemoItem(title: "深度链接", description: "Widget点击跳转到应用特定页面", icon: "link.circle.fill"),
        DemoItem(title: "多尺寸适配", description: "适配不同尺寸的Widget布局", icon: "rectangle.3.group.fill"),
        DemoItem(title: "日历Widget", description: "显示日历和日程安排的Widget示例", icon: "calendar"),
        DemoItem(title: "Live Activity", description: "实时活动展示示例", icon: "bolt.circle.fill"),
        DemoItem(title: "高级Widget示例", description: "展示复杂Widget功能和交互", icon: "star.circle.fill")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        title = "Widget Demo"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(DemoTableViewCell.self, forCellReuseIdentifier: "DemoCell")
        tableView.rowHeight = 80
        tableView.separatorStyle = .singleLine
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension DemoListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return demoItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DemoCell", for: indexPath) as! DemoTableViewCell
        let item = demoItems[indexPath.row]
        cell.configure(with: item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = demoItems[indexPath.row]
        
        // 如果是Widget使用教程，直接跳转到教程页面
        if item.title == "Widget使用教程" {
            let tutorialVC = TutorialDetailViewController()
            tutorialVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(tutorialVC, animated: true)
        } else {
            let detailVC = DemoDetailViewController(demoItem: item)
            detailVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
}

class DemoTableViewCell: UITableViewCell {
    
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let arrowImageView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .systemBlue
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .boldSystemFont(ofSize: 16)
        titleLabel.textColor = .label
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.font = .systemFont(ofSize: 14)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 2
        
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        arrowImageView.image = UIImage(systemName: "chevron.right")
        arrowImageView.tintColor = .systemGray3
        arrowImageView.contentMode = .scaleAspectFit
        
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(arrowImageView)
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 30),
            iconImageView.heightAnchor.constraint(equalToConstant: 30),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: arrowImageView.leadingAnchor, constant: -16),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -12),
            
            arrowImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            arrowImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            arrowImageView.widthAnchor.constraint(equalToConstant: 12),
            arrowImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    func configure(with item: DemoItem) {
        iconImageView.image = UIImage(systemName: item.icon)
        titleLabel.text = item.title
        descriptionLabel.text = item.description
    }
}