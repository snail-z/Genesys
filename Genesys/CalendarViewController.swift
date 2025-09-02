import UIKit

class CalendarViewController: UIViewController {
    
    // MARK: - 数据管理器
    private let dataManager = CalendarDataManager.shared
    
    // MARK: - UI Components
    private var scrollView: UIScrollView!
    private var contentView: UIView!
    
    // 头部
    private var headerView: UIView!
    private var yearMonthLabel: UILabel!
    private var prevButton: UIButton!
    private var nextButton: UIButton!
    private var todayButton: UIButton!
    
    // 星期头部
    private var weekHeaderView: UIView!
    private var weekLabels: [UILabel] = []
    
    // 日历网格
    private var calendarGridView: CalendarGridView!
    
    // 底部详情卡片
    private var detailCardView: UIView!
    private var lunarInfoLabel: UILabel!
    private var suitableLabel: UILabel!
    private var avoidLabel: UILabel!
    private var motivationLabel: UILabel!
    private var addNoteButton: UIButton!
    
    // MARK: - 数据
    private var currentDate = Date()
    private var selectedDate = Date()
    
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        updateDetailCard()
    }
    
    private func setupNavigationBar() {
        title = "日历"
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    private func setupGradientBackground() {
        // 创建清新淡雅绿渐变背景
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        
        // 清新淡雅绿色调
        let lightGreen = UIColor(red: 0.95, green: 0.98, blue: 0.95, alpha: 1.0).cgColor    // 极淡的薄荷绿
        let softGreen = UIColor(red: 0.90, green: 0.95, blue: 0.92, alpha: 1.0).cgColor     // 柔和浅绿
        let paleGreen = UIColor(red: 0.93, green: 0.97, blue: 0.94, alpha: 1.0).cgColor     // 淡雅绿
        
        gradientLayer.colors = [lightGreen, softGreen, paleGreen]
        gradientLayer.locations = [0.0, 0.5, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        // 视图大小改变时更新渐变
        gradientLayer.name = "backgroundGradient"
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // 更新渐变层大小
        if let gradientLayer = view.layer.sublayers?.first(where: { $0.name == "backgroundGradient" }) as? CAGradientLayer {
            gradientLayer.frame = view.bounds
        }
    }
    
    private func setupUI() {
        setupGradientBackground()
        
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        
        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        setupHeaderView()
        setupWeekHeaderView()
        setupCalendarGridView()
        setupDetailCardView()
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func setupHeaderView() {
        headerView = UIView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = UIColor(red: 0.92, green: 0.96, blue: 0.93, alpha: 0.8)
        headerView.layer.cornerRadius = 12
        
        yearMonthLabel = UILabel()
        yearMonthLabel.translatesAutoresizingMaskIntoConstraints = false
        yearMonthLabel.font = .boldSystemFont(ofSize: 20)
        yearMonthLabel.textColor = .label
        yearMonthLabel.textAlignment = .center
        
        prevButton = UIButton(type: .system)
        prevButton.translatesAutoresizingMaskIntoConstraints = false
        prevButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        prevButton.tintColor = .label
        prevButton.addTarget(self, action: #selector(prevMonthTapped), for: .touchUpInside)
        
        nextButton = UIButton(type: .system)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        nextButton.tintColor = .label
        nextButton.addTarget(self, action: #selector(nextMonthTapped), for: .touchUpInside)
        
        todayButton = UIButton(type: .system)
        todayButton.translatesAutoresizingMaskIntoConstraints = false
        todayButton.setTitle("今", for: .normal)
        todayButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        todayButton.backgroundColor = UIColor(red: 0.4, green: 0.8, blue: 0.6, alpha: 1.0)
        todayButton.setTitleColor(.white, for: .normal)
        todayButton.layer.cornerRadius = 15
        todayButton.addTarget(self, action: #selector(todayTapped), for: .touchUpInside)
        
        contentView.addSubview(headerView)
        headerView.addSubview(yearMonthLabel)
        headerView.addSubview(prevButton)
        headerView.addSubview(nextButton)
        headerView.addSubview(todayButton)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            headerView.heightAnchor.constraint(equalToConstant: 60),
            
            yearMonthLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            yearMonthLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            prevButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            prevButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            prevButton.widthAnchor.constraint(equalToConstant: 30),
            prevButton.heightAnchor.constraint(equalToConstant: 30),
            
            nextButton.trailingAnchor.constraint(equalTo: todayButton.leadingAnchor, constant: -12),
            nextButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            nextButton.widthAnchor.constraint(equalToConstant: 30),
            nextButton.heightAnchor.constraint(equalToConstant: 30),
            
            todayButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            todayButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            todayButton.widthAnchor.constraint(equalToConstant: 30),
            todayButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    private func setupWeekHeaderView() {
        weekHeaderView = UIView()
        weekHeaderView.translatesAutoresizingMaskIntoConstraints = false
        
        let weekdays = ["日", "一", "二", "三", "四", "五", "六"]
        let colors: [UIColor] = [.systemRed, .label, .label, .label, .label, .label, .systemRed]
        
        for (index, weekday) in weekdays.enumerated() {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = weekday
            label.font = .systemFont(ofSize: 16, weight: .medium)
            label.textColor = colors[index]
            label.textAlignment = .center
            
            weekHeaderView.addSubview(label)
            weekLabels.append(label)
            
            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: weekHeaderView.topAnchor),
                label.bottomAnchor.constraint(equalTo: weekHeaderView.bottomAnchor),
                label.widthAnchor.constraint(equalTo: weekHeaderView.widthAnchor, multiplier: 1.0/7.0),
                label.leadingAnchor.constraint(equalTo: weekHeaderView.leadingAnchor, constant: CGFloat(index) * UIScreen.main.bounds.width / 7.0)
            ])
        }
        
        contentView.addSubview(weekHeaderView)
        
        NSLayoutConstraint.activate([
            weekHeaderView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 16),
            weekHeaderView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            weekHeaderView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            weekHeaderView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func setupCalendarGridView() {
        calendarGridView = CalendarGridView()
        calendarGridView.translatesAutoresizingMaskIntoConstraints = false
        calendarGridView.delegate = self
        
        contentView.addSubview(calendarGridView)
        
        NSLayoutConstraint.activate([
            calendarGridView.topAnchor.constraint(equalTo: weekHeaderView.bottomAnchor, constant: 8),
            calendarGridView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            calendarGridView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            calendarGridView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
    
    private func setupDetailCardView() {
        detailCardView = UIView()
        detailCardView.translatesAutoresizingMaskIntoConstraints = false
        detailCardView.backgroundColor = UIColor(red: 0.92, green: 0.96, blue: 0.93, alpha: 0.85)
        detailCardView.layer.cornerRadius = 16
        detailCardView.layer.shadowColor = UIColor.black.cgColor
        detailCardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        detailCardView.layer.shadowRadius = 8
        detailCardView.layer.shadowOpacity = 0.1
        
        // 农历信息
        lunarInfoLabel = UILabel()
        lunarInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        lunarInfoLabel.font = .boldSystemFont(ofSize: 18)
        lunarInfoLabel.textColor = .label
        lunarInfoLabel.numberOfLines = 0
        
        // 宜事项
        let suitableIconLabel = UILabel()
        suitableIconLabel.translatesAutoresizingMaskIntoConstraints = false
        suitableIconLabel.text = "宜"
        suitableIconLabel.font = .boldSystemFont(ofSize: 14)
        suitableIconLabel.textColor = .white
        suitableIconLabel.backgroundColor = .systemGreen
        suitableIconLabel.textAlignment = .center
        suitableIconLabel.layer.cornerRadius = 10
        suitableIconLabel.clipsToBounds = true
        
        suitableLabel = UILabel()
        suitableLabel.translatesAutoresizingMaskIntoConstraints = false
        suitableLabel.font = .systemFont(ofSize: 14)
        suitableLabel.textColor = .secondaryLabel
        suitableLabel.numberOfLines = 0
        
        // 忌事项
        let avoidIconLabel = UILabel()
        avoidIconLabel.translatesAutoresizingMaskIntoConstraints = false
        avoidIconLabel.text = "忌"
        avoidIconLabel.font = .boldSystemFont(ofSize: 14)
        avoidIconLabel.textColor = .white
        avoidIconLabel.backgroundColor = .systemRed
        avoidIconLabel.textAlignment = .center
        avoidIconLabel.layer.cornerRadius = 10
        avoidIconLabel.clipsToBounds = true
        
        avoidLabel = UILabel()
        avoidLabel.translatesAutoresizingMaskIntoConstraints = false
        avoidLabel.font = .systemFont(ofSize: 14)
        avoidLabel.textColor = .secondaryLabel
        avoidLabel.numberOfLines = 0
        
        // 添加备注按钮
        addNoteButton = UIButton(type: .system)
        addNoteButton.translatesAutoresizingMaskIntoConstraints = false
        addNoteButton.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
        addNoteButton.setTitle("  添加备注", for: .normal)
        addNoteButton.titleLabel?.font = .systemFont(ofSize: 16)
        addNoteButton.tintColor = .systemBlue
        addNoteButton.addTarget(self, action: #selector(addNoteTapped), for: .touchUpInside)
        
        // 励志文案
        motivationLabel = UILabel()
        motivationLabel.translatesAutoresizingMaskIntoConstraints = false
        motivationLabel.font = .systemFont(ofSize: 14)
        motivationLabel.textColor = .tertiaryLabel
        motivationLabel.textAlignment = .center
        motivationLabel.numberOfLines = 0
        
        contentView.addSubview(detailCardView)
        detailCardView.addSubview(lunarInfoLabel)
        detailCardView.addSubview(suitableIconLabel)
        detailCardView.addSubview(suitableLabel)
        detailCardView.addSubview(avoidIconLabel)
        detailCardView.addSubview(avoidLabel)
        detailCardView.addSubview(addNoteButton)
        detailCardView.addSubview(motivationLabel)
        
        NSLayoutConstraint.activate([
            detailCardView.topAnchor.constraint(equalTo: calendarGridView.bottomAnchor, constant: 20),
            detailCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            detailCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            detailCardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            lunarInfoLabel.topAnchor.constraint(equalTo: detailCardView.topAnchor, constant: 20),
            lunarInfoLabel.leadingAnchor.constraint(equalTo: detailCardView.leadingAnchor, constant: 20),
            lunarInfoLabel.trailingAnchor.constraint(equalTo: detailCardView.trailingAnchor, constant: -20),
            
            suitableIconLabel.topAnchor.constraint(equalTo: lunarInfoLabel.bottomAnchor, constant: 16),
            suitableIconLabel.leadingAnchor.constraint(equalTo: detailCardView.leadingAnchor, constant: 20),
            suitableIconLabel.widthAnchor.constraint(equalToConstant: 20),
            suitableIconLabel.heightAnchor.constraint(equalToConstant: 20),
            
            suitableLabel.centerYAnchor.constraint(equalTo: suitableIconLabel.centerYAnchor),
            suitableLabel.leadingAnchor.constraint(equalTo: suitableIconLabel.trailingAnchor, constant: 8),
            suitableLabel.trailingAnchor.constraint(equalTo: detailCardView.trailingAnchor, constant: -20),
            
            avoidIconLabel.topAnchor.constraint(equalTo: suitableLabel.bottomAnchor, constant: 12),
            avoidIconLabel.leadingAnchor.constraint(equalTo: detailCardView.leadingAnchor, constant: 20),
            avoidIconLabel.widthAnchor.constraint(equalToConstant: 20),
            avoidIconLabel.heightAnchor.constraint(equalToConstant: 20),
            
            avoidLabel.centerYAnchor.constraint(equalTo: avoidIconLabel.centerYAnchor),
            avoidLabel.leadingAnchor.constraint(equalTo: avoidIconLabel.trailingAnchor, constant: 8),
            avoidLabel.trailingAnchor.constraint(equalTo: detailCardView.trailingAnchor, constant: -20),
            
            addNoteButton.topAnchor.constraint(equalTo: avoidLabel.bottomAnchor, constant: 20),
            addNoteButton.centerXAnchor.constraint(equalTo: detailCardView.centerXAnchor),
            
            motivationLabel.topAnchor.constraint(equalTo: addNoteButton.bottomAnchor, constant: 20),
            motivationLabel.leadingAnchor.constraint(equalTo: detailCardView.leadingAnchor, constant: 20),
            motivationLabel.trailingAnchor.constraint(equalTo: detailCardView.trailingAnchor, constant: -20),
            motivationLabel.bottomAnchor.constraint(equalTo: detailCardView.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: - 更新日历
    private func updateYearMonthLabel() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年 MM月"
        yearMonthLabel.text = formatter.string(from: currentDate)
    }
    
    private func updateDetailCard() {
        let dayDetail = dataManager.generateDayDetail(for: selectedDate)
        
        lunarInfoLabel.text = "\(dayDetail.lunarDate) \(dayDetail.zodiac) \(dayDetail.ganZhi)"
        suitableLabel.text = dayDetail.suitable.joined(separator: " ")
        avoidLabel.text = dayDetail.avoid.joined(separator: " ")
        motivationLabel.text = dayDetail.motivation
    }
    
    // MARK: - 事件处理
    @objc private func prevMonthTapped() {
        calendarGridView.navigateToMonth(-1)
    }
    
    @objc private func nextMonthTapped() {
        calendarGridView.navigateToMonth(1)
    }
    
    @objc private func todayTapped() {
        selectedDate = Date()
        currentDate = Date()
        calendarGridView.scrollToToday()
        updateYearMonthLabel()
        updateDetailCard()
    }
    
    @objc private func addNoteTapped() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        let dateString = formatter.string(from: selectedDate)
        
        let alert = UIAlertController(
            title: "添加备注",
            message: "为\(dateString)添加一个备注提醒",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "输入备注内容..."
        }
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "保存", style: .default) { _ in
            if let text = alert.textFields?.first?.text, !text.isEmpty {
                // 这里可以保存备注到本地存储
                let savedAlert = UIAlertController(title: "保存成功", message: "备注已保存", preferredStyle: .alert)
                savedAlert.addAction(UIAlertAction(title: "确定", style: .default))
                self.present(savedAlert, animated: true)
            }
        })
        
        present(alert, animated: true)
    }
}

// MARK: - CalendarGridViewDelegate
extension CalendarViewController: CalendarGridViewDelegate {
    func didSelectDate(_ date: Date) {
        selectedDate = date
        updateDetailCard()
    }
    
    func didChangeMonth(_ date: Date) {
        currentDate = date
        updateYearMonthLabel()
    }
}